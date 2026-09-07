# PROGRESS.md – Clod Milestone Tracker

This file is the single source of truth for current work, branch names, tasks, and human review checklists.

---

## Global Working Rules (Mandatory)

1. Never work directly on `production`, `main`, `staging`, or `development`.
2. Only commit to the active milestone branch (`feat/mXX-...`).
3. One atomic commit per task.
4. Follow the commit message format defined in `AGENTS.md`.
5. Run tests before marking any task complete.
6. When all tasks in a milestone are complete, stop and wait for human review.
7. Only the human reviewer marks a milestone as `✅ COMPLETE` and merges it into `development`.

---

## Milestones

### M00 – Project Setup & Responsive Shell 🔄 IN PROGRESS

**Branch:** `feat/m00-project-setup`  
**Status:** Active – agent is working here

#### Tasks
- [ ] Initialize Flutter project targeting Windows desktop and Android
- [ ] Configure `pubspec.yaml` with core dependencies (Drift, Riverpod, go_router, path_provider, etc.)
- [ ] Set up strict `analysis_options.yaml` and clean architecture folder structure (`core/`, `data/`, `domain/`, `presentation/`)
- [ ] Configure Material 3 theme with high-contrast palette and dark/light mode foundations
- [ ] Implement responsive shell (Sidebar / NavigationRail on Desktop & Tablet, NavigationBar on Mobile)
- [ ] Implement go_router configuration with placeholder route shells for all primary views
- [ ] Initialize empty Drift database instance and verify platform-specific sqlite bindings on Windows and Android
- [ ] Write unit and widget tests verifying responsive shell layout and routing

#### Human Review Checklist
- [ ] Flutter app builds and runs cleanly on Windows and Android
- [ ] Responsive navigation adapts seamlessly across desktop and mobile form factors
- [ ] Folder structure adheres strictly to the clean architecture specification
- [ ] No database business logic introduced ahead of time

---

### M01 – Core Data Layer & Business Profile ⏳ PENDING

**Branch:** `feat/m01-core-data-layer`  
**Status:** Pending human review of M00

#### Tasks
- [ ] Define complete SQLite schema via Drift tables (`business_profile`, `customers`, `items`, `sales`, `sale_items`, `credit_transactions`, `purchases`, `purchase_items`, `stock_movements`, `expenses`, `documents`, `app_settings`, `backup_logs`)
- [ ] Implement Drift DAOs with reactive watch streams and CRUD operations
- [ ] Create integer-cents Money utility class with formatting and parsing
- [ ] Implement BusinessProfile repository and Riverpod state provider
- [ ] Build Business Profile configuration screen (business name, phone, address, currency, logo picker)
- [ ] Implement persistent logo file storage service in local application documents
- [ ] Write comprehensive unit tests for Drift migrations, DAOs, and Money utility

#### Human Review Checklist
- [ ] All money values are strictly typed as integer cents
- [ ] Drift schema matches specification exactly
- [ ] Business profile persists and logo copies cleanly to app storage
- [ ] All database unit tests pass

---

### M02 – Customer & Credit Management ⏳ PENDING

**Branch:** `feat/m02-customer-credit`  
**Status:** Pending M01

#### Tasks
- [ ] Implement Customer domain entity, repository, and Riverpod providers
- [ ] Build Customer List screen with real-time search and outstanding balance badges
- [ ] Build Add/Edit Customer form with validation (name, phone, address, credit limit)
- [ ] Build Customer Detail screen displaying transaction history and current credit balance
- [ ] Implement atomic Repayment flow (inserts `credit_transaction`, updates balance)
- [ ] Build Credit Ledger dashboard summarizing total outstanding debt and top debtors
- [ ] Implement dynamic Credit Statement PDF generation and sharing
- [ ] Write unit and integration tests covering credit limits, repayments, and balance updates

#### Human Review Checklist
- [ ] Credit calculations are rock-solid and transactionally safe
- [ ] PDF credit statement renders cleanly with business profile
- [ ] Over-limit credit warnings function properly

---

### M03 – Product & Service Catalogue ⏳ PENDING

**Branch:** `feat/m03-catalogue`  
**Status:** Pending M02

#### Tasks
- [ ] Implement Item entity supporting dual types (`product` vs `service`)
- [ ] Build Catalogue List screen with search, type filters (All / Products / Services), and stock badges
- [ ] Build Add/Edit Item form:
  - Products: buying price, selling price, stock quantity, low-stock threshold
  - Services: selling price only
- [ ] Implement soft-delete (`is_active`) and low-stock alert triggers
- [ ] Write unit tests for catalogue search, filtering, and stock threshold logic

#### Human Review Checklist
- [ ] Services properly omit stock and buying prices
- [ ] Soft deletion preserves historical integrity
- [ ] Low-stock indicators display accurately

---

### M04 – Point of Sale & Checkout Engine ⏳ PENDING

**Branch:** `feat/m04-pos-checkout`  
**Status:** Pending M03

