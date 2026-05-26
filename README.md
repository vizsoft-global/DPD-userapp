# Musallam Delivery Partner (DPD Driver App)

Flutter companion app for the DPD admin panel. Drivers sign in with **driver code + 6-digit passcode** (issued in the admin panel).

## Prerequisites

- Flutter 3.11+
- Supabase project `ytfmsgckjatiserpgdbz` (same as admin panel)
- Edge Function `driver-passcode-login` deployed (see below)

## Configuration

```bash
flutter run -d chrome
```

Or pass keys explicitly:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ytfmsgckjatiserpgdbz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here
```

Copy the anon key from admin `.env.local` (`NEXT_PUBLIC_SUPABASE_ANON_KEY`).

## Passcode login

See [docs/PASSCODE_LOGIN.md](docs/PASSCODE_LOGIN.md).

## Add delivery

Drivers log deliveries from **Home → Add Delivery** or the **Deliveries** tab.

- Mandatory **Order ID**
- Optional proof photo → Cloudflare R2 via admin API (`presign` → `PUT` → `confirm`, proxy fallback)
- GPS + timestamp saved on submit (`driver_create_delivery` RPC)
- **Proximity gate:** Add Delivery is enabled only when within `driver_app_delivery_proximity_meters` (admin **Settings → Driver App**, default 500m) of the assigned zone boundary or an assigned restaurant. The server enforces the same rule (`delivery_out_of_range` if bypassed).

Requires Supabase migrations `20260609100000_driver_deliveries_app.sql` and `20260613110000_driver_delivery_proximity_gate.sql` in the admin repo.

```bash
flutter run \
  --dart-define=ADMIN_API_BASE_URL=https://dpdadmin.vercel.app
```

Ensure Vercel `DRIVER_APP_ORIGINS` includes your Flutter web origin for uploads.

Deploy the edge function from the admin repo:

```bash
cd "../dpd adminpannel/dpdadmin"
supabase functions deploy driver-passcode-login --project-ref ytfmsgckjatiserpgdbz
```

## Project structure

- `lib/features/splash` — 3s launch splash (`driver_app_splash_url` or bundled asset)
- `lib/features/maintenance` — Full-screen gate when driver maintenance mode is on
- `lib/core/branding` — Reads public `app_settings` (logo, title, hints, maintenance)
- `lib/features/auth` — Driver code + passcode login
- `lib/features/home` — Dashboard UI
- `lib/features/shell` — Bottom navigation (5 tabs)

## Driver app settings (admin)

Configured in the admin panel under **Settings → Driver App** (and login hint under **Settings → Branding**). The app reads row `app_settings.id = 1` at startup:

| Column | Use in app |
|--------|------------|
| `driver_app_title` | App title |
| `driver_app_logo_url` | Login & profile logo |
| `driver_app_splash_url` | Launch splash (fallback: `assets/images/splash.png`) |
| `driver_app_maintenance_mode` | Blocks app when true |
| `driver_app_maintenance_message` | Maintenance screen copy |
| `driver_app_login_hint` | Login helper text |
| `driver_app_delivery_proximity_meters` | Max meters outside zone boundary / from assigned restaurant to allow Add Delivery (`0` = disabled) |
| `app_subtitle` | Login / profile subtitle |

See handoff doc §9: `../dpd adminpannel/dpdadmin/docs/DRIVER_APP_HANDOFF.md`.

## Database

- Login: RPC `driver_app_lookup_by_passcode` + Edge Function `driver-passcode-login`
- Profile: `profiles` (`role = rider`), `drivers` (`driver_code`, `app_passcode`)
- Staff accounts (`role = staff`) cannot use this app
- Security audit events: apply `docs/20260525_driver_security_events.sql` in the
  admin Supabase project (table `driver_security_events` + RPC
  `driver_log_security_event`)

## Security hardening (driver app)

- Android secure-screen flag blocks screenshots/screen recordings while signed in
- Capture attempts are logged to `driver_security_events` (where supported)
- Developer mode checks are logged and surfaced with warning dialogs
- Mock GPS blocks sensitive actions (delivery location resolve + duty location push)
- Security events queue offline and sync automatically when connectivity returns

## Related

- Admin panel: `../dpd adminpannel/dpdadmin`
- Handoff doc: `../dpd adminpannel/dpdadmin/docs/DRIVER_APP_HANDOFF.md`
