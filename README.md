# BudgetTracker

BudgetTracker is a desktop-first personal budget and expense tracking app built with **C++20**, **Qt 6 / Qt Quick (QML)**, **SQLite**, and **CMake**.

The main target is Windows desktop. Android support is planned for later, with the project structured so the core logic can be reused without rewriting the application from scratch.

## Status

This project is currently in early development.

The Windows desktop version is the current focus. The app already supports the basic workflow for tracking income, expenses, people, categories, and monthly summaries.

## Features

- Monthly income and expense tracking
- Dashboard with income, expenses, and remaining balance
- Transaction management
- People management
- Category management
- Basic reports
- Local SQLite storage
- JSON import/export
- Arabic UI support
- English UI support in progress
- Desktop-first Qt/QML interface

## Tech Stack

- C++20
- Qt 6
- Qt Quick / QML
- SQLite
- CMake
- Qt Test

## Project Structure

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
```

## Architecture

The project is split into two main layers.

### Core Layer

The core layer contains the application logic and database access. It does not depend on QML, which makes it reusable for future desktop and mobile builds.

It includes:

- Domain models
- SQLite database setup
- Repositories
- Budget calculations
- Import/export logic

### App Layer

The app layer contains the Qt Quick application, C++ view models, and the QML user interface.

It includes:

- Desktop UI
- Shared QML components
- C++ view models
- Settings and dialogs
- Future mobile UI structure

## Why C++ and Qt?

This project is intentionally built with C++ and Qt as a learning-focused desktop application.

The goal is not only to build a useful budget tracker, but also to practice:

- C++ application design
- Qt/QML desktop development
- SQLite integration
- CMake project structure
- Separating UI from business logic
- Preparing a desktop app for future Android support

## Building on Windows

Requirements:

- Qt 6
- Qt Creator
- Visual Studio 2022 with **Desktop development with C++**
- CMake

Open the root `CMakeLists.txt` file in Qt Creator:

```text
BudgetTracker/CMakeLists.txt
```

Then select a desktop kit such as:

```text
Desktop Qt 6.x MSVC2022 64-bit
```

Build and run the project from Qt Creator.

## Running Tests

If tests are enabled, they can be run with:

```bash
ctest
```

The current tests focus mainly on the core budget calculation logic.

## Data Storage

BudgetTracker stores data locally using SQLite.

The database is created in the user's application data directory. The app is designed to work offline by default.

## Roadmap

Planned improvements include:

- Full English/Arabic language switching
- Transaction editing
- Better reports
- Stronger import/export validation
- Windows release packaging
- Android build support
- Optional synchronization in the future

## Documentation

The full design notes and architecture plan are available in:

```text
docs/DESIGN.md
```

## License

No license has been selected yet.
