
# mobile_flutter_challenge

Summary
- Flutter app with a futuristic (cyberpunk/neon) UI that fetches products from `https://fakestoreapi.com/products`.
- Each product is shown in a stylized card with image, title, description (max 2 lines), price, a "BUY" button and a FAVORITE toggle (using `setState`).

What was done
- Dark neon UI with gradients, glowing borders and shadows.
- Simple product model: `id`, `title`, `description`, `price`, `image`.
- Data fetching using the `http` package and `FutureBuilder` with loading and error states.
- Favorites tracked with a `Set<int>` and updated via `setState()`.

Prerequisites
- Flutter (3.x) installed and available in `PATH`.
- Android Studio with Android SDK and an AVD configured for emulator use.
- Google Chrome installed for running the web version.

Run (Chrome)
1. Open PowerShell in the project root.
2. Install dependencies:

```powershell
flutter pub get
```

3. Run on Chrome:

```powershell
flutter run -d chrome
```

Run (Android Studio / Emulator or Physical Device)
1. Open the project folder in Android Studio.
2. Wait for indexing and dependency resolution (or run `flutter pub get`).
3. Start an AVD emulator or connect a physical device with USB debugging enabled.
4. Run the app from Android Studio (Run button) or via terminal:

```powershell
flutter pub get
flutter run -d <device_id>
```

Notes
- The API used is a public example (`fakestoreapi.com`). If network errors occur, use the "RETRY CONNECTION" button on the error screen.
- The only additional dependency is `http` (already listed in `pubspec.yaml`).
- Main application code is in `lib/main.dart` (single-file app as requested).

---

Main file: `lib/main.dart`

Lucas Martinez
December, 2025

