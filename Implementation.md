# Unimote — universal TV remote, Flutter build plan

## Executive summary

Unimote is a Flutter app (iOS + Android) that discovers TVs on the local network or via IR and controls them from one unified interface, regardless of brand. There is no single "TV protocol" — Samsung, LG, Sony, Vizio, Roku, Fire TV, and Android TV each speak a different, proprietary language. The whole design problem is building one clean abstraction on top of seven incompatible backends without the seams showing.

**Reality check before you start:**
- iOS has no IR hardware or API — WiFi-only control on iPhone.
- iOS 14+ requires an explicit Local Network permission prompt plus declared Bonjour service types; Android 12+/13+ has its own nearby-devices permission model. Both need to be handled in Phase 2 or discovery silently fails.
- Fire TV control over ADB requires the user to enable ADB debugging on the TV — it can't be fully zero-config, and it's Android-app-only (iOS can't shell to `adb`).
- Powering on a fully-off TV from most of these adapters isn't possible over the same channel — that's what Wake-on-LAN is for (called out as a cross-cutting feature below).

---

## Recommended tech stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter 3.x / Dart 3.x | Single codebase, native platform channel support for the Android-only IR path |
| State management | Riverpod 2 | Testable, no `BuildContext` coupling — matters a lot for background protocol services |
| Local storage | Isar or Hive | Fast NoSQL, works fully offline (no cloud dependency for core function) |
| Secure storage | `flutter_secure_storage` | Pairing tokens and certificates must never sit in plaintext storage |
| Networking | `dio` (REST), `web_socket_channel` (Tizen/webOS) | Standard, well-maintained |
| Discovery | Raw UDP via `dart:io RawDatagramSocket` for SSDP; `bonsoir` or `multicast_dns` for mDNS/Bonjour | No actively maintained pure-Dart SSDP package exists — budget time to hand-roll the M-SEARCH multicast query and response parser |
| Platform channel | `MethodChannel('unimote/ir')` → native Kotlin `ConsumerIrManager` | IR is Android-only and has no Flutter plugin worth trusting long-term; write it yourself |
| Cast/Android TV | Hand-rolled protobuf client over TLS, or evaluate `android_tv_remote`-style packages for maturity | Package ecosystem here changes often — verify current state before committing |
| Testing | `flutter_test`, `mocktail`, `integration_test` | Adapters must be mockable without real hardware in CI |
| CI/CD | GitHub Actions + Codemagic or Fastlane | Store deploys need signing automation from day one, not bolted on later |
| Crash/analytics | Sentry or Firebase Crashlytics | Field failures will mostly be protocol-specific — you need per-adapter crash grouping |
| Monetization (optional) | RevenueCat | Only if you're gating premium adapters/macros behind a paywall |

## Recommended repository structure

```
lib/
  core/               # constants, theming, error types, utils
  domain/
    entities/         # Device, RemoteCommand, Macro
    repositories/      # abstract repository interfaces
  data/
    discovery/
      ssdp_scanner.dart
      mdns_scanner.dart
      manual_entry.dart
    adapters/
      base_adapter.dart
      samsung_adapter.dart
      lg_adapter.dart
      roku_adapter.dart
      firetv_adapter.dart
      androidtv_adapter.dart
      vizio_adapter.dart
      sony_adapter.dart
      ir_adapter.dart
      mock_adapter.dart
    storage/
      device_repository_impl.dart
      macro_repository_impl.dart
  presentation/
    screens/           # discovery_screen, remote_screen, macro_builder_screen, settings_screen
    widgets/            # dpad, volume_slider, power_button, numeric_pad
    providers/          # Riverpod providers
  main.dart
```

---

## The 10 phases

### Phase 1 — Foundations & project scaffolding
**Goal:** a running skeleton with the abstractions the other nine phases depend on.

- Flutter project initialized with the clean-architecture folders above.
- Theming: dark mode as the default (remotes get used in dark rooms), design tokens for buttons/spacing.
- CI pipeline: lint + `flutter test` on every PR.
- Navigation (GoRouter) between Discovery / Remote / Macro Builder / Settings screens (placeholder UI is fine).
- Define the core abstraction everything else builds on:
  - `abstract class RemoteAdapter { connect(); disconnect(); sendKey(RemoteKey); sendText(String); launchApp(String); Stream<AdapterState> get state; }`
  - `enum RemoteKey { power, home, back, dpadUp, dpadDown, dpadLeft, dpadRight, select, volumeUp, volumeDown, mute, playPause, num0..num9, inputSource }`

**Definition of done:** app builds on both simulators, shows the four placeholder screens, CI is green.

### Phase 2 — Device discovery engine
**Goal:** find TVs on the network automatically, with manual fallback for the ones that won't announce themselves.

- SSDP/UPnP scanner: M-SEARCH multicast to `239.255.255.250:1900` — catches Samsung, LG, Sony (all DIAL-compliant).
- mDNS/Bonjour scanner (`bonsoir`/`multicast_dns`) — catches Chromecast, Android TV/Google Cast, and Roku (which also answers SSDP).
- Manual "add by IP" entry — required fallback for Fire TV, which commonly won't be auto-discoverable.
- Device fingerprinting: parse SSDP/mDNS response headers and TXT records to guess brand, then route to the matching adapter.
- iOS: request the Local Network permission and declare Bonjour service types in `Info.plist`, or discovery silently returns nothing.
- Android: handle the 12+/13+ nearby-devices runtime permission.
- UI: live-populating "scanning…" device list, manual-entry bottom sheet.

**Definition of done:** correctly discovers and classifies Samsung/LG/Roku/Chromecast-class devices on a real network.

### Phase 3 — Adapter framework & command abstraction
**Goal:** one command set, many backends, zero leakage of protocol details into the UI.

- Finalize `RemoteAdapter` + an `AdapterFactory` that maps a detected brand to the right adapter instance.
- Command mapper: universal `RemoteKey` → protocol-specific payload, one mapper per adapter.
- Adapter lifecycle state machine — `disconnected → pairing → connected → error` — exposed via a Riverpod `StateNotifier`.
- Retry/backoff policy for the inevitable flaky local-network connection.
- A `MockAdapter` so the UI can be built and tested with zero real hardware in the loop.

**Definition of done:** swapping which adapter is active requires zero UI code changes; the mock adapter fully drives the remote screen in dev builds.

### Phase 4 — Samsung (Tizen) & LG (webOS) adapters
**Goal:** the two biggest smart-TV platforms.

- **Samsung:** WebSocket to `wss://<tv-ip>:8002/api/v2/channels/samsung.remote.control?name=<base64 app name>`; handle the on-screen pairing approval, persist the returned token, send `KEY_*` commands as base64-encoded JSON.
- **LG:** WebSocket to `wss://<tv-ip>:3001` (or unencrypted `3000` on older sets); SSAP handshake with a permission manifest; persist the `client-key` returned after pairing; use `ssap://com.webos.service.ime/insertText` for text input.
- Both tokens go into `flutter_secure_storage`, never plain Hive/Isar.
- Maintain a real-device testing checklist — firmware quirks differ enough between model years to bite you here.

**Definition of done:** full dpad/volume/power-off control working against a real Samsung and a real LG TV. (Power-on needs Wake-on-LAN — see cross-cutting concerns below.)

### Phase 5 — Roku, Fire TV & Vizio adapters
**Goal:** streaming boxes plus Vizio's REST API.

- **Roku (ECP):** plain HTTP POST to `http://<tv-ip>:8060/keypress/<Key>` — no auth required. This is the easiest adapter and a good confidence-builder to do first in this phase.
- **Fire TV:** control via ADB-over-network (`adb connect <ip>:5555`), which requires the user to enable ADB debugging on the device. Since Flutter can't shell to `adb` on iOS, this path is Android-only; document the iOS limitation clearly in-app rather than silently failing.
- **Vizio SmartCast:** REST API on port 7345/9000; pairing requires a PIN shown on the TV, then bearer-token-authenticated key presses.

**Definition of done:** Roku fully working as the baseline; Fire TV working on Android with the iOS gap documented; Vizio pairing and control working.

### Phase 6 — Android TV/Google TV & Sony Bravia adapters
**Goal:** the remaining major platforms — budget extra time here, this is the least mature part of the Dart package ecosystem.

- **Android TV Remote Service protocol:** protobuf messages over TLS on port 6467, certificate-based pairing (a code is shown on-screen). Package maturity varies a lot — verify current state before committing to a dependency, and budget for hand-rolling the protobuf client if needed.
- **Google Cast** integration as a complementary media-control path (via a `cast` plugin).
- **Sony Bravia:** "Simple IP Control" (plaintext, port 20060) on older sets, or the newer REST "IRCC" API (port 80, pre-shared key) on current models.

**Definition of done:** Android TV pairing plus basic dpad control working; Sony basic key commands working.

### Phase 7 — IR blaster fallback & legacy TV support
**Goal:** non-smart TVs, Android only.

- Platform channel to native Kotlin `ConsumerIrManager` — check `hasIrEmitter()` first. Most flagships released after ~2017 dropped this hardware entirely, so gate the feature visibly rather than letting users hit a dead end.
- Bundle an IR codeset database (LIRC-style code sets), keyed by brand, mapped onto the universal `RemoteKey` set. Verify the licensing of whatever codeset source you use before shipping.
- Brand/model selection UI with a "does this work?" test flow (power/volume first), with manual code-set switching if the first guess is wrong.
- Clear messaging when the phone has no IR hardware, steering the user back to the WiFi-based adapters instead of leaving them stuck.

**Definition of done:** on an IR-capable Android phone, power/volume/channel work against a common legacy TV brand.

### Phase 8 — Unified remote UI, macros & extras
**Goal:** make it feel like one product, not seven adapters glued together.

- Polished remote screen: dpad, volume rocker, collapsible numeric keypad, text input for search fields, app-launch shortcuts where the protocol supports it (Roku/Android TV/Vizio can deep-launch apps).
- Macro builder — chain commands into one tap, e.g. "Movie night" = power on → wait 2s → switch input → launch app.
- Home-screen widget / quick-settings tile for power toggle.
- Nice-to-haves: haptic feedback per button press, a landscape "trackpad" mode that sends relative dpad events.
- Multi-device support: saved device list with quick-switch between TVs (bedroom/living room).

**Definition of done:** cold open → controlling a previously-paired TV in under 3 taps; at least one macro built and run successfully.

### Phase 9 — Reliability, security & performance hardening
**Goal:** the difference between a demo and a product people trust.

- Connection health monitoring with auto-reconnect and exponential backoff, per adapter.
- Command debouncing/queueing so a fast dpad-tapping user doesn't flood the TV with requests.
- Full secrets audit — confirm every token/certificate goes through secure storage, nothing sensitive leaks into plain local storage.
- A structured error taxonomy surfaced to the UI (network unreachable vs. auth expired vs. TV offline) with an actionable recovery step for each, not just a generic "something went wrong."
- Crash reporting and non-fatal error logging wired up.
- Accessibility pass: screen-reader labels on every remote button, 44×44pt minimum touch targets, a high-contrast theme option.
- Battery/network profiling — WebSocket keep-alives left unmanaged will drain battery noticeably.

**Definition of done:** the app survives a TV reboot, a WiFi drop, and backgrounding/foregrounding without requiring the user to manually reconnect in the common cases.

### Phase 10 — Testing, store submission & launch
**Goal:** ship it, and be able to tell when it breaks.

- Unit tests per adapter against mocked sockets/HTTP; widget tests for the remote screen and macro builder; integration tests for the full discovery → pair → control flow.
- Closed beta via TestFlight and Play Console internal/closed testing — recruit testers who own TV brands you don't personally have.
- Store listings: per-platform screenshots, a privacy policy covering local-network scanning (required disclosure on both stores), the Play Data Safety form, and the App Store privacy "nutrition label."
- Feature-flag the riskier adapters (Fire TV/ADB especially) so they can be disabled remotely if a firmware update breaks them without needing a full app release.
- Post-launch: a crash-dashboard triage cadence, protocol-break monitoring (manufacturers do push firmware updates that silently change auth flows), and a versioned changelog.

**Definition of done:** live on both stores, crash-free rate above 99.5% in the first two weeks, monitoring dashboards in place.

---

## Cross-cutting concerns (track these from Phase 1 onward, don't defer them)

- **Wake-on-LAN** for "power on from fully off" — none of the WebSocket/REST adapters can power on a TV that's fully off; you need the TV's MAC address (captured at pairing time) and a WoL packet sender as a shared utility.
- **Per-adapter timeout/retry tuning** — a Roku on the same subnet responds in milliseconds; a Samsung TV waking from standby can take several seconds. One global timeout will misfire somewhere.
- **Codeset licensing** — verify the license of whatever IR codeset database you bundle before shipping.
- **Protocol churn** — Samsung, LG, and Vizio have each changed their auth flows before in firmware updates. Keeping every adapter fully isolated behind the `RemoteAdapter` interface means a break in one doesn't ripple into the others.

## Effort estimate

Roughly 16–18 weeks for one senior mobile engineer covering full multi-protocol support end to end. Two ways to compress this:
- **Parallelize Phases 4–6** across engineers — the adapters are independent behind the shared interface from Phase 3, so this is the natural place to split work.
- **Ship narrower first** — Roku + Samsung + LG + IR alone covers a large majority of the installed base. Treat Fire TV/Vizio (Phase 5b) and Android TV/Sony (Phase 6) as a fast-follow release rather than blocking v1 on all seven adapters.