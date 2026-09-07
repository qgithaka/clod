# Clod POS – Complete Build Blueprint
**Version 1.0**  
**Target Platforms:** Windows (Desktop) + Android (Phone/Tablet)  
**Philosophy:** Offline-first • Single-user • Absolute simplicity • Credit-native • Digital documents only

This document is a practical, sequential guide. Follow the phases in order. Each phase builds on the previous one and produces a working increment of the application.

---

## 1. Recommended Tech Stack

| Layer              | Choice                          | Why |
|--------------------|---------------------------------|-----|
| Framework          | **Flutter 3.24+**               | Single codebase, true native Windows + Android, excellent performance, strong offline capabilities |
| Language           | Dart                            | — |
| Local Database     | **Drift** (type-safe SQLite)    | Compile-time safe queries, migrations, reactive streams, excellent Flutter integration |
| State Management   | **Riverpod 2.x**                | Simple, testable, scalable, works perfectly with Drift |
| Navigation         | **go_router**                   | Declarative, deep-link friendly, good for responsive layouts |
| PDF Generation     | **pdf** + **printing** packages | Clean PDF creation + sharing |
| Local File Storage | `path_provider` + `file_picker` | Backups and logo handling |
| Encryption         | `encrypt` + `pointycastle`      | Encrypt `.clodbackup` files |
| Google Drive Sync  | `googleapis` + `google_sign_in` | Optional encrypted cloud backup |
| UI Components      | Material 3 + custom theme       | High-contrast, fast, responsive |
| Icons              | `lucide_icons` or Material Icons| Clean and consistent |

**Why Flutter?**  
One codebase → Windows desktop + Android. Excellent offline story. Fast UI on low-end devices. Mature ecosystem for PDF, SQLite, and file handling.

**Alternative (if you prefer C#):** .NET MAUI + SQLite-net + CommunityToolkit. Maui is also viable, but Flutter currently has stronger cross-platform maturity for this use case.

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Presentation                     │
│  (Screens, Widgets, Responsive Layouts)             │
└─────────────────────┬───────────────────────────────┘
                      │ Riverpod Providers
┌─────────────────────▼───────────────────────────────┐
│                     Application                     │
│  (Use Cases / Services: SaleService, CreditService) │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                       Domain                        │
│  (Entities, Value Objects, Repository Interfaces)   │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                        Data                         │
│  (Drift Database, DAOs, Mappers, Backup Service)    │
└─────────────────────────────────────────────────────┘
```

**Key Principles**
- Everything is local-first. No network calls required for core operations.
- Single source of truth = Drift database.
- UI only talks to Riverpod providers / use-case services.
- All money values stored as integers (cents/smallest currency unit) to avoid floating-point issues.

---

## 3. Core Data Model (SQLite via Drift)

Design the schema first. Create these tables:

### 3.1 Business Profile
```sql
business_profile (
  id INTEGER PRIMARY KEY CHECK (id = 1),  -- singleton
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  logo_path TEXT,          -- local file path
  currency_code TEXT DEFAULT 'USD',
  currency_symbol TEXT DEFAULT '$',
  created_at INTEGER,
  updated_at INTEGER
)
```

### 3.2 Customers
```sql
customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  credit_limit INTEGER DEFAULT 0,   -- in cents
  notes TEXT,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
)
```

### 3.3 Catalogue – Products & Services
```sql
items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,              -- 'product' | 'service'
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT,                        -- optional
  buying_price INTEGER DEFAULT 0,  -- average cost in cents
  selling_price INTEGER NOT NULL,
  stock_quantity REAL DEFAULT 0,   -- only for products
  low_stock_threshold REAL DEFAULT 5,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
)
```

### 3.4 Sales & Cart
```sql
sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT UNIQUE,
  customer_id INTEGER REFERENCES customers(id),
  sale_date INTEGER NOT NULL,
  payment_method TEXT NOT NULL,   -- 'cash' | 'credit'
  subtotal INTEGER NOT NULL,
  discount INTEGER DEFAULT 0,
  total INTEGER NOT NULL,
  amount_paid INTEGER DEFAULT 0,   -- for partial payments later
  notes TEXT,
  created_at INTEGER
)

sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES items(id),
  item_name TEXT NOT NULL,         -- snapshot
  quantity REAL NOT NULL,
  unit_price INTEGER NOT NULL,
  line_total INTEGER NOT NULL,
  cost_at_sale INTEGER DEFAULT 0   -- for accurate COGS
)
```

### 3.5 Credit Ledger
```sql
credit_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER REFERENCES customers(id),
  type TEXT NOT NULL,              -- 'sale' | 'repayment' | 'adjustment'
  reference_id INTEGER,            -- sale_id or null
  amount INTEGER NOT NULL,         -- positive = increase debt, negative = reduce
  balance_after INTEGER NOT NULL,
  note TEXT,
  created_at INTEGER
)
```
(You can also maintain a denormalized `current_balance` on the customers table and update it transactionally.)

### 3.6 Purchases (Stock In)
```sql
purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_name TEXT,
  purchase_date INTEGER,
  status TEXT DEFAULT 'draft',     -- draft | ordered | received
  total_cost INTEGER,
  notes TEXT,
  created_at INTEGER
)

purchase_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id INTEGER REFERENCES purchases(id),
  item_id INTEGER REFERENCES items(id),
  quantity REAL,
  unit_cost INTEGER,
  line_total INTEGER
)
```

### 3.7 Stock Movements (Shrinkage / Adjustments)
```sql
stock_movements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id INTEGER REFERENCES items(id),
  type TEXT NOT NULL,              -- 'sale' | 'purchase' | 'damage' | 'expired' | 'lost' | 'adjustment'
  quantity_change REAL NOT NULL,  -- negative for out
  reason TEXT,
  reference_id INTEGER,
  created_at INTEGER
)
```

### 3.8 Expenses
```sql
expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,          -- Rent, Utilities, Transport, etc.
  amount INTEGER NOT NULL,
  expense_date INTEGER,
  note TEXT,
  created_at INTEGER
)
```

### 3.9 Documents (Quotes & Invoices)
```sql
documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,              -- 'quote' | 'invoice'
  number TEXT UNIQUE,
  customer_id INTEGER,
  status TEXT,                     -- draft | sent | accepted | paid | cancelled
  issue_date INTEGER,
  due_date INTEGER,
  valid_until INTEGER,             -- for quotes
  subtotal INTEGER,
  total INTEGER,
  notes TEXT,
  created_at INTEGER
)

document_items (similar to sale_items)
```

### 3.10 Settings & Backup Log
```sql
app_settings (
  key TEXT PRIMARY KEY,
  value TEXT
)

backup_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT,
  type TEXT,                       -- local | google_drive
  status TEXT,
  created_at INTEGER
)
```

**Important Implementation Notes**
- Use Drift’s `@DataClassName` and type converters for enums and money.
- Always perform stock + credit + sale inserts inside a single Drift transaction.
- Keep historical snapshots (item name, price, cost) on sale/document lines so reports remain accurate even if catalogue prices change later.

---

## 4. Project Structure (Flutter)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/               # money formatting, date helpers
│   └── errors/
├── data/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── daos/
│   ├── repositories/
│   └── services/            # BackupService, PdfService, DriveService
├── domain/
│   ├── entities/
│   ├── repositories/        # abstract interfaces
│   └── usecases/
├── presentation/
│   ├── providers/           # Riverpod
│   ├── screens/
│   │   ├── dashboard/
│   │   ├── pos/
│   │   ├── customers/
│   │   ├── catalogue/
│   │   ├── documents/
│   │   ├── reports/
│   │   ├── settings/
│   │   └── ...
│   ├── widgets/
│   └── router/
└── l10n/                    # optional localization later
```

---

## 5. Phased Development Plan

### Phase 0 – Project Setup
1. Create Flutter project with Windows + Android support.
2. Add dependencies (Drift, Riverpod, go_router, pdf, path_provider, etc.).
3. Set up strict analysis_options.yaml and folder structure.
4. Configure Material 3 theme with high-contrast colors (primary, surface, error).
5. Implement basic responsive shell:
   - Desktop/Tablet → NavigationRail or Sidebar
   - Mobile → BottomNavigationBar
6. Create empty Drift database + first migration.
7. Add a simple “Business Profile” setup screen (forced on first launch).

**Exit Criteria:** App launches on Windows and Android, shows empty shell, database is created.

---

