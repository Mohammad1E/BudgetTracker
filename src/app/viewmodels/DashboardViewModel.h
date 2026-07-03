#pragma once
#include <QObject>
#include <QString>
#include "services/BudgetService.h"

namespace bt {

class Database;

// Exposes the headline numbers for the current month to QML.
// Bind in QML as:  App.dashboard.remainingText, .incomeText, .expenseText
class DashboardViewModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString month        READ month        NOTIFY changed)
    Q_PROPERTY(QString incomeText    READ incomeText    NOTIFY changed)
    Q_PROPERTY(QString expenseText   READ expenseText   NOTIFY changed)
    Q_PROPERTY(QString remainingText READ remainingText NOTIFY changed)
    Q_PROPERTY(bool    isNegative    READ isNegative    NOTIFY changed)
    Q_PROPERTY(QString currency      READ currency      NOTIFY changed)
public:
    explicit DashboardViewModel(Database* db, QObject* parent = nullptr);

    QString month() const          { return m_month; }
    QString incomeText() const;
    QString expenseText() const;
    QString remainingText() const;
    bool    isNegative() const     { return m_summary.remaining < 0; }
    QString currency() const       { return m_currency; }

    void setMonth(const QString& month);
    void setCurrency(const QString& c) { m_currency = c; emit changed(); }
    void refresh();

signals:
    void changed();

private:
    Database*      m_db;       // not owned
    BudgetService  m_service;
    QString        m_month;
    QString        m_currency = "JOD";
    MonthlySummary m_summary;
};

} // namespace bt
