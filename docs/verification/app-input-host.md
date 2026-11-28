# App input: the scheduled check on Antony's Mac

This record is the host check of app input. A VM cannot run Dia or Telegram
past their accounts. So the signed Koine 0.7.0 candidate sent one chord to
each on Antony's Mac. It ran at the time that he set, with the procedure and
the chords that he approved.

**Both apps acted on their chord.** Dia opened a new tab after New Tab,
Command-T. Telegram opened its search after Search in Chat, Command-F. Koine
reported `SENT` for each chord, and each app stayed the front app. Antony read
both effects on his screen, and he undid both by hand.

**The Mac is as the check found it.** The Koine data directory is identical to
its state before the check, file by file. The temporary grant is gone. The
candidate is no longer registered with Launch Services. The installed Koine
0.6.0 is unchanged, and it stays closed, as it was before the check. iTerm is
in front again.

The check proves route A for Chromium, in Dia, and for Qt, in Telegram. It
proves no configured row of these apps. The VM record is
[app-input-vm.md](app-input-vm.md).

## Procedure

```sh
KOINE_HOST_CHECK=approved task app:host-check-app-input -- <phase>   # scripts/host-check-app-input.sh
```

Each phase refuses unless `KOINE_HOST_CHECK=approved`. Antony acts between
the phases.

1. **record** reads the installed Koine, the candidate, the front app, Dia and
   Telegram. It changes nothing.
2. Antony quits the installed Koine, if it runs.
3. **backup** writes a SHA-256 manifest of the Koine data directory, and it
   copies the directory beside itself.
4. **launch** opens the candidate from `.build/app/Koine.app`. The candidate
   has the identifier and Team ID of the installed Koine. So the Accessibility
   consent of the installed Koine covers it.
5. **enrol** requests a grant for `input:read` and `input:control`. Antony
   approves it in the candidate's Settings window.
6. **send dia** and **send telegram** bring each app to the front. Target
   capture must name that app. Then the candidate sends the chord once.
   Antony reads the effect, and he undoes it by hand.
7. **front** brings the first front app to the front again.
8. Antony quits the candidate.
9. **restore** puts the copy back into the data directory, and the manifest
   must match. It deletes the copy and unregisters the candidate from Launch
   Services. It opens the installed Koine only if that Koine was running before.

The witness is Antony. The process of this session holds no Accessibility and
no screen capture access. So no tool here could read Dia or Telegram without a
new permission. `lsappinfo` names the front app with no permission. Koine's
receipt says only that Koine sent the chord.

A chord from Koine does not undo an effect. If the new tab had not opened,
Command-W would close one of Antony's own tabs.

## Run of 28 November 2026

The check ran from 19:09 to 19:13 on macOS 27.2.1 (26B131). The candidate
carried CDHash `3f720b4d332631adfbdd5f0f27f6ecacff09dd16`, the bundle that the
accepted VM run used. Its version still reads 0.6.0, because the release leaf
sets 0.7.0. The installed Koine was 0.6.0, with CDHash
`92f25cc9dfeff4870904b3db32faeb95159571a7`, and it was not running. The
transcript is
[host-check-20261128.log](app-input-host/host-check-20261128.log).

| Step | Observation |
| --- | --- |
| Before the check | The installed Koine was not running. iTerm was in front. Dia ran as pid 14271, and Telegram as pid 94193. |
| Copy | The data directory held 36 files. The copy matched the manifest. |
| Candidate | The candidate opened and wrote its endpoint. |
| Grant | Antony approved `k6-host-check`, with the comparison code 5DKQ-GECT. The grant held `input:control` and `input:read`. |
| Dia | Target capture named Dia, `company.thebrowser.dia`, pid 14271, `ADDRESSABLE`. Koine reported `SENT` for Command-T. Dia stayed in front. Antony: "yes, it brought up a new tab". |
| Telegram | Target capture named Telegram, `com.tdesktop.Telegram`, pid 94193, `ADDRESSABLE`. Koine reported `SENT` for Command-F. Telegram stayed in front. Antony: "yes, it opened the search. I closed the search and the new dia tab". |
| Front app | iTerm came to the front again. |
| Restore | The candidate had changed `grants.sqlite`, and it had staged its desktop, input and workspace bundles. After the restore, the manifest matched the record. |

The restore phase stopped after its manifest matched. Koine makes its provider
staging read-only, so `rm -rf` of the copy failed, and the phase did not reach
Launch Services. That `rm -rf` had already deleted `grants.sqlite` from the
copy, so a rerun of the phase refused the incomplete copy. The data directory
was already exact. So the remaining steps ran by hand at 19:13:40, as the
transcript shows:

- The manifest of the data directory matched the record again.
- `chmod -R u+w` and `rm -rf` deleted the copy.
- `lsregister -u` unregistered the candidate, and `lsregister -f` registered
  `/Applications/Koine.app` again.
- Neither Koine was running, and iTerm was in front.

The script now makes the copy writable before it deletes it.

## What this does not claim

- **The rows of Dia and Telegram.** One chord each proves the route for the
  toolkit. The rows of Dia wait with issue #7. The rows of Telegram belong to
  the account-dependent item of the roadmap.
- **An app in the background.** Each app was in front, as in the VM run. The VM
  run sent a chord to Safari in the background.
- **An automated witness.** Antony read both effects. No tool read them.
- **The notarised bundle.** The candidate is the signed bundle that `task app`
  builds. The release checks of 0.7.0 run on the notarised build.