### Phase 1 – Core Data Layer & Business Profile
1. Define all Drift tables listed in Section 3.
2. Write DAOs for basic CRUD.
3. Implement BusinessProfile repository + provider.
4. Build Settings → Business Profile screen (name, phone, address, logo upload).
5. Logo is copied to app documents directory and path stored in DB.
6. Create money utility (format cents → display string, parse input).

**Exit Criteria:** Can save business info and logo. Logo path persists.

---

### Phase 2 – Customer & Credit Management
1. Customer entity + repository.
2. Customer list screen (searchable).
3. Add/Edit Customer form (name, phone, address, credit limit).
4. Credit Ledger dashboard:
   - List of customers with outstanding balance > 0
   - Total debt owed to business
5. Customer detail screen showing:
   - Current balance
   - Transaction history (from credit_transactions)
6. Repayment flow:
   - Select customer → enter amount → optional note → record repayment
   - Updates balance and inserts credit_transaction
7. Generate simple Credit Statement PDF (customer history + current balance).

**Exit Criteria:** Full customer CRUD + credit tracking + repayment + PDF statement works offline.

---

### Phase 3 – Catalogue (Products & Services)
1. Item entity (type = product | service).
2. Catalogue list with filters (All / Products / Services) + search.
3. Add/Edit Item form:
   - Products: name, buying price, selling price, stock, low-stock threshold
   - Services: name, selling price only
4. Stock adjustment is not done here (handled later via purchases/movements).
5. Low-stock badge on product list.
6. Soft-delete (is_active flag) instead of hard delete.

**Exit Criteria:** Can manage full catalogue. Products show stock levels.

---

### Phase 4 – Point of Sale (Checkout)
This is the heart of the app. Prioritize speed and clarity.

1. POS screen layout:
   - Left/Top: searchable item grid or list (large tap targets)
   - Right/Bottom: Cart (quantity steppers, line totals, running total)
2. Add item to cart (product or service).
3. Adjust quantity, remove line.
4. Optional: attach Customer (searchable dropdown/bottom sheet).
5. Payment method selection:
   - Cash → record sale, reduce stock (products only), generate receipt
   - Credit → only enabled if customer selected → increase customer balance + insert credit_transaction + reduce stock
6. All of the above inside a single database transaction.
7. After successful sale → show success screen with “Share Receipt” button.
8. PDF Receipt generation (business logo + info, items, totals, payment method, date).

**Key Technical Points**
- Cart held in memory (Riverpod StateNotifier) until checkout.
- On checkout: create sale + sale_items + stock_movements + (optional) credit_transaction atomically.
- Snapshot item name/price/cost at time of sale.

**Exit Criteria:** Full cash and credit sales work. Stock deducts correctly. PDF receipt generates and can be shared.

---

### Phase 5 – Back-Office Operations
1. **Purchase Orders**
   - Create PO → add items + quantities + costs
   - Status: Draft → Ordered → Received
   - On “Received”: increase stock, update average buying price, create stock_movements
2. **Stock Issues (Shrinkage)**
   - Select product → quantity → reason (Damaged / Expired / Lost / Other)
   - Creates negative stock_movement
3. **Expense Tracking**
   - Simple form: category, amount, date, note
   - List + basic filtering by date range

**Exit Criteria:** Stock can be increased via purchases and decreased via issues. Expenses can be logged.

---

### Phase 6 – Business Documents (Quotes & Invoices)
1. Create Quote / Invoice from scratch or convert from cart.
2. Document list with status filters.
3. Document detail + PDF preview.
4. Convert Quote → Sale or Invoice (copy lines).
5. Mark Invoice as Paid (optional simple status).
6. Reuse the same PDF engine as receipts, just different templates/headers.

**Exit Criteria:** Can create, view, and share professional Quotes and Invoices as PDF.

---

### Phase 7 – Dashboard & Reporting
1. **Dashboard**
   - Today’s Revenue (cash + credit)
   - Total Outstanding Credit
   - Low-stock alerts (count + list)
   - Quick actions (New Sale, Add Expense, etc.)
2. **Profit & Loss**
   - Date range selector
   - Revenue (from sales)
   - COGS (sum of cost_at_sale)
   - Gross Profit
   - Expenses
   - Net Profit
3. **Cash vs Accrual toggle**
   - Cash view: only completed cash sales
   - Accrual/Total Value: cash + outstanding credit
