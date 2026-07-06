# Coding Standards

## React Dashboard (TypeScript)

### Module Pattern

Each domain follows this structure:
```
src/<domain>/
├── <domain>.service.ts     ← All Supabase queries (no UI)
├── <domain>.types.ts       ← TypeScript interfaces/types
├── <domain>.context.tsx    ← React context (if global state needed)
├── <domain>.hook.ts        ← Custom hooks that use the service
└── pages/<domain>.tsx      ← Route-level component (in src/pages/)
```

### Service Layer Rules

- **No direct Supabase calls from components** — always through service files
- Services throw errors; components/hooks catch them
- Services return typed domain objects (camelCase), never raw DB rows (snake_case)
- Use `db.mappers.ts` for DB ↔ app type conversion

### Naming

- **Files**: `kebab-case.ts` for utilities, `domain.service.ts`, `domain.types.ts`
- **Types/Interfaces**: PascalCase — `OrderDetails`, `StaffMember`
- **Functions**: camelCase — `getOrderById`, `assignStaff`
- **DB columns**: snake_case in SQL, converted to camelCase in app via mappers
- **Constants**: UPPER_SNAKE_CASE for true constants, camelCase for objects

### Error Handling

```typescript
// Service: throw
async function getOrders(companyId: string): Promise<Order[]> {
  const { data, error } = await supabase.from('orders').select('*')
  if (error) throw error
  return data.map(mapDbOrderToOrder)
}

// Hook/Context: catch and expose error string
const [error, setError] = useState<string | null>(null)
try {
  const orders = await ordersService.getOrders(companyId)
} catch (e) {
  setError(e instanceof Error ? e.message : 'Unknown error')
}
```

### DB Mappers Pattern

`src/types/db.mappers.ts` provides:
```typescript
snakeToCamel(str: string): string
camelToSnake(str: string): string
mapDbOrderToOrder(dbOrder: DbOrder): Order
mapOrderToDb(order: Order): DbOrder
```

Always convert at the service boundary — components never see snake_case.

### Auth Pattern

```typescript
// Wrap protected routes with auth check
const { user, session } = useAuth()
const { company } = useCompany()
```

### Async Style

- `async/await` throughout — no `.then()` chains
- Parallel fetches: `Promise.all([...])` or `Promise.allSettled([...])`

### Phone Handling

Always use `phone.util.ts`:
```typescript
normalizePhone(phone: string): string  // → +91XXXXXXXXXX
formatPhoneForDisplay(phone: string): string
```

---

## Flutter Apps (Dart)

### Module Pattern

Each domain follows:
```
lib/<domain>/
├── <domain>_service.dart    ← All Supabase calls
├── <domain>_provider.dart   ← ChangeNotifier state
├── models/
│   └── <model>.dart         ← Data classes with fromJson/toJson
└── screens/
    └── <screen>_screen.dart  ← UI only
```

### Provider Pattern

```dart
class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  // Only getters exposed
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _orderService.getOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Service Layer Rules

- No Supabase calls in widgets
- Services are injected or instantiated in providers
- Services return typed model objects (fromJson on Supabase response)

### Naming (Dart)

- **Files**: `snake_case.dart`
- **Classes**: PascalCase — `OrderService`, `AssignedJob`
- **Variables/methods**: camelCase — `orderId`, `loadJobs()`
- **Constants**: `lowerCamelCase` (Dart convention)

### Phone Handling (Mechanic App)

`lib/core/utils/phone_util.dart`:
```dart
normalizePhone(String phone)  // → 91XXXXXXXXXX (no + for email format)
```

### Image Upload

- Max dimensions: 1920×1080
- Quality: 85% JPEG
- Pick via `image_picker` package, upload to appropriate Supabase bucket

### Offline Pattern (Mechanic App Only)

```dart
if (await _connectivityService.isOnline()) {
  await _executeDirectly();
} else {
  await _syncService.enqueue(SyncQueueItem(
    type: SyncOperationType.updateStatus,
    payload: {...},
  ));
}
```

### GoRouter Pattern

Routes defined in `config/app_router.dart`. Guards via `redirect` callback checking auth state.

---

## SQL Conventions

- snake_case everywhere
- UUID v4 primary keys (`gen_random_uuid()`)
- All tables: `created_at TIMESTAMPTZ DEFAULT now()`, `updated_at TIMESTAMPTZ` with trigger
- Enums for constrained string values (not CHECK constraints)
- SECURITY DEFINER functions for anything that needs to bypass RLS
- Partial indexes for business constraints (e.g., one active assignment per order)
- Views for complex joins used repeatedly

## Migrations

- File naming: `NNN_description.sql` (zero-padded 3 digits)
- Idempotent where possible (`CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`)
- Never drop or destructively alter without a corresponding down-migration comment
- New RLS policies: never use `WITH CHECK (true)` — always scope to company

## Commit Style

No enforced convention observed in git log. Use descriptive imperative sentences:
```
added functionality fixes
made dashboard changes
fixed ci/cd pipeline error
```
