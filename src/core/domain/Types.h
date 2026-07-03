#pragma once
#include <QtGlobal>

namespace bt {

// Transaction direction. Stored as INTEGER in SQLite.
enum class TxType : int {
    Expense = 0,
    Income  = 1
};

// Money is ALWAYS stored as integer "minor units" (e.g. piasters/cents) to
// avoid floating-point rounding errors. 12.50 JOD -> 1250.
using Money = qint64;

} // namespace bt
