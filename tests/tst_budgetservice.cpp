// Unit tests for the core calculation logic.
// Uses an in-memory SQLite DB so tests are fast and isolated.
#include <QtTest>
#include <QTemporaryDir>

#include "data/Database.h"
#include "data/TransactionRepository.h"
#include "services/BudgetService.h"

using namespace bt;

class TstBudgetService : public QObject {
    Q_OBJECT
private slots:
    void monthlySummary_computesRemaining();
    void expensesByCategory_groupsAndSorts();
};

static Transaction makeTx(TxType type, qint64 minor, const QString& isoDate, qint64 cat = 0)
{
    Transaction t;
    t.type = type;
    t.amount = minor;
    t.date = QDate::fromString(isoDate, "yyyy-MM-dd");
    t.categoryId = cat;
    return t;
}

void TstBudgetService::monthlySummary_computesRemaining()
{
    QTemporaryDir dir;
    Database db;
    QVERIFY(db.open(dir.path() + "/t.sqlite"));

    TransactionRepository repo(&db);
    repo.insert(makeTx(TxType::Income,  150000, "2026-06-01")); // 1500.00
    repo.insert(makeTx(TxType::Expense,  20000, "2026-06-03")); //  200.00
    repo.insert(makeTx(TxType::Expense,  30000, "2026-06-10")); //  300.00
    repo.insert(makeTx(TxType::Expense,  99999, "2026-05-30")); // other month

    BudgetService svc(&db);
    const auto s = svc.monthlySummary("2026-06");

    QCOMPARE(s.income,    150000);
    QCOMPARE(s.expense,    50000);
    QCOMPARE(s.remaining, 100000);   // 1500 - 500 = 1000.00
}

void TstBudgetService::expensesByCategory_groupsAndSorts()
{
    QTemporaryDir dir;
    Database db;
    QVERIFY(db.open(dir.path() + "/t.sqlite"));

    // seeded categories exist; ids 3=طعام, 4=مواصلات (see Database::seedDefaults)
    TransactionRepository repo(&db);
    repo.insert(makeTx(TxType::Expense, 10000, "2026-06-01", 4)); // مواصلات 100
    repo.insert(makeTx(TxType::Expense, 25000, "2026-06-02", 3)); // طعام 250
    repo.insert(makeTx(TxType::Expense,  5000, "2026-06-04", 3)); // طعام 50

    BudgetService svc(&db);
    const auto rows = svc.expensesByCategory("2026-06");

    QCOMPARE(rows.size(), 2);
    // sorted by total DESC -> طعام (300) first
    QCOMPARE(rows[0].total, 30000);
    QCOMPARE(rows[1].total, 10000);
}

QTEST_MAIN(TstBudgetService)
#include "tst_budgetservice.moc"
