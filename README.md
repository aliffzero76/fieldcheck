# FieldCheck — Field Check-In App

A small Flutter app to check in at a location: take a photo, record GPS
coordinates, and save the record locally so it appears in a history list
and survives an app restart.

## How to run

1. Make sure Flutter is installed and set up (`flutter doctor` should pass).
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Connect a physical device (recommended, since camera/GPS behave best on
   real hardware) or start an emulator.
4. Run the app:
   ```bash
   flutter run
   ```

No code generation step is needed — the Hive model uses a hand-written
`TypeAdapter` (see `lib/models/check_in.dart`) instead of `build_runner`,
so `flutter pub get` is enough.

## Plugins used

| Purpose        | Plugin              |
|-----------------|----------------------|
| Camera          | `image_picker`       |
| GPS             | `geolocator`, `permission_handler` |
| Local storage   | `hive`, `hive_flutter`, `path_provider` |
| Formatting/IDs  | `intl`, `uuid`        |

## Project structure

```
lib/
  models/check_in.dart        # CheckIn data model + Hive adapter
  services/storage_service.dart  # Hive persistence wrapper
  services/location_service.dart # geolocator + permission handling
  widgets/check_in_card.dart     # history list row
  widgets/empty_state.dart       # empty state for Home
  widgets/photo_picker_field.dart # Take Photo button + preview
  widgets/location_field.dart     # Get Location button + result states
  screens/home_screen.dart        # Home / History
  screens/new_check_in_screen.dart # New Check-In form
  screens/detail_screen.dart       # Read-only detail view
  main.dart
```

## Requirements status

**Done**
- Three screens (Home/History, New Check-In, Detail) with navigation.
- Home shows thumbnail + note + timestamp per card, plus an empty state.
- New Check-In: note field with required validation, Take Photo with
  preview, Get Location with lat/lng/accuracy and a loading state, Save
  button.
- Detail screen is read-only, shows photo, note, lat/lng/accuracy, and
  created-at timestamp.
- Camera via `image_picker`, GPS via `geolocator`.
- Records persisted with Hive so they survive an app restart; photos are
  copied into the app's documents directory so they aren't lost when the
  OS clears temp files.
- Permission handling: camera and location failures are caught and shown
  as inline messages/snackbars — the app does not crash on denial.
- UI split into reusable widgets (`CheckInCard`, `EmptyState`,
  `PhotoPickerField`, `LocationField`) instead of one large `build()`.
- Delete a record from the Detail screen (small extra, not required but
  useful for testing).

**Not done / known limitations**
- No automated tests (unit/widget) included.
- No edit functionality for existing check-ins (Detail is read-only per
  the spec, so this was intentionally left out).
- Not tested on iOS hardware — iOS `Info.plist` permission strings are
  included but the flow was primarily verified on Android.
- No pagination/search on the History list (fine for a small local demo
  dataset).

## Screenshots / demo video

*(Add screenshots or a short screen recording here showing: taking a
photo, fetching GPS coordinates, and a saved check-in appearing in the
history list after an app restart.)*
