# ============================================================================
#  BudgetTracker - Qt Quick application (view-models + QML UI + main)
#  Shares src/core for all logic. Only the QML tree differs per platform.
# ============================================================================

qt_add_executable(BudgetTracker
    main.cpp
    viewmodels/AppController.h        viewmodels/AppController.cpp
    viewmodels/TransactionListModel.h viewmodels/TransactionListModel.cpp
    viewmodels/DashboardViewModel.h   viewmodels/DashboardViewModel.cpp
    viewmodels/CategoryListModel.h    viewmodels/CategoryListModel.cpp
    viewmodels/PersonListModel.h      viewmodels/PersonListModel.cpp
)
# Tip: add WIN32 above (qt_add_executable(BudgetTracker WIN32 ...)) for a
# release build with no console window on Windows. Left off so you see logs.

# ---- QML files --------------------------------------------------------------
# Shared components + theme are always compiled in.
set(BT_QML_SHARED
    qml/shared/Theme.qml
    qml/shared/Card.qml
    qml/shared/MoneyText.qml
    qml/shared/KpiCard.qml
    qml/shared/TransactionDialog.qml
)

# UI shell is platform-specific. Desktop on Windows/macOS/Linux; mobile on
# Android. Type names (Main, TransactionsPage, ...) never clash because only
# ONE of these sets is added per build.
if(ANDROID OR IOS)
    set(BT_QML_UI
        qml/mobile/Main.qml
        qml/mobile/HomePage.qml
        qml/mobile/QuickAddPage.qml
        qml/mobile/TransactionsPage.qml
        qml/mobile/SettingsPage.qml
    )
else()
    set(BT_QML_UI
        qml/desktop/Main.qml
        qml/desktop/Sidebar.qml
        qml/desktop/DashboardPage.qml
        qml/desktop/TransactionsPage.qml
        qml/desktop/ReportsPage.qml
        qml/desktop/PeoplePage.qml
        qml/desktop/CategoriesPage.qml
        qml/desktop/SettingsPage.qml
    )
endif()

# Theme.qml is a QML singleton.
set_source_files_properties(qml/shared/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

if(COMMAND qt_policy)
    qt_policy(SET QTP0004 NEW)
endif()

qt_add_qml_module(BudgetTracker
    URI BudgetTrackerUi
    VERSION 1.0
    QML_FILES ${BT_QML_SHARED} ${BT_QML_UI}
)

target_link_libraries(BudgetTracker PRIVATE
    bt_core
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

# ---- Android-specific build settings ---------------------------------------
# These only take effect when configuring with the Android toolchain.
# Build for BOTH old (32-bit) and modern (64-bit) ARM devices.
# On the command line you can instead pass:
#   -DQT_ANDROID_ABIS="armeabi-v7a;arm64-v8a"  or  -DQT_ANDROID_BUILD_ALL_ABIS=ON
if(ANDROID)
    set_target_properties(BudgetTracker PROPERTIES
        QT_ANDROID_MIN_SDK_VERSION    28    # Android 9 (Qt 6.8 minimum)
        QT_ANDROID_TARGET_SDK_VERSION 34
    )
    # When you need to customize the manifest/icons, let Qt Creator generate the
    # Android template into src/app/android, then uncomment:
    # set_target_properties(BudgetTracker PROPERTIES
    #     QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
endif()
