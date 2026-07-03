#pragma once
#include <QString>
#include <QVector>
#include "domain/Types.h"

namespace bt {

class Database;

// Aggregated totals for one month.
struct MonthlySummary {
    Money income    = 0;   // sum of income transactions (minor units)
    Money expense   = 0;   // sum of expense transactions
    Money remaining = 0;   // income - expense
};

// One row of "spending grouped by category".
struct CategoryTotal {
    qint64  categoryId = 0;
    QString name;
    QString color;
    Money   total = 0;
};

// One row of "spending grouped by day".
struct DailyTotal {
    QString date;          // 'YYYY-MM-DD'
    Money   expense = 0;
    Money   income  = 0;
};

// All read-only reporting/aggregation lives here. No UI, fully unit-testable.
class BudgetService {
public:
    explicit BudgetService(Database* db);

    // month format: "YYYY-MM"
    MonthlySummary        monthlySummary(const QString& month) const;
    QVector<CategoryTotal> expensesByCategory(const QString& month) const;
    QVector<DailyTotal>    dailyTotals(const QString& month) const;

    // Planned salary for a month (0 if none set).
    Money plannedSalary(const QString& month) const;
    bool  setPlannedSalary(const QString& month, Money amount);

    // remaining vs the *planned* salary instead of actual income.
    Money remainingVsPlan(const QString& month) const;

private:
    Database* m_db;   // not owned
};

} // namespace bt
