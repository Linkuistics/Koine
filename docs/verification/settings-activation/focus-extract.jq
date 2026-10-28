# Context only: no transaction, cross-clock or causal classification.
# Count all native records, including those omitted from the context extract.
"Filtering the log data using \"process IN {\"Koine\", \"WindowServer\", \"Dock\", \"TextEdit\", \"runningboardd\", \"loginwindow\", \"lsd\", \"coreservicesd\"}\"" as $header
| foreach inputs as $text ({line: 0, seen: 0, ended: false};
    .line += 1 | .output = null
    | if .ended then error("record after native completion")
      elif .line == 1 and $text == $header then
        .output = {sourceLine: .line, header: $text}
      else ($text | fromjson) as $record
      | if ($record | type) != "object" then error("expected native record object")
        elif $record.finished == 1 and ($record | keys) == ["count", "finished"] then
          if $record.count != .seen then error("invalid native completion count")
          else .ended = true | .output = {sourceLine: .line, record: $record} end
        elif ($record.eventMessage | type) != "string" then
          error("expected eventMessage string")
        else .seen += 1
        | if ($record.eventMessage | test("chain did update|[Ss]etFrontProcess|isActivationTokenActive|SetWindowHasKeyAppearance|[Rr]eleaseKeyFocus|LS/CAS: Changed front application")) then
            .output = {sourceLine: .line, record: $record}
          else . end
        end
      end;
    .output // empty
  )
