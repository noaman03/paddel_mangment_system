# Padelit 🎾

A padel court-booking platform built with Flutter, with three distinct
experiences behind one codebase: **players** who book courts and find games,
**club owners** who run the venues, and **administrators** who keep the
platform healthy.

Runs entirely offline against a seeded demo dataset — clone it, run it, and
every screen is populated and interactive.

<p align="center">
  <img src="screenshots/01-light-login.png" width="24%" alt="Sign in" />
  <img src="screenshots/08-light-tournaments.png" width="24%" alt="Tournaments" />
  <img src="screenshots/04-dark-courts.png" width="24%" alt="Court discovery in dark mode" />
  <img src="screenshots/19-light-owner-dashboard.png" width="24%" alt="Owner dashboard" />
</p>

**▶ [Watch the 2-minute demo reel](demo/padelit-demo.mp4)** — a full walkthrough
of all three roles in both themes.

---

## Demo accounts

The login screen lists all three and signs you in with a single tap; these are
the credentials behind them.

| Role | Email | Password |
| --- | --- | --- |
| Player | `ahmed@email.com` | `AMZ 123 mh` |
| Administrator | `admin@email.com` | `admin123` |
| Court owner | `owner` | `owner` |

On the web build you can also deep-link straight into a panel with
`?demo=player`, `?demo=admin` or `?demo=owner`.

---

## What it does

### Player

- **Court discovery** — search, filter by price / court type / facilities,
  browse by area, or sort by distance. Location is optional: pick a starting
  area and distance sorting works without granting a device permission.
- **Booking** — pick a day and an hour from the availability grid, confirm, and
  pay through the checkout flow. Bookings appear in *My Reservations* and in the
  home carousel, where they can be rebooked or cancelled.
- **Open matches** — browse games that need players, join one (the roster and
  player count update immediately), or create your own with a validated form.
  Join requests to your own matches can be accepted or declined.
- **Tournaments** — browse official and player-run events, open a full
  breakdown of format, prizes, schedule and capacity, send an entry request, and
  organise your own. Entry requests to your tournaments are managed in-app.
- **Messages** — conversation list and threads with players and club owners.

### Court owner

- Dashboard with today's bookings, active courts, revenue and pending items.
- Court management — create and edit courts, manage photos, pricing, facilities
  and availability.
- Tournament management — create, edit, archive and manage registrations, with a
  full validated editor.

### Administrator

- Platform metrics, an operations queue with per-row actions, and directories
  for players, courts and bookings with CSV export.

---

## Engineering notes

The interesting parts, and why they are built the way they are.

**A real two-theme design system.** `ThemeData` supplies explicit light and dark
`ColorScheme`s plus ~25 component themes (card, dialog, drawer, dropdown,
slider, snackbar, bottom sheet, tab bar, list tile, date/time picker …), so
screens describe *structure* and the theme decides colour. On top of that,
`context.padel` exposes semantic tokens — `surface`, `textPrimary`, `border`,
`primarySoft`, `soft(color)`, `onSurfaceAccent(color)` — which is what keeps
status colours legible on both backgrounds instead of hardcoding white.
Appearance is switchable in-app (Light / Dark / Auto), not just via the OS.

**One feedback layer.** `AppFeedback` drives a root `ScaffoldMessenger` through a
global key, so controllers, sheets and dialogs all report success and failure the
same way. Modal sheets register their own messenger so toasts raised inside a
sheet draw above it rather than behind it. `showAppSheet` and
`AppFeedback.confirm` give every bottom sheet and confirmation the same
structure, theming and safe-area handling.

**Offline-first demo data.** There is no backend. Controllers seed realistic
Egyptian data and mutate it in place, so actions have visible consequences:
joining a tournament increments its participant count, adds it to *My
Tournaments* and flips the button to *Requested*. Firebase initialisation is
wrapped so an unreachable project can never block startup.

**State management.** GetX reactive controllers for feature state
(`TournamentsController`, `OpenMatchesController`, `CourtBrowseController` and
its sub-controllers for filters/areas/location/data), Riverpod for auth
providers, and `SessionController` as the single source of truth for who is
signed in and which panel they belong to.

**Tests.** `flutter test` covers the behaviour that matters: role → panel
routing, credential rejection, tournament and match join semantics (including
double-join and full-capacity paths), filter reset, and theme invariants such as
"dark input fill must contrast with dark body text" and "both themes supply an
explicit ColorScheme".

---

## Running it

Requires Flutter **3.44+** (Dart 3.12+).

```bash
flutter pub get
flutter run
```

Checks:

```bash
flutter analyze && flutter test
```

The web build needs one flag, because the icon-font subsetter fails on some
toolchains:

```bash
flutter build web --release --no-tree-shake-icons
```

---

## Regenerating the screenshots and the demo video

Both are produced by a scripted walkthrough rather than by hand, so they never
drift from the app.

```bash
python tool/demo/make_assets.py
```

That builds the web release, serves it, drives it with Playwright — enabling
Flutter's semantics tree so controls can be addressed by their accessible label
— captures all 46 stills across both themes, and renders `demo/padelit-demo.mp4`
with title cards and captions.

Requires `playwright` (`playwright install chromium`), `opencv-python`,
`pillow`, and `imageio-ffmpeg` for H.264 output.

---

## Project structure

```
lib/
├── core/
│   ├── const/            colours + semantic palette, sizes, images
│   ├── controllers/      session and theme controllers
│   ├── Service/          in-memory stores (reservations, chat), Firebase wrappers
│   ├── utils/
│   │   ├── feedback/     AppFeedback, showAppSheet
│   │   ├── theme/        ThemeData and per-component themes
│   │   ├── formatters/   currency, dates, phone numbers
│   │   └── helpers/      pricing, misc
│   └── widgets/          shared Player* components (card, header, tabs, chips…)
├── Features/
│   ├── auth/             login, signup flow, demo accounts
│   ├── players/          courts, court_details, open_matches, tournaments,
│   │                     checkout, reservations, chat
│   ├── owner/            dashboard, court_management, tournaments, data
│   └── admin/            admin panel and controller
├── Models/               court, booking, chat, user
├── Screens/home/         player shell (bottom nav + drawer)
└── main.dart
tool/demo/                screenshot + video capture pipeline
test/                     behaviour and theme tests
```

108 Dart files, `flutter analyze` clean.

---

## Screens

All 46 stills live in [`screenshots/`](screenshots/), named
`NN-<theme>-<screen>.png`, with captions in
[`screenshots/manifest.json`](screenshots/manifest.json).

| | Light | Dark |
| --- | --- | --- |
| Court discovery | ![](screenshots/04-light-courts.png) | ![](screenshots/04-dark-courts.png) |
| Tournament details | ![](screenshots/10-light-tournament-details.png) | ![](screenshots/10-dark-tournament-details.png) |
| Create a match | ![](screenshots/17-light-match-create.png) | ![](screenshots/17-dark-match-create.png) |
| Owner tournaments | ![](screenshots/21-light-owner-tournaments.png) | ![](screenshots/21-dark-owner-tournaments.png) |
| Admin panel | ![](screenshots/22-light-admin.png) | ![](screenshots/22-dark-admin.png) |

---

## Status

A portfolio project, not a production service. The data layer is deliberately
in-memory so the app is fully explorable without credentials or a backend;
Firebase wiring is present but every screen degrades gracefully without it.
