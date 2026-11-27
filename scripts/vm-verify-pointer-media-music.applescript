-- Runs inside the VM, started by scripts/vm-verify-pointer-media.sh: the witness of the player and of the output
-- volume, independent of Koine. Each command prints one JSON object on one line.
--
-- usage: osascript vm-verify-pointer-media-music.applescript setup <folder>   the playlist "Koine Silence" of the
--                                                                              three tracks in <folder>, playing
--        osascript vm-verify-pointer-media-music.applescript state            Music's player state and track
--        osascript vm-verify-pointer-media-music.applescript volume           the output volume and its mute
--        osascript vm-verify-pointer-media-music.applescript set-volume <n>   the output volume set to n, unmuted
--        osascript vm-verify-pointer-media-music.applescript set-position <s> the player position set to s seconds
--
-- `setup` and `state` ask Music through Apple events, so the first of them in a clone needs the Automation consent
-- of the process that runs osascript. `volume` and `set-volume` use Standard Additions and ask no application.

on run argv
	set command to item 1 of argv
	if command is "setup" then
		set theFolder to item 2 of argv
		tell application "Music"
			set shuffle enabled to false
			set song repeat to off
			if not (exists user playlist "Koine Silence") then make new user playlist with properties {name:"Koine Silence"}
			repeat with n from 1 to 3
				add (POSIX file (theFolder & "/Koine Silence " & n & ".m4a")) to user playlist "Koine Silence"
			end repeat
			play user playlist "Koine Silence"
		end tell
		return my playerState()
	else if command is "state" then
		return my playerState()
	else if command is "set-position" then
		tell application "Music" to set player position to ((item 2 of argv) as integer)
		return my playerState()
	else if command is "volume" then
		return my volumeState()
	else if command is "set-volume" then
		set volume output volume ((item 2 of argv) as integer) without output muted
		return my volumeState()
	end if
	error "unknown command " & command
end run

on playerState()
	tell application "Music"
		set theState to player state as text
		set theTitle to ""
		set thePosition to -1
		set theCount to 0
		try
			set theTitle to name of current track
			set thePosition to player position
		end try
		try
			set theCount to count of tracks of user playlist "Koine Silence"
		end try
	end tell
	return "{\"state\":\"" & theState & "\",\"track\":\"" & theTitle & "\",\"position\":" & my wholeNumber(thePosition) & ",\"playlistTracks\":" & theCount & "}"
end playerState

on volumeState()
	set theSettings to get volume settings
	return "{\"outputVolume\":" & (output volume of theSettings) & ",\"outputMuted\":" & (output muted of theSettings) & "}"
end volumeState

-- A real as JSON: whole points are enough for the witness, and AppleScript can print a real in a form JSON refuses.
on wholeNumber(theValue)
	return ((round theValue rounding down) as integer) as text
end wholeNumber
