# Dependencies

## React Dashboard (`spanr-mechanic/`)

### Runtime Dependencies

| Package | Version | Purpose |
|---|---|---|
| `react` | 19.x | UI framework |
| `react-dom` | 19.x | DOM rendering |
| `react-router-dom` | 7.x | Client-side routing |
| `@supabase/supabase-js` | latest | Supabase client |
| `@mantine/core` | 8.x | UI component library |
| `@mantine/hooks` | 8.x | Mantine utility hooks |
| `@mantine/form` | 8.x | Form management |
| `@mantine/notifications` | 8.x | Toast notifications |
| `@mantine/dropzone` | 8.x | File upload dropzone |
| `@mantine/dates` | 8.x | Date picker components |
| `@tabler/icons-react` | latest | Icon set |
| `tailwindcss` | 4.x | Utility CSS |

### Dev Dependencies

| Package | Purpose |
|---|---|
| `vite` (rolldown-vite 7.1.14) | Build tool |
| `typescript` | 5.9.x |
| `@vitejs/plugin-react` | Vite React plugin |
| `eslint` | Linting |
| `firebase-tools` | Firebase deploy CLI |

---

## Flutter User App (`spanr_app/pubspec.yaml`)

| Package | Purpose |
|---|---|
| `supabase_flutter` | Supabase client |
| `go_router` | Navigation |
| `provider` | State management |
| `razorpay_flutter` | Payment SDK |
| `google_maps_flutter` | Map display |
| `geolocator` | GPS coordinates |
| `geocoding` | Reverse geocoding |
| `google_sign_in` | Google OAuth |
| `image_picker` | Camera/gallery |
| `cached_network_image` | Image caching |
| `flutter_dotenv` | Env variable loading |
| `intl` | Internationalization/formatting |
| `uuid` | UUID generation |
| `path_provider` | File system paths |
| `shared_preferences` | Local key-value storage |

---

## Flutter Mechanic App (`spanr-mechanic-app/pubspec.yaml`)

| Package | Purpose |
|---|---|
| `supabase_flutter` | Supabase client |
| `go_router` | Navigation |
| `provider` | State management |
| `hive` | Offline queue storage |
| `hive_flutter` | Hive Flutter adapter |
| `connectivity_plus` | Network status detection |
| `image_picker` | Camera/gallery |
| `lottie` | Animation files |
| `cached_network_image` | Image caching |
| `intl` | Date/number formatting |
| `path_provider` | File paths |

---

## External Services

| Service | Used By | Purpose |
|---|---|---|
| Supabase | All apps | Database, Auth, Storage, Realtime, Edge Functions |
| Razorpay | User app + Edge Functions | Payment processing |
| Google Maps Platform | User app | Maps, geocoding |
| Firebase Hosting | CI/CD | Dashboard web hosting |
| GitHub Actions | CI/CD | Automated build + deploy |

---

## Version Constraints

- Flutter SDK: `^3.9.2`
- Dart SDK: `^3.9.2`
- Node.js: Not explicitly pinned (use LTS)
- TypeScript: `5.9.x`
