# ============================================================================
#  bt_core - shared, platform-agnostic library (no QML / no Quick dependency)
#  Depends only on Qt6::Core and Qt6::Sql so it compiles identically on
#  Windows and Android.
# ============================================================================
qt_add_library(bt_core STATIC
    # ---- domain (plain structs, header-only) ----
    domain/Types.h
    domain/Transaction.h
    domain/Category.h
    domain/Person.h
    domain/Account.h
    domain/Budget.h

    # ---- data access ----
    data/Database.h          data/Database.cpp
    data/TransactionRepository.h  data/TransactionRepository.cpp
    data/CategoryRepository.h     data/CategoryRepository.cpp
    data/PersonRepository.h       data/PersonRepository.cpp

    # ---- business logic / services ----
    services/BudgetService.h        services/BudgetService.cpp
    services/ImportExportService.h  services/ImportExportService.cpp
)

target_link_libraries(bt_core PUBLIC
    Qt6::Core
    Qt6::Sql)

target_compile_features(bt_core PUBLIC cxx_std_20)

# Allow includes like  #include "data/Database.h"  from anywhere that links core.
target_include_directories(bt_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
