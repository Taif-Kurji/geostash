GeoStash
========

GeoStash är en mobilapp byggd i Flutter där användare kan logga in, skapa/gå med i grupper och lägga ut gömställen på en karta. Backend är Firebase (Auth + Firestore). Appen stöder realtidsuppdateringar, GPS, Google Maps, mörkt läge och flerspråk (sv/en).

Huvudfunktioner
---------------
- Auth: e‑post/lösenord och Google-inloggning.
- Grupper: skapa grupp, få join-kod, gå med via kod.
- Karta: skapa cache (titel+beskrivning), markera/ångra hittad, ta bort (ägare), visa/dölj hittade. GPS för centrering/avstånd.
- Profil: statistik på skapade och hittade cacher.
- Inställningar: tema (ljust/mörkt), språk (sv/en) sparas lokalt.

Tech och struktur
-----------------
- Flutter med Provider (ChangeNotifier) för state.
- Firestore collections: `groups`, `memberships` (doc `{groupId}_{userId}`), `caches`, `finds` (doc `{cacheId}_{userId}`).
- Viktiga filer:
  - `lib/main.dart` – start, MultiProvider, theme/locale.
  - `lib/auth_page.dart`, `lib/data/auth_model.dart` – authflöde.
  - `lib/groups_page.dart`, `lib/data/group_model.dart` – grupper.
  - `lib/map_page.dart`, `lib/data/cache_model.dart`, `lib/data/find_model.dart` – karta och cacher.
  - `lib/settings_page.dart`, `lib/data/settings_model.dart` – tema/språk (SharedPreferences).
  - `lib/utils/geo.dart` – avståndsberäkning (distanceBetweenPointsMeters).
  - `lib/utils/group_code.dart` – generering av join-koder.

Köra projektet
--------------
Från `tdp028/myapp`:
```
flutter pub get
flutter run
```

Tester
------
Enhetstester för två hjälpfunktioner:
- `distanceBetweenPointsMeters` i `lib/utils/geo.dart`
- `generateGroupCode` i `lib/utils/group_code.dart`

Testfiler:
- `test/geo_test.dart`
- `test/group_code_test.dart`

Kör tester med coverage (från `tdp028/myapp`):
```
flutter test --coverage test/geo_test.dart test/group_code_test.dart
```

Coverage (senaste körning):
- `lib/utils/geo.dart`: 100%
- `lib/utils/group_code.dart`: 66.7%
*** End Patch
