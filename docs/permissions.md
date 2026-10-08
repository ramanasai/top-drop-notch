# macOS permission matrix

**Policy (learned from Droppy, correct UX):** request **only when a feature needs it**, never at launch. Each permission has a Settings → Permissions entry that explains *why*, re-requests, and deep-links to the correct System Settings pane when denied. Document any new permission here in the same PR that needs it.

> Status: which milestone starts needing each permission. "Ask when" = the user-visible moment the prompt should appear.

| Permission | Framework / API | Needed for | Ask when | Milestone | Fallback if denied |
|---|---|---|---|---|---|
| **Automation** (AppleScript) | `NSAppleScript` / `osascript` per-app (`System Events`, Music, Spotify) | Now Playing metadata + transport controls (public path in [architecture §4](architecture.md)) | First time island tries to read playback while Music/Spotify running | **M2** | Island shows "Allow automation to control Music" hint + deep link to Settings → Privacy → Automation; no media UI |
| **Accessibility** | `AXIsProcessTrusted()`, AX API | Overlay interaction edge cases, global shortcut registration robustness, future: window snap, acting on other apps | On first feature that needs it (likely M5 shortcut recorder polish; not needed for basic panel) | M5 (revisit M1 if click-through requires it) | Features degrade individually; island itself still works (non-activating panel needs no AX) |
| **Screen Recording** | `CGWindowListCreateImage` / ScreenCaptureKit | *Later:* reading wallpaper pixels behind the surface for glass blending; screenshots/OCR (backlog) | First feature that samples screen pixels | Deferred (not M0–M6 core) | Opaque black shell (our v1 design doesn't need wallpaper sampling) |
| **Input Monitoring** | `CGEventTap` / `NSEvent.addGlobalMonitorForEvents` | Detecting drag-shake (M6+ tray summon), global key pass-through | When shake-to-summon ships | Backlog | Delay-based or hold-key tray summon instead |
| **System Audio Recording** | CoreAudio process taps | Per-app volume sliders, audio visualizer | When those ship | Backlog | Feature absent |
| **Microphone** | `AVCaptureDevice` / `AVAudioRecorder` | Voice transcription (if ever) | On use | Out of scope | — |
| **Bluetooth** | `IOBluetooth` / CoreBluetooth | Headphone battery live activity | On use | Backlog | No headphone battery chip |
| **Camera** | `AVCaptureDevice` | Camera-in-notch (if ever) | On use | Out of scope | — |
| **Calendar / Reminders** | EventKit | Calendar widgets (if ever) | On use | Out of scope | — |
| **Full Disk Access** | file reads outside sandbox | Never, if we keep to `~/Library/Application Support` + user-selected files | — | — | Use security-scoped bookmarks from user-granted drops |

## Design rules

1. **No permission prompt at launch.** Ever. (Possible exception: none currently.)
2. Every request is preceded by an in-app explanation (one sentence: what + why) — a raw system prompt without context reads as malware.
3. Denied ≠ dead: the requesting feature shows a persistent inline "needs permission — Fix" affordance; everything else keeps working.
4. Deep links: `x-apple.systempreferences:com.apple.preference.security?Privacy_<Pane>` for re-prompting.
5. Requests are idempotent — macOS hides repeated `AXIsProcessTrustedWithOptions` prompts after the first denial, so the Settings page is the real retry path.
6. **Private/fragile APIs** (MediaRemote especially) are not "permissions" but follow the same rule: opt-in + automatic fallback, never the only path ([ADR-0001](adr/0001-use-swift-swiftui-appkit.md)).
7. Privacy posture to preserve: clipboard and file data never leave the machine; no analytics; no network in core paths.

## Notarization note

Developer ID distribution (not Mac App Store) means no sandbox — file access is normal user-level. The App Store remains *possible later* only if we keep public APIs as the default paths; `CGEventTap`, MediaRemote, and global hotkeys are the things that would fight the sandbox. This is why the matrix above stays minimal.
