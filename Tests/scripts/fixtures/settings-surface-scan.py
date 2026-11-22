"""Scan the strict surface of the Settings scenario from its syntax trees.

Usage: settings-surface-scan.py SCENARIO

The scan parses each script with `shfmt --to-json`. It follows every `source`
from SCENARIO and then every call from the top-level commands and the traps. It
prints one JSON report on the functions that SCENARIO can reach:

- `legacy`: each call of `testanyware` or of a function that a legacy library
  defines, with the lane that holds it. The lane is `root-unset`, `root-set` or
  `unguarded`.
- `external`: the name of each other command.
- `dynamic`: each call whose command word is not a literal.
- `predicates`: each jq filter or CLI payload predicate that the surface passes.
- `constant_true`: the predicates that yield true for every sample input and
  every value that replaces a shell expansion.
- `unparsed`: the predicates that jq cannot compile for any replacement.

The report is evidence about the source text. It proves no runtime behaviour.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

Node = dict[str, Any]

LEGACY_LIBRARIES = {"vm-verify-lib.sh", "vm-verify-desktop-lib.sh"}
ROOT_SET = '[[ "${KOINE_VM_EVIDENCE_ROOT+x}" ]]'
ROOT_UNSET = '[[ ! "${KOINE_VM_EVIDENCE_ROOT+x}" ]]'
SOURCING_SCRIPT = '"${BASH_SOURCE[1]##*/}"'
# A shell expansion in a predicate takes each of these values in turn.
EXPANSION = "__KOINE_EXPANSION__"
REPLACEMENTS = ["null", "0", "1", '"x"', "true", "false", "[]"]
SAMPLES = (
    '[null, false, true, 0, 1, "", "x", [], [1], {}, {"value": 1}, {"value": []},'
    ' {"windows": []}, {"windows": [{"appName": "x"}]}, {"present": false}]'
)
JQ_VALUE_OPTIONS = {"--arg": 2, "--argjson": 2, "--slurpfile": 2, "--rawfile": 2}
JQ_BUILTIN_VARIABLES = {"ENV", "ARGS", "__loc__", "__prog_args"}


@dataclass
class Call:
    name: str | None
    args: list[Node]
    line: int
    file: str
    function: str
    lane: str


@dataclass
class Function:
    name: str
    file: str
    body: Node
    source: bytes
    calls: list[Call] = field(default_factory=list)
    # Each variable's possible values, from its assignments in source order.
    values: dict[str, list[list[Node]]] = field(default_factory=dict)


@dataclass
class Scan:
    functions: dict[str, Function] = field(default_factory=dict)
    top: list[Function] = field(default_factory=list)
    entry: str = ""


def parse(path: Path) -> tuple[Node, bytes]:
    source = path.read_bytes()
    result = subprocess.run(
        ["shfmt", "--to-json"], input=source, capture_output=True, check=True
    )
    return json.loads(result.stdout), source


def text_of(node: Node, source: bytes) -> str:
    return source[node["Pos"]["Offset"] : node["End"]["Offset"]].decode()


def unescape(value: str, quoted: bool) -> str:
    pattern = r'\\([$`"\\])' if quoted else r"\\(.)"
    return re.sub(pattern, r"\1", value)


def literal(word: Node) -> str | None:
    """The text of a word without expansions, or None."""
    out = ""
    for part in word.get("Parts", []):
        kind = part.get("Type")
        if kind == "Lit":
            out += unescape(part.get("Value", ""), quoted=False)
        elif kind == "SglQuoted":
            out += part.get("Value", "")
        elif kind == "DblQuoted":
            inner = part.get("Parts", [])
            if any(item.get("Type") != "Lit" for item in inner):
                return None
            out += "".join(
                unescape(item.get("Value", ""), quoted=True) for item in inner
            )
        else:
            return None
    return out


def single_expansion(word: Node) -> str | None:
    """The parameter name when the whole word is one plain expansion."""
    parts = word.get("Parts", [])
    if len(parts) == 1 and parts[0].get("Type") == "DblQuoted":
        parts = parts[0].get("Parts", [])
    if len(parts) != 1 or parts[0].get("Type") != "ParamExp":
        return None
    expansion = parts[0]
    if expansion.get("Index") or expansion.get("Repl") or expansion.get("Excl"):
        return None
    if expansion.get("Length") or expansion.get("Slice"):
        return None
    operator = expansion.get("Exp")
    # `${4-}` is a positional parameter with an empty default.
    if operator and operator.get("Word"):
        return None
    return expansion["Param"]["Value"]


def source_target(word: Node, current: Path, repository: Path) -> Path | None:
    out = ""
    for part in word.get("Parts", []):
        inner = part.get("Parts", []) if part.get("Type") == "DblQuoted" else [part]
        for item in inner:
            if item.get("Type") == "Lit":
                out += item.get("Value", "")
            elif (
                item.get("Type") == "ParamExp"
                and item["Param"]["Value"] == "BASH_SOURCE"
            ):
                out += str(current.parent)
            else:
                return None
    path = Path(out)
    return path if path.is_absolute() else repository / path


def is_statement_list(value: Any) -> bool:
    return (
        isinstance(value, list)
        and bool(value)
        and isinstance(value[0], dict)
        and "Cmd" in value[0]
    )


def ends_in_return(statements: list[Node]) -> bool:
    command = statements[-1].get("Cmd") or {} if statements else {}
    if command.get("Type") != "CallExpr" or not command.get("Args"):
        return False
    return literal(command["Args"][0]) == "return"


class Walker:
    def __init__(self, function: Function, entry: str) -> None:
        self.function = function
        self.entry = entry
        # The depth of conditional branches around the current statement.
        self.branches = 0

    def statements(self, items: list[Node], lane: str) -> None:
        for statement in items:
            command = statement.get("Cmd") or {}
            if command.get("Type") == "IfClause":
                following = self.if_clause(command, lane)
                self.visit({k: v for k, v in statement.items() if k != "Cmd"}, lane)
                lane = following or lane
            else:
                self.visit(statement, lane)

    def if_clause(self, clause: Node, lane: str) -> str | None:
        """Visit one if. Return the lane of the statements after an early return."""
        condition = clause.get("Cond") or []
        text = text_of(condition[0], self.function.source) if condition else ""
        text = text.rstrip(";").strip()
        then_lane, else_lane = lane, lane
        if text == ROOT_SET:
            then_lane, else_lane = "root-set", "root-unset"
        elif text == ROOT_UNSET:
            then_lane, else_lane = "root-unset", "root-set"
        self.statements(condition, lane)
        then = clause.get("Then") or []
        self.branches += 1
        self.statements(then, then_lane)
        otherwise = clause.get("Else")
        if otherwise:
            if otherwise.get("Cond"):
                self.if_clause(otherwise, else_lane)
            else:
                self.statements(otherwise.get("Then") or [], else_lane)
            self.branches -= 1
            return None
        self.branches -= 1
        if else_lane != lane and ends_in_return(then):
            return else_lane
        return None

    def case_clause(self, clause: Node, lane: str) -> None:
        word = clause["Word"]
        selective = text_of(word, self.function.source) == SOURCING_SCRIPT
        chosen = False
        for item in clause.get("Items") or []:
            patterns = [literal(pattern) for pattern in item.get("Patterns") or []]
            if selective:
                if chosen or not (self.entry in patterns or "*" in patterns):
                    continue
                chosen = True
            self.branches += 1
            self.statements(item.get("Stmts") or [], lane)
            self.branches -= 1

    def assignment(self, assign: Node) -> None:
        name = assign.get("Name")
        value = assign.get("Value")
        if not name or value is None:
            return
        choices = self.function.values.setdefault(name["Value"], [])
        if assign.get("Append") and choices:
            appended = [[*choice, value] for choice in choices]
            # A branch can skip its append, so the shorter spelling stays possible.
            choices[:] = [*choices, *appended] if self.branches else appended
        else:
            choices.append([value])

    def visit(self, node: Any, lane: str) -> None:
        if isinstance(node, list):
            if is_statement_list(node):
                self.statements(node, lane)
            else:
                for item in node:
                    self.visit(item, lane)
            return
        if not isinstance(node, dict):
            return
        kind = node.get("Type")
        if kind == "FuncDecl":
            return
        if kind == "IfClause":
            self.if_clause(node, lane)
            return
        if kind == "CaseClause":
            self.case_clause(node, lane)
            return
        if kind == "DeclClause":
            for assign in node.get("Args") or []:
                self.assignment(assign)
        if kind == "CallExpr":
            for assign in node.get("Assigns") or []:
                self.assignment(assign)
            args = node.get("Args") or []
            if args:
                self.function.calls.append(
                    Call(
                        literal(args[0]),
                        args[1:],
                        args[0]["Pos"]["Line"],
                        self.function.file,
                        self.function.name,
                        lane,
                    )
                )
        for key, value in node.items():
            if key not in {"Pos", "End"}:
                self.visit(value, lane)


def load(path: Path, repository: Path, scan: Scan, stack: tuple[Path, ...]) -> None:
    resolved = path.resolve()
    if resolved in stack:
        return
    tree, source = parse(resolved)
    top = Function(f"<top:{resolved.name}>", resolved.name, tree, source)
    kept: list[Node] = []
    for statement in tree.get("Stmts") or []:
        command = statement.get("Cmd") or {}
        if command.get("Type") == "FuncDecl":
            name = command["Name"]["Value"]
            scan.functions[name] = Function(
                name, resolved.name, command["Body"], source
            )
            continue
        args = command.get("Args") or []
        if (
            command.get("Type") == "CallExpr"
            and args
            and literal(args[0]) in {"source", "."}
        ):
            target = source_target(args[1], resolved, repository)
            if target is None:
                raise SystemExit(f"{resolved}: a source path is not static")
            load(target, repository, scan, (*stack, resolved))
            continue
        kept.append(statement)
    top.body = {"Stmts": kept}
    scan.top.append(top)


def apply_fence(scan: Scan) -> None:
    """The fence replaces each legacy name before the first transport."""
    fence = scan.functions.get("settings_fence")
    if fence is None:
        return

    def find(node: Any) -> None:
        if isinstance(node, list):
            for item in node:
                find(item)
        elif isinstance(node, dict):
            if node.get("Type") == "FuncDecl":
                name = node["Name"]["Value"]
                scan.functions[name] = Function(
                    name, fence.file, node["Body"], fence.source
                )
                return
            for key, value in node.items():
                if key not in {"Pos", "End"}:
                    find(value)

    find(fence.body)


def trap_handlers(call: Call) -> list[str]:
    if call.name != "trap" or not call.args:
        return []
    handler = literal(call.args[0])
    return handler.split()[:1] if handler and handler != "-" else []


def reachable(scan: Scan) -> tuple[list[Function], dict[str, Function]]:
    for function in [*scan.top, *scan.functions.values()]:
        Walker(function, scan.entry).visit(function.body, "unguarded")
    seen: dict[str, Function] = {}
    work = [
        name
        for top in scan.top
        for call in top.calls
        for name in (call.name, *trap_handlers(call))
        if name
    ]
    while work:
        name = work.pop()
        function = scan.functions.get(name)
        if function is None or name in seen:
            continue
        seen[name] = function
        for call in function.calls:
            if call.name:
                work.append(call.name)
            work.extend(trap_handlers(call))
    return scan.top, seen


def jq_filter(call: Call) -> Node | None:
    """The filter word of a jq call that tests its result with -e."""
    index = 0
    tests = False
    while index < len(call.args):
        word = literal(call.args[index])
        if word in JQ_VALUE_OPTIONS:
            index += JQ_VALUE_OPTIONS[word] + 1
        elif word is not None and word.startswith("-"):
            if not word.startswith("--") and "e" in word:
                tests = True
            index += 1
        else:
            return call.args[index] if tests else None
    return None


def argument_index(call: Call, position: int) -> tuple[Node | None, int | None]:
    """The word at POSITION, or the caller's position that "$@" forwards to it."""
    for index, word in enumerate(call.args):
        if single_expansion(word) == "@":
            return None, position - index if position >= index else None
        if index == position:
            return word, None
    return None, None


