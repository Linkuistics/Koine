include "application-location-observations";
# Accept only established physical native values, never command status or alias text.
def registered_order($bytesExpected; $copy; $order):
  .nativeSelectionBefore.listed as $listed
  | ("/Users/admin/install-fx/" + $copy + "/Fixture.app") as $short
  | [$listed | to_entries[] | select(.value.expandedBytes == $bytesExpected
       and .value.knownPhysicalPath != null and .value.identifier == "dev.koine.test.InstallationFixture") | .key] as $long
  | [$listed | to_entries[] | select(.value.knownPhysicalPath == $short) | .key] as $selected
  | ($long | length) > 0 and ($selected | length) == 1
    and (if $order == "before" then any($long[]; . < $selected[0])
         else any($long[]; . > $selected[0]) end);
def preferred_long($bytesExpected):
  .nativeSelectionBefore.preferred
  | .knownPhysicalPath != null and .expandedBytes == $bytesExpected
    and .identifier == "dev.koine.test.InstallationFixture";
def preferred_short($copy):
  .nativeSelectionBefore.preferred.knownPhysicalPath == ("/Users/admin/install-fx/" + $copy + "/Fixture.app");
def running_short($process):
  ($process != null) and (.before | type == "array") and (.procsBefore | type == "array")
    and (.procsBefore | length > 0)
    and any(.before[]; .pid == $process.pid and .startedAt == $process.startedAt
      and .bundle == "/Users/admin/install-fx/A/Fixture.app");
def discovered_refusal($bytesExpected; $kind):
  .nativeSelectionBefore.preferred as $preferred
  | (if $preferred.bytes >= 1024 then "the application path as written"
     else ($preferred.expansions | to_entries | map(select(.value.bytes >= 1024)) | first) as $expansion
       | if $expansion != null then "the remaining application path after symbolic link " + (($expansion.key + 1) | tostring)
         else "the resolved application path" end end) as $spelling
  | (if $preferred.bytes >= 1024 then $preferred.bytes
     else ($preferred.expansions | map(select(.bytes >= 1024)) | first | .bytes) // $preferred.expandedBytes end) as $count
  | (if $kind == "launch" then "launched" else "opened" end) as $action
  | (if $kind == "launch" then "workspaceLaunchApplication" else "workspaceOpenPath" end) as $root
  | ("The application hand-off was refused: " + $spelling + " is " + ($count | tostring)
      + " bytes, and a path of 1024 bytes or more cannot be handed to an application (1023 is the most, not counting the terminating NUL). No request was made, so nothing was "
      + $action + ".") as $guidance
  | preferred_long($bytesExpected) and .answer.classification == "failed"
    and .answer.dependency == null and .answer.process == null
    and .answer.application.applicationPath == null
    and ((.answer.errors // []) | length == 1)
    and all(.answer.errors[]; .kind == "failed" and .path == [$root] and .message == $guidance)
    and (.log | type == "array") and (.log | length == 0)
    and (.before | type == "array") and (.after | type == "array")
    and (.procsBefore | type == "array") and (.procsAfter | type == "array")
    and .before == .after and .procsBefore == .procsAfter;
