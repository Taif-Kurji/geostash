GeoStash
========

GeoStash: Delning av gömställen

GeoStash är en mobilapp designad för att låta användare logga in, skapa och hantera grupper samt dela platser på en karta. Appens syfte är att skapa en rolig och interaktiv upplevelse för att hitta och dela "gömställen" eller "skatter" som användare har lämnat. Användare kan se gömställena direkt på en karta och navigera till dem. Det är en modern digital skattjakt som lämpar sig för vänner, familjer eller communities som gillar utmaningar och äventyr.
Användargrupp



--------------
slut screncast ligger i /docs/slutcast
--------------

Betyg 4
Tekniska krav 

Provider för state (1p)

GPS-sensor (1p)

Forms + validering (2p)

Firebase-inloggning e‑post/lösenord (1p)

Google-inloggning (1p)

Kontohantering över tid (memberships/finds) (1p)

Realtidsuppdatering via Firestore-snapshots (1p)

Unit tests av två funktioner med >50% coverage (1p)

Entreprenöriella krav 
Firestore som databas (2p)

Google Maps meningsfullt (2p)

Dark mode (1p)

Multispråk (sv/en) (1p)

Köra projektet
--------------
Från `tdp028/myapp`:

flutter pub get
flutter run


Tester
------
Enhetstester för två hjälpfunktioner:
distanceBetweenPointsMeters i lib/utils/geo.dart
generateGroupCode` i `lib/utils/group_code.dart`

Testfiler:
test/geo_test.dart
test/group_code_test.dart

Kör tester med coverage (från `tdp028/myapp`):

flutter test --coverage test/geo_test.dart test/group_code_test.dart


Coverage:
lib/utils/geo.dart: 100%
lib/utils/group_code.dart: 66.7%

