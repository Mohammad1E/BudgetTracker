# ============================================================================
#  BudgetTracker - Top-level CMake
#  C++20 + Qt 6.8 (LTS) + Qt Quick/QML + SQLite
#  Desktop-first (Windows EXE), Android-ready (APK/AAB)
# ============================================================================
cmake_minimum_required(VERSION 3.21.1)   # 3.21.1+ required for Qt 6 Android multi-ABI

project(BudgetTracker
    VERSION 0.1.0
    DESCRIPTION "Personal budget & expense tracker"
    LANGUAGES CXX)

# ---- C++ standard ----------------------------------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ---- Qt --------------------------------------------------------------------
# Components used across the whole project. Add modules here as the app grows.
find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Sql)

# Sets up AUTOMOC/AUTORCC, output dirs, and QML helpers. Requires Qt 6.5+.
qt_standard_project_setup(REQUIRES 6.5)

# ---- Sub-projects ----------------------------------------------------------
# core  = shared, platform-agnostic logic (no QML). Reused by Windows & Android.
# app   = Qt Quick application (view-models + QML UI + main).
add_subdirectory(src/core)
add_subdirectory(src/app)

# ---- Tests (optional) ------------------------------------------------------
# Configure with -DBT_BUILD_TESTS=ON to build the unit tests for the core.
option(BT_BUILD_TESTS "Build unit tests for the core library" OFF)
if(BT_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
