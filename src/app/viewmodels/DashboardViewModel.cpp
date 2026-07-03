#include "viewmodels/DashboardViewModel.h"
#include <QDate>

namespace bt {

static QString fmt(Money minor) { return QString::number(minor / 100.0, 'f', 2); }

DashboardViewModel::DashboardViewModel(Database* db, QObject* parent)
    : QObject(parent), m_db(db), m_service(db)
{
    m_month = QDate::currentDate().toString("yyyy-MM");
    refresh();
}

QString DashboardViewModel::incomeText() const    { return fmt(m_summary.income); }
QString DashboardViewModel::expenseText() const    { return fmt(m_summary.expense); }
QString DashboardViewModel::remainingText() const  { return fmt(m_summary.remaining); }

void DashboardViewModel::setMonth(const QString& month)
{
    if (m_month == month) return;
    m_month = month;
    refresh();
}

void DashboardViewModel::refresh()
{
    m_summary = m_service.monthlySummary(m_month);
    emit changed();
}

} // namespace bt
