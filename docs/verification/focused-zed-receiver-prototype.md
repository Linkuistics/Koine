# Opening a deeply nested file in Zed: what we learned

**Zed successfully read both test files, including the one with a 1,500-byte
path.** We achieved that by giving macOS a short address for the same file.
This is a useful result: it shows that this particular workaround can get the
long-path file's contents into Zed. There are still problems to solve before
Koine could use it as a normal feature.

Let me walk through what we tried and why.

## The question we were testing

Earlier experiments showed that we could reach a deeply nested file ourselves,
but handing its long path to macOS's usual application-opening machinery failed.
Those are two different steps: Koine being able to read a file does not mean it
can ask Zed to open it.

This experiment tested a specific way around that handoff problem. macOS has a
special filesystem address that identifies a file using the storage volume's
number and the file's number. Such an address looks like
`/.vol/16777230/223952`. It is short even when the file lives far down a directory
tree.

The idea was to give macOS that short address and ask it to open the file in
Zed. We needed to find out whether Zed could actually read the file through
that route. Merely getting an “open request accepted” message would not answer
that question.

## What I did

I used one disposable macOS virtual machine, so this did not involve your real
documents or desktop. Inside it, I created two small text files in deeply nested
folders. One had a 900-byte path, and the other had a 1,500-byte path. These
lengths include all the folders and the filename; the files themselves contained
just one line of text. All path characters were ASCII, so each character used
one byte.

The 900-byte file was our control: a case below the boundary seen in the earlier
experiments. The 1,500-byte file was the long-path case we wanted to learn about.

Each file contained a different, unmistakable line. I also created a nearby
“decoy” file with different contents. Before opening anything, I checked that
the short address led to the original test file, not its decoy. The workaround
did not copy, move, rename or link the file; it gave us another address for the
same object already on disk.

I then asked macOS to open the control file in the installed copy of Zed. After
checking that result, I quit Zed and confirmed that it had gone away before
asking it to open the long-path file. That fresh start matters: it prevents
content left on screen by the first request from being mistaken for success
on the second. I also checked that the process owning each observed window was
running the exact Zed installation we had selected.

## What happened in Zed

Both requests opened a Zed window with the expected line of text visible.
However, Zed also displayed its **Unrecognized Project** dialog. Following the
specific permission you had already given, I chose **Stay in Restricted Mode**
once for each file. I did not grant project trust.

I then checked the actual editor buffer after the dialog was gone. Both files'
unique lines were clearly visible, and neither was the decoy's line. This is
why we can say that Zed read the files, rather than merely acknowledging an
open request or showing a filename.

| Test | What Zed showed after staying restricted |
| --- | --- |
| 900-byte path | The correct text, under the original filename |
| 1,500-byte path | The correct text, but under the file number `223952` |

You can see the long-path result in the
[editor screenshot](focused-zed-receiver/results/after-choice-1500.png).
The line `K155_TARGET_1500_ONLY` is the deliberately unique content of that
original file.

That filename difference is significant. Zed could read the long file, but it
displayed the number from the short address instead of recovering the original
filename. We have not tested saving, so this result tells us nothing about how
saving or later editing operations would behave.

After the two requests, I disposed of the virtual machine. The whole run,
including disposal, took about two and a half minutes. I preserved the logs and
screenshots, and checked that the earlier experiment's evidence was unchanged.

## What this means for Koine

We now have a concrete positive: **this short-address route let this version
of Zed read an existing file whose original path was 1,500 bytes long.** That
fills in a previously unanswered part of the investigation.

It does not yet give us a finished Koine solution. Three problems matter most
for understanding this result:

- **We changed the address handed to macOS.** The file stayed the same, but
  we submitted its special short address instead of its original pathname.
  The current production requirements still call for the original spelling.
- **Other macOS checks still failed for the long file.** In particular, our
  attempts to obtain its content type and determine whether it was an
  application returned errors. We could proceed in this experiment because
  we had created the harmless text file ourselves. Koine needs a reliable way
  to check arbitrary selected files before opening them.
- **We have not established that this special address is a dependable,
  supported basis for the product.** Seeing it work on this macOS build does
  not settle whether we can rely on it in future releases. The observed trust
  dialog and number-only filename also remain part of the result.

This experiment was deliberately limited to opening two files in Zed. It did
not test opening folders, revealing items in Finder, default applications,
launching an application installed under a long path, or saving. Those questions
remain open; this success does not answer them.

My recommendation is to carry this result into the next design step as evidence
that **the file-reading part of this workaround works in Zed on the tested
system**, while keeping the unresolved product requirements explicit. Accepting
that result would mean acknowledging what we observed. It would not mean
approving this workaround for production or giving permission for another test.

The next design step still has to turn that useful observation into a complete,
agreed solution. No new experiment has been started.

You accepted this report on 2026-10-06: “I've read the document. I agree.”
That agreement completes this prototype. The next design step will use the
observed Zed result and the remaining limitations described above.

If you want to inspect how these conclusions were checked, the
[technical evidence](focused-zed-receiver-technical-evidence.md) contains the
exact versions, file identities, errors, process checks and links to the raw
records. You do not need to work through it to assess the explanation above.
