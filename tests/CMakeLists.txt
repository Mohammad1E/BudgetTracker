# Unit tests for the core library (no UI). Uses Qt Test.
find_package(Qt6 REQUIRED COMPONENTS Test)

qt_add_executable(tst_budgetservice tst_budgetservice.cpp)
target_link_libraries(tst_budgetservice PRIVATE bt_core Qt6::Test Qt6::Sql)
add_test(NAME budgetservice COMMAND tst_budgetservice)
