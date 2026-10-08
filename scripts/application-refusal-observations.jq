# Literal supplied-application refusal, paired with the original fixture observer record.
def supplied_refusal($bytes; $kind; $application):
  (if $kind == "launch" then "launched" else "opened" end) as $action
  | (if $kind == "launch" then "workspaceLaunchApplication" else "workspaceOpenPath" end) as $root
  | ("The application hand-off was refused: the application path as written is "
      + ($bytes | tostring) + " bytes, and a path of 1024 bytes or more cannot be handed to an application "
      + "(1023 is the most, not counting the terminating NUL). No request was made, so nothing was "
      + $action + ".") as $guidance
  | .answer.classification == "failed" and .answer.process == null and .answer.dependency == null
    and .answer.application.applicationPath == $application
    and ($application | utf8bytelength) == $bytes
    and ((.answer.errors // []) | length == 1)
    and all(.answer.errors[]; .kind == "failed" and .path == [$root] and .message == $guidance)
    and (.log | length == 0) and .before == .after and .procsBefore == .procsAfter;
