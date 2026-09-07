# Clod

**Offline-first • Credit-native • Single-user • Local-first Business Platform**

Target Platforms: **Windows (Desktop)** + **Android (Phone & Tablet)**

---

## 📖 About Clod

**Clod** is an offline-first, credit-native business operations platform built to provide merchants and entrepreneurs with a fast, reliable, zero-cloud-dependent system for managing sales, inventory, credit ledgers, dynamic documents, and financial health.

### Core Philosophy:
- **Offline-First:** 100% of functionality runs on-device using local SQLite via Drift.
- **Credit-Native:** Integrated credit ledger tracking customer debts, limits, repayments, and PDF statements.
- **Integer Money:** All currency amounts are strictly stored as integer cents to eliminate floating-point calculation errors.
- **Cross-Platform:** Built on Flutter 3.24+ delivering native execution across Windows desktop and Android devices.
- **Digital Documents:** Instant offline PDF generation for receipts, quotes, invoices, and credit statements with embedded branding.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | **Flutter 3.24+** (Dart) | Single codebase for Windows desktop + Android |
| **Local Database** | **Drift** (SQLite) | Type-safe queries, transactional consistency, reactive streams |
| **State Management** | **Riverpod 2.x** | Testable, modular state architecture |
| **Routing & Navigation** | **go_router** | Declarative, responsive layout routing |
| **PDF Generation** | **pdf** + **printing** | Dynamic on-device document rendering |
| **Security & Encryption** | **encrypt** + **pointycastle** | AES-256 encrypted local backups (`.clodbackup`) |
| **Cloud Sync (Optional)** | **googleapis** + **google_sign_in** | Optional encrypted Google Drive backup sync |

---

## 📂 Project Structure

```
lib/
├── main.dart                  <- Application entry point
├── app.dart                   <- MaterialApp configuration & theme setup
├── core/
│   ├── theme/                 <- Material 3 high-contrast palette
│   ├── constants/             <- Application constants
│   ├── utils/                 <- Money (cents), date formatting, helpers
│   └── errors/                <- Failure definitions & error handling
├── data/
│   ├── database/              <- Drift database, tables, DAOs, migrations
│   ├── repositories/          <- Data repository implementations
│   └── services/              <- BackupService, PdfService, DriveService
├── domain/
│   ├── entities/              <- Pure domain models
│   ├── repositories/          <- Abstract repository interfaces
│   └── usecases/              <- Business use case services
└── presentation/
    ├── providers/             <- Riverpod state providers
    ├── screens/               <- POS, Customers, Catalogue, Dashboard, etc.
    ├── widgets/               <- Reusable UI components
    └── router/                <- go_router responsive shell
```

---

## 🚦 Development Workflow & Version Control

Clod enforces strict, test-driven development:
- **`AGENTS.md`** defines the mandatory rules of engagement and commit formats.
- **`PROGRESS.md`** tracks active milestones, task checkboxes, and human review gates.
- Work proceeds only on milestone feature branches (`feat/mXX-...`) and merges into `development` upon review.
