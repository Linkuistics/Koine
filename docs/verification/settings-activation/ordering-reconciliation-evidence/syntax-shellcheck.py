import glob, re, subprocess, tempfile, os
lines = open('Taskfile.yml').read().splitlines()
task=None; bn={}; sc={}
for l in lines:
    m=re.match(r'^  ([a-zA-Z0-9:_-]+):\s*$', l)
    if m: task=m.group(1)
    for key,store in (('bash -n',bn),('shellcheck',sc)):
        m=re.match(r'^\s+- '+key+r' (.+)$', l)
        if m:
            fs=[]
            for a in m.group(1).split():
                if a.startswith('-'): continue
                fs += sorted(glob.glob(a)) if '*' in a else [a]
            store.setdefault(task,[]).append(fs)
missing=[]; n=0
for t,groups in bn.items():
    covered={f for g in sc.get(t,[]) for f in g}
    for g in groups:
        for f in g[1:]:
            if re.match(r'(scripts/vm-|Tests/scripts/vm-)',f):
                n+=1
                if f not in covered: missing.append((t,f))
print('harness task-file pairs unparsed by bash -n:',n,'missing from the same task shellcheck:',missing)
with tempfile.TemporaryDirectory() as d:
    p=os.path.join(d,'bad.sh'); open(p,'w').write('#!/bin/bash\nif true; then\n')
    print('control: shellcheck on a syntax error =',subprocess.run(['shellcheck',p],capture_output=True).returncode)
    q=os.path.join(d,'bad.bats'); open(q,'w').write('#!/usr/bin/env bats\n@test "x" {\n  if true; then\n}\n')
    print('control: shellcheck on a broken bats file =',subprocess.run(['shellcheck',q],capture_output=True).returncode)