4. Simple charts optional (fl_chart) but not required for v1.

**Exit Criteria:** Owner can see daily health and basic P&L offline.

---

### Phase 8 – Settings, Backups & Google Drive
1. Settings screen:
   - Business Profile (already done)
   - Backup interval (Every 4h / Daily / Manual only)
   - Google Drive connection status
2. **Local Backup**
   - Export encrypted `.clodbackup` (SQLite file + metadata) to chosen folder or app documents
   - Use AES encryption with a user-provided or device-derived key
3. **Restore** from `.clodbackup`
4. **Google Drive** (optional)
   - Sign in with Google
   - Upload encrypted backup on schedule or manually
   - List and restore previous cloud backups
5. Automatic backup scheduler using `workmanager` (Android) + Windows equivalent or simple timer.

**Exit Criteria:** User can create encrypted local backups and optionally sync them to Google Drive.

---

### Phase 9 – Polish, Testing & Packaging
1. Responsive refinements (phone vs tablet vs desktop layouts).
2. Empty states, loading indicators, error handling.
3. Input validation and confirmation dialogs for destructive actions.
4. Performance pass (especially POS grid and large customer lists).
5. Unit tests for critical use cases (sale on credit, stock update, balance calculation).
6. Integration tests for full sale flow.
7. App icons, splash screen, Windows installer (Msix or Inno Setup), Android signing.
8. Basic onboarding / first-run tips.

**Exit Criteria:** App feels polished and is ready for real use by a shop owner.

---

## 6. Critical Implementation Guidelines

### Money Handling
- Store everything as `INTEGER` (cents).
- Display layer converts to decimal with proper currency formatting.
- Never use `double` for money in the database or calculations.

### Transactions
Every multi-table write (sale, repayment, purchase receive, stock issue) **must** run inside a Drift transaction.

### PDF Strategy
Create a single `PdfService` with methods:
- `generateReceipt(Sale sale)`
- `generateCreditStatement(Customer customer)`
- `generateQuote(Document doc)`
- `generateInvoice(Document doc)`

All PDFs pull business logo + profile dynamically.

### Offline-First Rules
- No feature may require internet.
- Google Drive is purely additive.
- All timestamps stored as Unix milliseconds (UTC).

### Performance
- Paginate long lists (customers, sales history).
- Use Drift’s `.watch()` only where reactivity is needed.
- Keep POS cart in memory until checkout.

---

## 7. Suggested Development Order Summary

| Phase | Focus                          |
|-------|--------------------------------|
| 0     | Setup + Shell                  |
| 1     | Database + Business Profile    |
| 2     | Customers + Credit             |
| 3     | Catalogue                      |
| 4     | Point of Sale (most important) |
| 5     | Purchases + Stock + Expenses   |
| 6     | Quotes & Invoices              |
| 7     | Dashboard & Reports            |
| 8     | Backups + Drive                |
| 9     | Polish & Release               |

---

## 8. Definition of Done for v1.0

- [ ] Fully offline on Windows and Android
- [ ] Customer credit tracking + repayments + statements
- [ ] Products + Services in one catalogue
- [ ] Fast POS with Cash and Credit payment
- [ ] Automatic stock deduction
- [ ] Purchase orders that update stock & average cost
- [ ] Stock shrinkage logging
- [ ] Expense tracking
- [ ] PDF Receipts, Quotes, Invoices, Credit Statements
- [ ] Dashboard with today’s numbers + low stock
- [ ] Basic P&L (Cash and Accrual views)
- [ ] Encrypted local backups
- [ ] Optional Google Drive sync
- [ ] Business logo on all documents
- [ ] Responsive UI (phone → desktop)

---

## 9. Future Extensions (Post-v1)
- Multi-user / PIN lock
- Optional Bluetooth barcode scanner support
- Basic tax configuration
- Export to CSV / Excel
- Recurring expenses
- Simple loyalty points
- Multi-currency (if needed)

---

**You now have a complete, sequential blueprint.**  
Start with Phase 0. Finish each phase’s exit criteria before moving to the next.  

This document should stay living — update it as you make architectural decisions during development.

Good luck building Clod POS. Keep it simple, keep it fast, and keep the credit ledger rock-solid.  
That is the soul of the product.