def origin(function: Function, word: Node) -> int | None:
    """The zero-based parameter that WORD forwards unchanged, if any."""
    name = single_expansion(word)
    if name is None:
        parts = word.get("Parts", [])
        inner = parts[0].get("Parts", []) if parts else []
        if len(inner) == 1 and inner[0].get("Type") == "ParamExp":
            name = inner[0]["Param"]["Value"]
    if name is None:
        return None
    if name.isdigit():
        return int(name) - 1
    choices = function.values.get(name, [])
    if len(choices) == 1 and len(choices[0]) == 1:
        return origin(function, choices[0][0])
    return None


def render(function: Function, word: Node, depth: int = 0) -> list[str]:
    """Each possible text of WORD, with EXPANSION for an unknown shell value."""
    texts = [""]
    for part in word.get("Parts", []):
        kind = part.get("Type")
        if kind == "DblQuoted":
            choices = render(function, {"Parts": part.get("Parts", [])}, depth)
            # Inside double quotes, a Lit keeps its escapes for the shell.
            choices = [unescape(choice, quoted=True) for choice in choices]
        elif kind in {"Lit", "SglQuoted"}:
            choices = [part.get("Value", "")]
        elif kind == "ParamExp" and depth < 8:
            options = function.values.get(part["Param"]["Value"], [])
            choices = []
            for option in options:
                joined = [""]
                for value in option:
                    rendered = render(function, value, depth + 1)
                    joined = [a + b for a in joined for b in rendered]
                choices.extend(joined)
            choices = choices or [EXPANSION]
        else:
            choices = [EXPANSION]
        texts = [a + b for a in texts for b in choices]
    return texts


