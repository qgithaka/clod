# PROGRESS.md – Clod Milestone Tracker

**This is the single source of truth for what the AI agent is allowed to work on right now.**

Before starting any work, the agent must have read `AGENTS.md`.  
All permanent rules (branching strategy, commit format, PR generation, how to mark tasks) live in `AGENTS.md`.

---

## M00 – Project Setup & Responsive Shell 🔄 IN PROGRESS

**Branch:** `feat/m00-project-setup`  
**Status:** Active – agent is working here

### Context
Establishes the Flutter multi-platform application foundation targeting Windows desktop and Android (phones and tablets). Configures clean architecture layer separation (`core/`, `data/`, `domain/`, `presentation/`), strict linting rules, Material 3 high-contrast theme, go_router navigation, and responsive shell scaffolding (Sidebar / NavigationRail for desktop/tablet, NavigationBar for mobile).

### Tasks

- [x] Initialize Flutter project targeting Windows desktop and Android
- [x] Configure `pubspec.yaml` with core dependencies (Drift, Riverpod, go_router, path_provider, etc.)
- [x] Set up strict `analysis_options.yaml` and clean architecture folder structure (`core/`, `data/`, `domain/`, `presentation/`)
- [x] Configure Material 3 theme with high-contrast palette and dark/light mode foundations
- [x] Implement responsive shell (Sidebar / NavigationRail on Desktop & Tablet, NavigationBar on Mobile)
- [x] Implement go_router configuration with placeholder route shells for all primary views
- [x] Initialize empty Drift database instance and verify platform-specific sqlite bindings on Windows and Android
- [ ] Write unit and widget tests verifying responsive shell layout and routing

---

## M01 – Core Data Layer & Business Profile ⏳ PENDING

**Branch:** `feat/m01-core-data-layer`  
**Status:** Pending human review of M00

### Context
Defines the complete local SQLite schema via Drift tables and DAOs with compile-time safety, reactive streams, and strict integer-cents money typing. Implements the Business Profile singleton, persistent local logo storage in application documents, and core financial math utilities.

### Tasks

- [ ] Define complete SQLite schema via Drift tables (`business_profile`, `customers`, `items`, `sales`, `sale_items`, `credit_transactions`, `purchases`, `purchase_items`, `stock_movements`, `expenses`, `documents`, `app_settings`, `backup_logs`)
- [ ] Implement Drift DAOs with reactive watch streams and CRUD operations
- [ ] Create integer-cents Money utility class with formatting and parsing
- [ ] Implement BusinessProfile repository and Riverpod state provider
- [ ] Build Business Profile configuration screen (business name, phone, address, currency, logo picker)
- [ ] Implement persistent logo file storage service in local application documents
- [ ] Write comprehensive unit tests for Drift migrations, DAOs, and Money utility

---

## M02 – Customer & Credit Management ⏳ PENDING

**Branch:** `feat/m02-customer-credit`  
**Status:** Pending M01

### Context
Implements the customer directory and credit ledger system. Tracks individual customer balances, credit limits, transaction histories, and repayments. Generates offline Credit Statement PDFs dynamically branded with the business profile.

### Tasks

- [ ] Implement Customer domain entity, repository, and Riverpod providers
- [ ] Build Customer List screen with real-time search and outstanding balance badges
- [ ] Build Add/Edit Customer form with validation (name, phone, address, credit limit)
- [ ] Build Customer Detail screen displaying transaction history and current credit balance
- [ ] Implement atomic Repayment flow (inserts `credit_transaction`, updates balance)
- [ ] Build Credit Ledger dashboard summarizing total outstanding debt and top debtors
- [ ] Implement dynamic Credit Statement PDF generation and sharing
- [ ] Write unit and integration tests covering credit limits, repayments, and balance updates

---

## M03 – Product & Service Catalogue ⏳ PENDING

**Branch:** `feat/m03-catalogue`  
**Status:** Pending M02

### Context
Builds the unified catalogue supporting both physical products (with stock tracking, buying price, and low-stock alerts) and services (selling price only). Enforces soft deletion to preserve historical data integrity.

### Tasks

- [ ] Implement Item entity supporting dual types (`product` vs `service`)
- [ ] Build Catalogue List screen with search, type filters (All / Products / Services), and stock badges
- [ ] Build Add/Edit Item form (Products: buying/selling price, stock, threshold; Services: selling price only)
- [ ] Implement soft-delete (`is_active`) and low-stock alert triggers
- [ ] Write unit tests for catalogue search, filtering, and stock threshold logic

---

## M04 – Point of Sale & Checkout Engine ⏳ PENDING

**Branch:** `feat/m04-pos-checkout`  
**Status:** Pending M03

### Context
Constructs the high-speed, touch-optimized checkout experience. Manages an in-memory cart with line adjustments, customer attachment, and atomic multi-table checkout transactions (Cash vs Credit) with immediate offline PDF receipt generation.

