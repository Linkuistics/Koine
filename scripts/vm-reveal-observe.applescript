-- Runs IN THE GUEST, by the test agent (never by Koine): Finder's own account of what it shows.
-- One line per fact, tab separated, for scripts/vm-verify-reveal-path.sh to read:
--   WINDOWS <count of Finder windows>
--   TARGET  <POSIX path of the front window's folder>
--   TITLE   <the front window's name>
--   SELECTED <POSIX path> <kind> <name>   one per selected item (the path is the system's alias
--             coercion of the item, which resolves a symlink to its target; the name does not)
-- A read only: it changes nothing, so it is safe to repeat.
on run
	set tab_ to ASCII character 9
	set out to ""
	tell application "Finder"
		set n to count of Finder windows
		set out to out & "WINDOWS" & tab_ & n & linefeed
		if n > 0 then
			try
				set out to out & "TARGET" & tab_ & (POSIX path of (target of front Finder window as alias)) & linefeed
			end try
			set out to out & "TITLE" & tab_ & (name of front Finder window) & linefeed
		end if
		set sel to selection
		repeat with i in sel
			set itm to contents of i
			set out to out & "SELECTED" & tab_ & (POSIX path of (itm as alias)) & tab_ & (kind of itm) & tab_ & (name of itm) & linefeed
		end repeat
	end tell
	return out
end run