def predicate_sites(functions: dict[str, Function]) -> list[dict[str, Any]]:
    positions: dict[str, set[int]] = {"cli_guest_evidence": {3}}
    changed = True
    while changed:
        changed = False
        for function in functions.values():
            for call in function.calls:
                forwarded: list[int] = []
                if call.name == "jq":
                    word = jq_filter(call)
                    if (
                        word is not None
                        and (index := origin(function, word)) is not None
                    ):
                        forwarded.append(index)
                for position in positions.get(call.name or "", set()):
                    word, through = argument_index(call, position)
                    if through is not None:
                        forwarded.append(through)
                    elif (
                        word is not None
                        and (index := origin(function, word)) is not None
                    ):
                        forwarded.append(index)
                for index in forwarded:
                    if index not in positions.setdefault(function.name, set()):
                        positions[function.name].add(index)
                        changed = True
    sites: list[dict[str, Any]] = []
    for function in functions.values():
        for call in function.calls:
            words: list[Node] = []
            if call.name == "jq" and (word := jq_filter(call)) is not None:
                words.append(word)
            for position in positions.get(call.name or "", set()):
                word, _ = argument_index(call, position)
                if word is not None:
                    words.append(word)
            for word in words:
                if origin(function, word) is not None:
                    continue
                for text in render(function, word):
                    # An empty value is the facade's refused argument form.
                    if text.strip() not in {"", EXPANSION}:
                        sites.append(
                            {
                                "file": call.file,
                                "line": call.line,
                                "function": function.name,
                                "callee": call.name,
                                "text": text,
                            }
                        )
    return sites


