# Menu probe primary API inputs

Read on 2026-10-28 against Package.swift (Swift tools 6.2, macOS 26 minimum),
Apple Swift 6.4 and installed macOS 27 SDK. These are source contracts, not a
claim of target-guest availability or exact guest framework implementation.

- [NSMenu.highlightedItem](https://developer.apple.com/documentation/appkit/nsmenu/highlighteditem): actual currently highlighted item. Full Apple documentation JSON is retained as highlight-api.json.
- [NSEvent.addLocalMonitorForEvents](https://developer.apple.com/documentation/appkit/nsevent/addlocalmonitorforevents(matching:handler:)): receives event copies before dispatch; return the identical argument unchanged. Full JSON is monitor-api.json. No inspected contract proves these menu-tracking key events will reach this monitor or share object identity with currentEvent; finite route qualification must establish the declared positive evidence or fail.
- [RunLoop.Mode.eventTracking](https://developer.apple.com/documentation/foundation/runloop/mode/eventtracking): tracking-mode timer, rather than assuming a default-mode request handler runs while a menu tracks. Full JSON is event-tracking-api.json. Timer scheduling/deadline is not guaranteed; the host reads the nonce response once after the fixed wait, and unavailable delivery ends the slot.
- [NSApplication.currentEvent](https://developer.apple.com/documentation/appkit/nsapplication/currentevent): last retrieved event. The new criterion requires an independent direct-monitor observation after the served nonce plus exact event-object identity at callback. It never credits this getter alone.
- [NSEvent.keyCode](https://developer.apple.com/documentation/appkit/nsevent/keycode) and the installed public Carbon Events.h kVK_Return value 0x24 define the admitted Return key. keyDown type is the public NSEventTypeKeyDown value 10. Do not read eventNumber for keyboard events or use event characters. Numeric-keypad Enter (76), repeats and modifiers fail this route.

The native clock contracts remain in ../causal-evidence/api-sources.txt. No
synchronous SkyLight logging contract, private order-op semantics or universal
refusal coverage is established.

TestAnyware input move/key --help and schema input key/file exec were read
without a connection or guest operation. The installed input-action schema is
explicitly a stub, providing only schema_version and ok. The route retains
raw envelopes and exits; those establish transport only. A guessed
`schema input-action` returned SCHEMA_NOT_FOUND before the canonical
`schema input key` command succeeded. No input was sent during discovery.
