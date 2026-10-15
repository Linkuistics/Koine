include "application-location-observations";
include "application-refusal-observations";

# Each expected subject must have exactly one retained observation. Raw verdicts
# remain intact; this instrument corrects only the literal-guidance matcher.
def one($name):
  [$raw[0][] | select(.case == $name)]
  | if length == 1 then .[0] else error("missing or duplicate case: " + $name) end;
def verdict($record; $valid; $basis):
  {case: $record.case, originalStatus: $record.status,
   status: (if $valid then "passed" else "failed" end), basis: $basis};
def selected($path): .windows > 0 and any(.selected[]; .path == $path);

one("independent 1023-byte document delivery") as $control
| ([$control.log[] | select(.event == "open" and (.path | utf8bytelength) == 1023) | .path] | unique) as $controlPaths
| if ($controlPaths | length) != 1 then error("ambiguous or missing control path") else $controlPaths[0] end as $controlPath
| one("component-created long copies and native registration attempts") as $registration
| if $registration.observed != $subjects[0] then error("registration evidence differs from subjects") else . end
| (
[
  ((1024, 1500) as $bytes
  | ($subjects[0].subjects | map(select(.bytes == $bytes))) as $matches
  | if ($matches | length) != 1 then error("missing or duplicate application subject") else $matches[0].path end as $application
  | ("launch", "open") as $kind | ("cold", "running") as $state
  | one($kind + ": " + ($bytes | tostring) + "-byte constrained application, " + $state + "; no substitution") as $r
  | verdict($r; ($r.observed | supplied_refusal($bytes; $kind; $application))
      and (if $state == "cold" then ($r.observed.before | length) == 0
           else ($r.observed.before | length) == 1
             and $r.observed.before[0].bundle == "/Users/admin/install-fx/A/Fixture.app" end);
      "exact literal selector, canonical stage/kind/count guidance, no receipt/dependency/delivery/process change")),
  (("A", "B") as $copy | ("launch", "open") as $kind
   | one($kind + ": constrained short " + $copy + " beside long copies on disk") as $r
   | verdict($r; ($r.observed | short_workflow($copy; $kind; "/Users/admin/install-fx/docs/note-1.koineinstall"));
       "exact physical bundle and document, non-null receipt matches kernel PID/start")),
  (("launch", "open") as $kind
   | one($kind + ": unconstrained short preferred A beside long copies on disk") as $r
   | verdict($r; ($r.observed | short_workflow("A"; $kind; "/Users/admin/install-fx/docs/note-1.koineinstall"));
       "actual preferred A, exact bundle/document and kernel-backed receipt")),
  (one("independent 1023-byte document delivery") as $r
   | verdict($r; $r.status == "passed" and $r.wrongPathMutationRejected == true
       and any($r.log[]; .event == "open" and (.path | utf8bytelength) == 1023
         and .label == "A" and .bundlePath == "/Users/admin/install-fx/A/Fixture.app"
         and .atMs >= $r.controlSentMs and .atMs - $r.controlSentMs < 20000);
       "retained independent delivery within 20 seconds; live exact-path assertion and rejected wrong-path control")),
  (one("independent 1023-byte Finder selection") as $r
   | verdict($r; $r.status == "passed" and $r.finder.windows > 0
       and ($r.finder | selected($controlPath));
       "retained exact independently delivered 1023-byte control path selected by Finder")),
  (one("short reveal finds Finder beside long copies") as $r
   | verdict($r; $r.status == "passed" and ($r.finder | selected("/Users/admin/install-fx/docs/note-1.koineinstall"))
       and $reveal[0].answer.classification == "ok" and $reveal[0].answer.status == "AVAILABLE"
       and $reveal[0].answer.dependency == null and ($reveal[0].answer.errors | length) == 0
       and $reveal[0].answer.path == "/Users/admin/install-fx/docs/note-1.koineinstall";
       "retained exact Finder selection and full atomic request acknowledgement")),
  (("no system dialog after the section", "accessibility absent throughout") as $name
   | one($name) as $r | verdict($r; $r.status == "passed";
       "retained live permission/dialog assertion in unchanged measurement recipe")),
  (("preferred long copy refusal, cold and with a short copy running",
     "short selected beside registered long copy in both enumeration orders") as $name
   | one($name) as $r
   | if $r.status != "pending" then error("native precondition row is not pending")
     else {case: $name, originalStatus: $r.status, status: "pending", basis: $r.notes} end)
] as $evaluated
| if ($evaluated | length) != 21 then error("unexpected evaluation count")
  elif ($raw[0] | map(.case) | sort) !=
       ([$evaluated[].case, "what Launch Services says before any request", "component-created long copies and native registration attempts"] | sort)
  then error("unexpected raw case set")
  elif any($raw[0][]; .status == "failed" and (.case | test("^(launch|open): (1024|1500)-byte constrained application, (cold|running); no substitution$") | not))
  then error("unaccounted raw failure")
  else {instrument: "recorded-observation reevaluation; raw results preserved",
        results: $evaluated, counts: ($evaluated | group_by(.status) | map({status: .[0].status, count: length}))} end
)
