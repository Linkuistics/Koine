import glob, json, re, subprocess, sys, tempfile, os
lines = open('Taskfile.yml').read().splitlines()
task = None; rows = []
for n, l in enumerate(lines, 1):
    m = re.match(r'^  ([a-zA-Z0-9:_-]+):\s*$', l)
    if m: task = m.group(1)
    m = re.match(r'^\s+- bash -n (.+)$', l)
    if m:
        files = []
        for a in m.group(1).split():
            files += sorted(glob.glob(a)) if '*' in a else [a]
        rows.append((n, task, files))
multi = [r for r in rows if len(r[2]) > 1]
unparsed = sorted({f for r in multi for f in r[2][1:]})
def parse(f):
    if f.endswith('.bats'):
        p = subprocess.run(['bats', '--count', f], capture_output=True, text=True)
        return 'bats --count', p.returncode, (p.stderr or '').strip()[:160]
    p = subprocess.run(['bash', '-n', f], capture_output=True, text=True)
    return 'bash -n', p.returncode, p.stderr.strip()[:160]
results = {f: parse(f) for f in sorted({f for r in rows for f in r[2]})}
harness = [f for f in results if re.match(r'(scripts/vm-|Tests/scripts/vm-)', f)]
print('lines', len(rows), 'multi-file lines', len(multi), 'files never parsed by their line', len(unparsed))
print('all files', len(results), 'harness files', len(harness))
print('failures', {f: r for f, r in results.items() if r[1] != 0})
print('harness files unparsed by their line:', len([f for f in unparsed if f in harness]))
for f in unparsed:
    if f in harness: print(' ', results[f][0], results[f][1], f)
with tempfile.TemporaryDirectory() as d:
    good, bad = os.path.join(d, 'good.sh'), os.path.join(d, 'bad.sh')
    open(good, 'w').write('true\n'); open(bad, 'w').write('if true; then\n')
    print('control: bash -n good bad =', subprocess.run(['bash', '-n', good, bad], capture_output=True).returncode)
    print('control: bash -n bad =', subprocess.run(['bash', '-n', bad], capture_output=True).returncode)
    badb = os.path.join(d, 'bad.bats'); open(badb, 'w').write('@test "x" {\n  if true; then\n}\n')
    print('control: bats --count bad =', subprocess.run(['bats', '--count', badb], capture_output=True).returncode)
    print('control: bash -n valid bats =', subprocess.run(['bash', '-n', 'Tests/scripts/vm-settings-sequence.bats'], capture_output=True).returncode)
