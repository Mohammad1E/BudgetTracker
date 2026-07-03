#pragma once
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QAbstractListModel>

#include "data/TransactionRepository.h"
#include "data/CategoryRepository.h"
#include "data/PersonRepository.h"
#include "services/ImportExportService.h"

#include "viewmodels/TransactionListModel.h"
#include "viewmodels/DashboardViewModel.h"
#include "viewmodels/CategoryListModel.h"
#include "viewmodels/PersonListModel.h"

namespace bt {

class Database;

// Root object exposed to QML as the context property "App".
// Owns the view-models and provides the actions the UI calls.
class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QAbstractListModel* transactions READ transactions CONSTANT)
    Q_PROPERTY(QAbstractListModel* categories   READ categories   CONSTANT)
    Q_PROPERTY(QAbstractListModel* people        READ people       CONSTANT)
    Q_PROPERTY(bt::DashboardViewModel* dashboard READ dashboard    CONSTANT)
    Q_PROPERTY(QString currentMonth READ currentMonth WRITE setCurrentMonth NOTIFY currentMonthChanged)
    Q_PROPERTY(QString currency     READ currency     NOTIFY currencyChanged)
public:
    explicit AppController(Database* db, QObject* parent = nullptr);

    QAbstractListModel* transactions() const { return m_transactions; }
    QAbstractListModel* categories()   const { return m_categories; }
    QAbstractListModel* people()       const { return m_people; }
    DashboardViewModel* dashboard()    const { return m_dashboard; }

    QString currentMonth() const { return m_month; }
    QString currency()     const { return m_currency; }
    void    setCurrentMonth(const QString& month);

    // ---- actions called from QML ----
    Q_INVOKABLE void addTransaction(int type, double amount, const QString& isoDate,
                                    qint64 categoryId, qint64 personId,
                                    const QString& note);
    Q_INVOKABLE void removeTransaction(qint64 id);

    Q_INVOKABLE void addCategory(const QString& name, int type, const QString& color);
    Q_INVOKABLE void addPerson(const QString& name, const QString& phone);

    // -1 = both, 0 = expense, 1 = income (affects the shared transactions model)
    Q_INVOKABLE void setTransactionTypeFilter(int type);

    // Report data for the current month: list of {name, color, amountText, value}.
    Q_INVOKABLE QVariantList expenseByCategory() const;

    // Accept either a plain path or a file:// URL (from QML FileDialog).
    Q_INVOKABLE bool exportJson(const QString& fileUrlOrPath);
    Q_INVOKABLE bool importJson(const QString& fileUrlOrPath);

    // Month navigation helpers for the UI.
    Q_INVOKABLE void goToPreviousMonth();
    Q_INVOKABLE void goToNextMonth();

signals:
    void currentMonthChanged();
    void currencyChanged();
    void dataChanged();   // emitted after any mutation so views can react

private:
    void refreshAll();
    static QString toLocalPath(const QString& fileUrlOrPath);

    Database* m_db;   // not owned

    // repositories used by the action methods
    TransactionRepository m_txRepo;
    CategoryRepository    m_catRepo;
    PersonRepository      m_personRepo;
    ImportExportService   m_importExport;

    // view-models (children of this, deleted automatically)
    TransactionListModel* m_transactions = nullptr;
    DashboardViewModel*   m_dashboard    = nullptr;
    CategoryListModel*    m_categories   = nullptr;
    PersonListModel*      m_people       = nullptr;

    QString m_month;
    QString m_currency = "JOD";
};

} // namespace bt
