# BudgetTracker

BudgetTracker is a desktop-first personal finance application for tracking monthly income, expenses, people, categories, and reports.

The project is built with C++20, Qt Quick/QML, SQLite, and CMake.  
The main target is Windows desktop, with the codebase structured so Android support can be added later without rewriting the core logic.

## Project Status

This project is currently in early development.

The Windows desktop version is the main focus right now. The app already supports the core flow of adding transactions, viewing monthly totals, managing categories and people, and showing basic reports.

Android support is planned for a later stage.

## Features

Current features include:

- Monthly income and expense tracking
- Dashboard with income, expense, and remaining balance
- Add and delete transactions
- People management
- Category management
- Basic reports
- Local SQLite storage
- JSON import/export
- Arabic UI support
- English UI support planned/being added
- Desktop-first Qt/QML interface

## Tech Stack

- C++20
- Qt 6
- Qt Quick / QML
- SQLite
- CMake
- Qt Test

## Architecture

The project is split into two main parts:

### Core Layer

The core layer contains the application logic and database access.  
It does not depend on QML, which makes it reusable across desktop and future mobile builds.

Main responsibilities:

- Domain models
- SQLite database setup and migrations
- Repositories
- Budget calculations
- Import/export logic

### App Layer

The app layer contains the Qt Quick application, view models, and QML user interface.

Main responsibilities:

- Connecting QML to C++ through view models
- Desktop UI
- Future mobile UI
- User interaction
- Settings and dialogs

Simplified structure:

```text
BudgetTracker/
├── src/
│   ├── core/
│   │   ├── domain/
│   │   ├── data/
│   │   └── services/
│   │
│   └── app/
│       ├── viewmodels/
│       └── qml/
│           ├── desktop/
│           ├── mobile/
│           └── shared/
│
├── tests/
├── docs/
├── CMakeLists.txt
└── README.md
