# PROGRESS.md – Clod Milestone Tracker

**This is the single source of truth for what the AI agent is allowed to work on right now.**

Before starting any work, the agent must have read `AGENTS.md`.  
All permanent rules (branching strategy, commit format, PR generation, how to mark tasks) live in `AGENTS.md`.

---

## M00 – Project Setup & Responsive Shell ✅ COMPLETE

**Branch:** `feat/m00-project-setup`  
**Status:** Merged into `development`

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
- [x] Write unit and widget tests verifying responsive shell layout and routing

---

## M01 – Core Data Layer & Business Profile ✅ COMPLETE

**Branch:** `feat/m01-core-data-layer`  
**Status:** Merged into `development`

### Context
Defines the complete local SQLite schema via Drift tables and DAOs with compile-time safety, reactive streams, and strict integer-cents money typing. Implements the Business Profile singleton, persistent local logo storage in application documents, and core financial math utilities.

### Tasks

- [x] Define complete SQLite schema via Drift tables (`business_profile`, `customers`, `items`, `sales`, `sale_items`, `credit_transactions`, `purchases`, `purchase_items`, `stock_movements`, `expenses`, `documents`, `app_settings`, `backup_logs`)
- [x] Implement Drift DAOs with reactive watch streams and CRUD operations
- [x] Create integer-cents Money utility class with formatting and parsing
- [x] Implement BusinessProfile repository and Riverpod state provider
- [x] Build Business Profile configuration screen (business name, phone, address, currency, logo picker)
- [x] Implement persistent logo file storage service in local application documents
- [x] Write comprehensive unit tests for Drift migrations, DAOs, and Money utility

---

## M02 – Customer & Credit Management ✅ COMPLETE

**Branch:** `feat/m02-customer-credit`  
**Status:** Completed and ready for review

### Context
Implements the customer directory and credit ledger system. Tracks individual customer balances, credit limits, transaction histories, and repayments. Generates offline Credit Statement PDFs dynamically branded with the business profile.

### Tasks

- [x] Implement Customer domain entity, repository, and Riverpod providers
- [x] Build Customer List screen with real-time search and outstanding balance badges
- [x] Build Add/Edit Customer form with validation (name, phone, address, credit limit)
- [x] Build Customer Detail screen displaying transaction history and current credit balance
- [x] Implement atomic Repayment flow (inserts `credit_transaction`, updates balance)
- [x] Build Credit Ledger dashboard summarizing total outstanding debt and top debtors
- [x] Implement dynamic Credit Statement PDF generation and sharing
- [x] Write unit and integration tests covering credit limits, repayments, and balance updates

---

## M03 – Product & Service Catalogue ✅ COMPLETE

**Branch:** `feat/m03-catalogue-inventory`  
**Status:** Completed and ready for review

### Context
Builds the unified catalogue supporting both physical products (with stock tracking, buying price, and low-stock alerts) and services (selling price only). Enforces soft deletion to preserve historical data integrity.

### Tasks

- [x] Implement Item entity supporting dual types (`product` vs `service`)
- [x] Build Catalogue List screen with search, type filters (All / Products / Services), and stock badges
- [x] Build Add/Edit Item form (Products: buying/selling price, stock, threshold; Services: selling price only)
- [x] Implement soft-delete (`is_active`) and low-stock alert triggers
- [x] Write unit tests for catalogue search, filtering, and stock threshold logic

---

## M04 – Point of Sale & Checkout Engine ✅ COMPLETE

**Branch:** `feat/m04-pos-checkout`  
**Status:** Active – agent is working here

### Context
Constructs the high-speed, touch-optimized checkout experience. Manages an in-memory cart with line adjustments, customer attachment, and atomic multi-table checkout transactions (Cash vs Credit) with immediate offline PDF receipt generation.

### Tasks

- [x] Implement in-memory POS Cart state management via Riverpod (add/remove items, quantity steppers, discounts)
- [x] Build fast, touch-friendly POS Screen layout (Item grid/search on left, live Cart on right)
- [x] Implement Customer attachment flow to cart
- [x] Build atomic Checkout transaction (Cash: records sale + stock deduction; Credit: updates customer balance + records credit transaction + stock deduction)
- [x] Build Sale Success screen with instant PDF receipt preview and sharing
- [x] Implement dynamic PDF receipt generator with logo, items, totals, and payment method
- [x] Write rigorous integration tests for concurrent cart operations, stock deductions, and credit checkout