def builder_sites(functions: dict[str, Function], entry: Path) -> list[dict[str, Any]]:
    """Run each reachable *_predicate builder, because its output is a gate."""
    sites: list[dict[str, Any]] = []
    for name, function in sorted(functions.items()):
        if not name.endswith("_predicate"):
            continue
        library = entry.parent / function.file
        result = subprocess.run(
            ["bash", "-c", 'source "$1" && "$2" Koine 1', "scan", library, name],
            capture_output=True,
            text=True,
            check=True,
        )
        sites.append(
            {
                "file": function.file,
                "line": function.body["Pos"]["Line"],
                "function": name,
                "callee": "builder",
                "text": result.stdout.strip(),
            }
        )
    return sites


def always_true(predicate: str) -> bool | None:
    """True if constant, False if falsified, None if jq compiles no replacement."""
    compiled = False
    for replacement in REPLACEMENTS:
        program = predicate.replace(EXPANSION, replacement)
        bound: list[str] = []
        for name in sorted(set(re.findall(r"\$([A-Za-z_]\w*)", program))):
            if name not in JQ_BUILTIN_VARIABLES:
                bound += ["--arg", name, "x"]
        check = f"[$samples[] | try ([({program})] == [true]) catch false] | all"
        result = subprocess.run(
            ["jq", "-n", "--argjson", "samples", SAMPLES, *bound, check],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            continue
        compiled = True
        if result.stdout.strip() != "true":
            return False
    return True if compiled else None


def main() -> int:
    entry = Path(sys.argv[1]).resolve()
    repository = entry.parent.parent
    scan = Scan(entry=entry.name)
    load(entry, repository, scan, ())
    legacy_names = {
        name
        for name, function in scan.functions.items()
        if function.file in LEGACY_LIBRARIES
    }
    fence = scan.functions.get("settings_fence")
    fenced: set[str] = set()
    if fence is not None:
        fenced = set(
            re.findall(r"(\w+)\(\) \{ settings_(?:legacy|fail)", fence.source.decode())
        )
    apply_fence(scan)
    top, functions = reachable(scan)
    surface = [*top, *functions.values()]
    legacy: list[dict[str, Any]] = []
    external: set[str] = set()
    dynamic: list[dict[str, Any]] = []
    for function in surface:
        if function.file in LEGACY_LIBRARIES and function.name in functions:
            legacy.append(
                {
                    "kind": "function",
                    "file": function.file,
                    "function": function.name,
                }
            )
        for call in function.calls:
            if call.name is None:
                dynamic.append(
                    {"file": call.file, "line": call.line, "function": function.name}
                )
            elif call.name == "testanyware" or call.name in fenced:
                legacy.append(
                    {
                        "kind": "call",
                        "command": call.name,
                        "file": call.file,
                        "line": call.line,
                        "function": function.name,
                        "lane": call.lane,
                    }
                )
            elif call.name not in scan.functions and call.name not in legacy_names:
                external.add(call.name)
    sites = predicate_sites({f.name: f for f in surface})
    sites += builder_sites(functions, entry)
    verdicts = {text: always_true(text) for text in {site["text"] for site in sites}}
    report = {
        "files": sorted({function.file for function in surface}),
        "functions": sorted(functions),
        "legacy": sorted(
            legacy, key=lambda item: (item["file"], item.get("line", 0), item["kind"])
        ),
        "external": sorted(external),
        "dynamic": dynamic,
        "predicate_count": len(sites),
        "predicates": sorted(verdicts),
        "constant_true": [site for site in sites if verdicts[site["text"]] is True],
        "unparsed": [site for site in sites if verdicts[site["text"]] is None],
    }
    json.dump(report, sys.stdout, indent=1)
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