### Tasks

- [ ] Implement in-memory POS Cart state management via Riverpod (add/remove items, quantity steppers, discounts)
- [ ] Build fast, touch-friendly POS Screen layout (Item grid/search on left, live Cart on right)
- [ ] Implement Customer attachment flow to cart
- [ ] Build atomic Checkout transaction (Cash: records sale + stock deduction; Credit: updates customer balance + records credit transaction + stock deduction)
- [ ] Build Sale Success screen with instant PDF receipt preview and sharing
- [ ] Implement dynamic PDF receipt generator with logo, items, totals, and payment method
- [ ] Write rigorous integration tests for concurrent cart operations, stock deductions, and credit checkout

---

## M05 – Back-Office Operations ⏳ PENDING

**Branch:** `feat/m05-back-office`  
**Status:** Pending M04

### Context
Handles inventory restocking via Purchase Orders with automated weighted average cost updates, stock shrinkage logging (damage, expired, lost), and offline business expense tracking.

### Tasks

- [ ] Implement Purchase Order workflow (Draft -> Ordered -> Received)
- [ ] On PO Received: atomically update stock quantities, recalculate average buying cost, insert stock movements
- [ ] Build Stock Issues / Shrinkage logging screen (Damaged / Expired / Lost / Adjustment)
- [ ] Build Expense Tracking module (Category, Amount, Date, Note)
- [ ] Build Expense List screen with date range filters
- [ ] Write unit tests for weighted average cost calculation and shrinkage deductions

---

## M06 – Business Documents (Quotes & Invoices) ⏳ PENDING

**Branch:** `feat/m06-business-documents`  
**Status:** Pending M05

### Context
Provides professional document creation for quotes and invoices. Supports one-click conversion of quotes into active sales or invoices, status lifecycle tracking, and dynamic branded PDF rendering.

### Tasks

- [ ] Implement Document domain model (`quote` vs `invoice`) and Drift repository
- [ ] Build Document List screen with status filters (Draft / Sent / Accepted / Paid / Cancelled)
- [ ] Build Document Creation/Editing screen with line items and customer attachment
- [ ] Implement one-click conversion: Quote -> Invoice / Cart Sale
- [ ] Implement dynamic PDF generator for Quotes and Invoices
- [ ] Write unit tests for document lifecycle and conversion logic

---

## M07 – Dashboard & Analytics Reporting ⏳ PENDING

**Branch:** `feat/m07-dashboard-reporting`  
**Status:** Pending M06

### Context
Provides the merchant with actionable real-time business intelligence: daily revenue totals, outstanding debt summaries, low-stock alerts, and an offline Profit & Loss reporting engine with Cash vs Accrual views.

### Tasks

- [ ] Build Owner Dashboard with daily metrics (Today's Revenue, Total Outstanding Debt, Low Stock Count)
- [ ] Implement Profit & Loss calculation engine (Revenue, COGS from snapshotted costs, Gross Profit, Expenses, Net Profit)
- [ ] Build P&L Report screen with custom date ranges and Cash vs Accrual view toggles
- [ ] Build Stock Valuation report (total inventory value at cost vs retail)
- [ ] Write comprehensive unit tests for P&L financial equations and date slicing

---

## M08 – Settings, Encrypted Backups & Cloud Sync ⏳ PENDING

**Branch:** `feat/m08-backups-sync`  
**Status:** Pending M07

### Context
Guarantees merchant data durability through encrypted `.clodbackup` exports (AES-256 encrypted SQLite snapshot + metadata), integrity-verified database restores, and optional Google Drive synchronization.

### Tasks

- [ ] Implement encrypted local backup service exporting `.clodbackup` (AES-256 encrypted SQLite snapshot + metadata)
- [ ] Implement full restore engine validating checksums and schema versions before database swap
- [ ] Implement optional Google Drive backup sync via OAuth2
- [ ] Build Settings screen (Business profile, backup scheduling, manual backup/restore, Drive status)
- [ ] Write unit tests for backup encryption, integrity verification, and restore pipelines

---

## M09 – Polish, Multi-Platform Packaging & Release ⏳ PENDING

**Branch:** `feat/m09-polish-release`  
**Status:** Pending M08

### Context
Conducts comprehensive cross-platform responsiveness audits across Windows desktop, Android phones, and tablets. Executes performance optimizations, branding/app icon integration, and standalone packaging build pipelines.

### Tasks

- [ ] Multi-platform UI responsiveness audit (Windows Desktop, Android Phone, Android Tablet)
- [ ] Performance pass on large product catalogues and long customer credit histories
- [ ] App icons, branding assets, splash screen configuration
- [ ] End-to-end integration test suite covering the full merchant lifecycle
- [ ] Build scripts for Windows installer (MSIX / Inno Setup) and Android APK / AAB signing