---

## M05 – Back-Office Operations ✅ COMPLETE

**Branch:** `feat/m05-back-office`  
**Status:** Active – agent is working here

### Context
Handles inventory restocking via Purchase Orders with automated weighted average cost updates, stock shrinkage logging (damage, expired, lost), and offline business expense tracking.

### Tasks

- [x] Implement Purchase Order workflow (Draft -> Ordered -> Received)
- [x] On PO Received: atomically update stock quantities, recalculate average buying cost, insert stock movements
- [x] Build Stock Issues / Shrinkage logging screen (Damaged / Expired / Lost / Adjustment)
- [x] Build Expense Tracking module (Category, Amount, Date, Note)
- [x] Build Expense List screen with date range filters
- [x] Write unit tests for weighted average cost calculation and shrinkage deductions

---

## M06 – Business Documents (Quotes & Invoices) ✅ COMPLETE

**Branch:** `feat/m06-business-documents`  
**Status:** Active – agent is working here

### Context
Provides professional document creation for quotes and invoices. Supports one-click conversion of quotes into active sales or invoices, status lifecycle tracking, and dynamic branded PDF rendering.

### Tasks

  - [x] Implement Document domain model (`quote` vs `invoice`) and Drift repository
  - [x] Build Document List screen with status filters (Draft / Sent / Accepted / Paid / Cancelled)
  - [x] Build Document Creation/Editing screen with line items and customer attachment
  - [x] Implement one-click conversion: Quote -> Invoice / Cart Sale
  - [x] Implement dynamic PDF generator for Quotes and Invoices
  - [x] Write unit tests for document lifecycle and conversion logic

---

## M07 – Dashboard & Analytics Reporting 🔄 IN PROGRESS

**Branch:** `feat/m07-dashboard-reporting`  
**Status:** Active – agent is working here

### Context
Provides the merchant with actionable real-time business intelligence: daily revenue totals, outstanding debt summaries, low-stock alerts, and an offline Profit & Loss reporting engine with Cash vs Accrual views.

### Tasks

  - [x] Build Owner Dashboard with daily metrics (Today's Revenue, Total Outstanding Debt, Low Stock Count)
  - [x] Implement Profit & Loss calculation engine (Revenue, COGS from snapshotted costs, Gross Profit, Expenses, Net Profit)
  - [x] Build P&L Report screen with custom date ranges and Cash vs Accrual view toggles
  - [x] Build Stock Valuation report (total inventory value at cost vs retail)
  - [x] Write comprehensive unit tests for P&L financial equations and date slicing

---

## M08 – Settings, Encrypted Backups & Cloud Sync ✅ COMPLETE

**Branch:** `feat/m08-backups-sync`  
**Status:** Merged into `development`

### Context
Guarantees merchant data durability through encrypted `.clodbackup` exports (AES-256 encrypted SQLite snapshot + metadata), integrity-verified database restores, and optional Google Drive synchronization.

### Tasks
  
  - [x] Implement encrypted local backup service exporting `.clodbackup` (AES-256 encrypted SQLite snapshot + metadata)
  - [x] Implement full restore engine validating checksums and schema versions before database swap
  - [x] Implement optional Google Drive backup sync via OAuth2
  - [x] Build Settings screen (Business profile, backup scheduling, manual backup/restore, Drive status)
  - [x] Write unit tests for backup encryption, integrity verification, and restore pipelines

---

## M09 – Polish, Multi-Platform Packaging & Release 🔄 IN PROGRESS

**Branch:** `feat/m09-polish-release`  
**Status:** Active – agent is working here

### Context
Conducts comprehensive cross-platform responsiveness audits across Windows desktop, Android phones, and tablets. Executes performance optimizations, branding/app icon integration, and standalone packaging build pipelines.

### Tasks

  - [x] Multi-platform UI responsiveness audit (Windows Desktop, Android Phone, Android Tablet)
  - [x] Performance pass on large product catalogues and long customer credit histories
  - [x] App icons, branding assets, splash screen configuration
  - [x] End-to-end integration test suite covering the full merchant lifecycle
- [ ] Build scripts for Windows installer (MSIX / Inno Setup) and Android APK / AAB signing
