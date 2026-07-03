#include "services/BudgetService.h"
#include "data/Database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

BudgetService::BudgetService(Database* db) : m_db(db) {}

MonthlySummary BudgetService::monthlySummary(const QString& month) const
{
    MonthlySummary s;
    QSqlQuery q(m_db->connection());
    q.prepare(
        "SELECT type, COALESCE(SUM(amount),0) AS total "
        "FROM transactions "
        "WHERE substr(occurred_on,1,7) = :m "
        "GROUP BY type");
    q.bindValue(":m", month);
    if (!q.exec()) { qWarning() << "[Budget] summary:" << q.lastError().text(); return s; }
    while (q.next()) {
        const auto type  = static_cast<TxType>(q.value("type").toInt());
        const Money total = q.value("total").toLongLong();
        if (type == TxType::Income) s.income  = total;
        else                        s.expense = total;
    }
    s.remaining = s.income - s.expense;
    return s;
}

QVector<CategoryTotal> BudgetService::expensesByCategory(const QString& month) const
{
    QVector<CategoryTotal> out;
    QSqlQuery q(m_db->connection());
    q.prepare(
        "SELECT t.category_id AS cid, "
        "       COALESCE(c.name,'بدون تصنيف') AS name, "
        "       COALESCE(c.color,'#64748B')   AS color, "
        "       SUM(t.amount) AS total "
        "FROM transactions t "
        "LEFT JOIN categories c ON c.id = t.category_id "
        "WHERE t.type = 0 AND substr(t.occurred_on,1,7) = :m "
        "GROUP BY t.category_id "
        "ORDER BY total DESC");
    q.bindValue(":m", month);
    if (!q.exec()) { qWarning() << "[Budget] byCategory:" << q.lastError().text(); return out; }
    while (q.next()) {
        CategoryTotal ct;
        ct.categoryId = q.value("cid").toLongLong();
        ct.name       = q.value("name").toString();
        ct.color      = q.value("color").toString();
        ct.total      = q.value("total").toLongLong();
        out.push_back(ct);
    }
    return out;
}

QVector<DailyTotal> BudgetService::dailyTotals(const QString& month) const
{
    QVector<DailyTotal> out;
    QSqlQuery q(m_db->connection());
    q.prepare(
        "SELECT occurred_on AS d, "
        "       COALESCE(SUM(CASE WHEN type=0 THEN amount END),0) AS exp, "
        "       COALESCE(SUM(CASE WHEN type=1 THEN amount END),0) AS inc "
        "FROM transactions "
        "WHERE substr(occurred_on,1,7) = :m "
        "GROUP BY occurred_on "
        "ORDER BY occurred_on");
    q.bindValue(":m", month);
    if (!q.exec()) { qWarning() << "[Budget] daily:" << q.lastError().text(); return out; }
    while (q.next()) {
        DailyTotal dt;
        dt.date    = q.value("d").toString();
        dt.expense = q.value("exp").toLongLong();
        dt.income  = q.value("inc").toLongLong();
        out.push_back(dt);
    }
    return out;
}

Money BudgetService::plannedSalary(const QString& month) const
{
    QSqlQuery q(m_db->connection());
    q.prepare("SELECT planned_salary FROM monthly_income_plan WHERE month=?");
    q.addBindValue(month);
    if (q.exec() && q.next())
        return q.value(0).toLongLong();
    return 0;
}

bool BudgetService::setPlannedSalary(const QString& month, Money amount)
{
    QSqlQuery q(m_db->connection());
    q.prepare("INSERT INTO monthly_income_plan(month,planned_salary) VALUES(?,?) "
              "ON CONFLICT(month) DO UPDATE SET planned_salary=excluded.planned_salary");
    q.addBindValue(month);
    q.addBindValue(amount);
    if (!q.exec()) { qWarning() << "[Budget] setPlanned:" << q.lastError().text(); return false; }
    return true;
}

Money BudgetService::remainingVsPlan(const QString& month) const
{
    const Money planned = plannedSalary(month);
    const Money spent   = monthlySummary(month).expense;
    return planned - spent;
}

} // namespace bt