#### Tasks
- [ ] Implement in-memory POS Cart state management via Riverpod (add/remove items, quantity steppers, discounts)
- [ ] Build fast, touch-friendly POS Screen layout (Item grid/search on left, live Cart on right)
- [ ] Implement Customer attachment flow to cart
- [ ] Build atomic Checkout transaction:
  - Cash: records sale, sale items, creates stock movement (products only)
  - Credit: verifies customer attached, updates balance, creates credit transaction, creates stock movement
- [ ] Build Sale Success screen with instant PDF receipt preview and sharing
- [ ] Implement dynamic PDF receipt generator with logo, items, totals, and payment method
- [ ] Write rigorous integration tests for concurrent cart operations, stock deductions, and credit checkout

#### Human Review Checklist
- [ ] Checkout operations are 100% atomic inside a Drift transaction
- [ ] Credit sales require attached customer
- [ ] Stock deducts accurately and historical prices are snapshotted on line items
- [ ] PDF receipt generates instantly offline

---

### M05 – Back-Office Operations ⏳ PENDING

**Branch:** `feat/m05-back-office`  
**Status:** Pending M04

#### Tasks
- [ ] Implement Purchase Order workflow (Draft -> Ordered -> Received)
- [ ] On PO Received: atomically update stock quantities, recalculate average buying cost, insert stock movements
- [ ] Build Stock Issues / Shrinkage logging screen (Damaged / Expired / Lost / Adjustment)
- [ ] Build Expense Tracking module (Category, Amount, Date, Note)
- [ ] Build Expense List screen with date range filters
- [ ] Write unit tests for weighted average cost calculation and shrinkage deductions

#### Human Review Checklist
- [ ] Purchase receiving updates stock and weighted cost atomically
- [ ] Shrinkage logging creates negative stock movements cleanly
- [ ] Expense logging operates offline

---

### M06 – Business Documents (Quotes & Invoices) ⏳ PENDING

**Branch:** `feat/m06-business-documents`  
**Status:** Pending M05

#### Tasks
- [ ] Implement Document domain model (`quote` vs `invoice`) and Drift repository
- [ ] Build Document List screen with status filters (Draft / Sent / Accepted / Paid / Cancelled)
- [ ] Build Document Creation/Editing screen with line items and customer attachment
- [ ] Implement one-click conversion: Quote -> Invoice / Cart Sale
- [ ] Implement dynamic PDF generator for Quotes and Invoices
- [ ] Write unit tests for document lifecycle and conversion logic

#### Human Review Checklist
- [ ] Quotes convert seamlessly to invoices or sales
- [ ] PDF invoices and quotes render professional typography and business branding

---

### M07 – Dashboard & Analytics Reporting ⏳ PENDING

**Branch:** `feat/m07-dashboard-reporting`  
**Status:** Pending M06

#### Tasks
- [ ] Build Owner Dashboard with daily metrics (Today's Revenue, Total Outstanding Debt, Low Stock Count)
- [ ] Implement Profit & Loss calculation engine (Revenue, COGS from snapshotted costs, Gross Profit, Expenses, Net Profit)
- [ ] Build P&L Report screen with custom date ranges and Cash vs Accrual view toggles
- [ ] Build Stock Valuation report (total inventory value at cost vs retail)
- [ ] Write comprehensive unit tests for P&L financial equations and date slicing

#### Human Review Checklist
- [ ] P&L calculations match financial formulas exactly
- [ ] Cash vs Accrual views accurately differentiate cash received vs credit extended
- [ ] Reports calculate entirely offline from local SQLite data

---

### M08 – Settings, Encrypted Backups & Cloud Sync ⏳ PENDING

**Branch:** `feat/m08-backups-sync`  
**Status:** Pending M07

#### Tasks
- [ ] Implement encrypted local backup service exporting `.clodbackup` (AES-256 encrypted SQLite snapshot + metadata)
- [ ] Implement full restore engine validating checksums and schema versions before database swap
- [ ] Implement optional Google Drive backup sync via OAuth2
- [ ] Build Settings screen (Business profile, backup scheduling, manual backup/restore, Drive status)
- [ ] Write unit tests for backup encryption, integrity verification, and restore pipelines

#### Human Review Checklist
- [ ] `.clodbackup` archives are securely encrypted
- [ ] Restoring replaces local database cleanly with zero corruption
- [ ] Google Drive integration remains 100% optional

---

### M09 – Polish, Multi-Platform Packaging & Release ⏳ PENDING

**Branch:** `feat/m09-polish-release`  
**Status:** Pending M08

#### Tasks
- [ ] Multi-platform UI responsiveness audit (Windows Desktop, Android Phone, Android Tablet)
- [ ] Performance pass on large product catalogues and long customer credit histories
- [ ] App icons, branding assets, splash screen configuration
- [ ] End-to-end integration test suite covering the full merchant lifecycle
- [ ] Build scripts for Windows installer (MSIX / Inno Setup) and Android APK / AAB signing

#### Human Review Checklist
- [ ] App launches and operates with 60 FPS fluidity on target devices
- [ ] All exit criteria and Definition of Done for v1.0 met
- [ ] Multi-platform packaging compiles clean standalone binaries
