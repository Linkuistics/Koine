# Predicate shared by the live VM checks and their recorded-evidence mutation controls.
def short_workflow($copy; $kind; $document):
  .answer.process as $p
  | ("/Users/admin/install-fx/" + $copy + "/Fixture.app") as $bundle
  | .answer.classification == "ok" and .answer.status == "AVAILABLE"
    and .answer.dependency == null and ((.answer.errors // []) | length == 0)
    and $p != null and .witness.pid == $p.pid and .witness.startedAt == $p.startedAt
    and .witness.bundle == $bundle
    and (.log | length) > 0 and all(.log[]; .label == $copy)
    and all(.log[]; .bundlePath == $bundle)
    and any(.log[]; .pid == $p.pid and .label == $copy)
    and ($kind != "open" or any(.log[]; .pid == $p.pid and .event == "open"
                                            and .path == $document));
