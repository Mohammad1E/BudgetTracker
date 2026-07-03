#pragma once
#include <QString>
#include "domain/Types.h"

namespace bt {

// A planned spending limit for a category in a given month ("YYYY-MM").
struct Budget {
    qint64  id            = 0;
    QString month;            // "2026-06"
    qint64  categoryId     = 0;
    Money   plannedAmount   = 0;   // minor units
};

// Planned salary / expected income for a month, used for "remaining vs plan".
struct MonthlyIncomePlan {
    QString month;            // "2026-06"
    Money   plannedSalary = 0;
};

} // namespace bt
