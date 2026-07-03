#include "viewmodels/AppController.h"
#include "data/Database.h"
#include "services/BudgetService.h"

#include <QDate>
#include <QUrl>
#include <QVariantMap>
#include <cmath>

namespace bt {

AppController::AppController(Database* db, QObject* parent)
    : QObject(parent)
    , m_db(db)
    , m_txRepo(db)
    , m_catRepo(db)
    , m_personRepo(db)
    , m_importExport(db)
{
    m_month = QDate::currentDate().toString("yyyy-MM");

    m_transactions = new TransactionListModel(db, this);
    m_dashboard    = new DashboardViewModel(db, this);
    m_categories   = new CategoryListModel(db, this);
    m_people       = new PersonListModel(db, this);

    m_transactions->setMonth(m_month);
    m_dashboard->setMonth(m_month);
}

void AppController::setCurrentMonth(const QString& month)
{
    if (m_month == month) return;
    m_month = month;
    m_transactions->setMonth(month);
    m_dashboard->setMonth(month);
    emit currentMonthChanged();
}

void AppController::addTransaction(int type, double amount, const QString& isoDate,
                                   qint64 categoryId, qint64 personId,
                                   const QString& note)
{
    Transaction t;
    t.type       = (type == 1) ? TxType::Income : TxType::Expense;
    t.amount     = static_cast<Money>(std::llround(amount * 100.0)); // -> minor units
    t.currency   = m_currency;
    t.date       = isoDate.isEmpty() ? QDate::currentDate()
                                     : QDate::fromString(isoDate, "yyyy-MM-dd");
    t.categoryId = categoryId;
    t.personId   = personId;
    t.note       = note;

    if (m_txRepo.insert(t) > 0)
        refreshAll();
}

void AppController::removeTransaction(qint64 id)
{
    if (m_txRepo.remove(id))
        refreshAll();
}

void AppController::addCategory(const QString& name, int type, const QString& color)
{
    if (name.trimmed().isEmpty()) return;
    Category c;
    c.name  = name.trimmed();
    c.type  = (type == 1) ? TxType::Income : TxType::Expense;
    c.color = color.isEmpty() ? "#3B82F6" : color;
    if (m_catRepo.insert(c) > 0) {
        m_categories->reload();
        emit dataChanged();
    }
}

void AppController::addPerson(const QString& name, const QString& phone)
{
    if (name.trimmed().isEmpty()) return;
    Person p;
    p.name  = name.trimmed();
    p.phone = phone;
    if (m_personRepo.insert(p) > 0) {
        m_people->reload();
        emit dataChanged();
    }
}

bool AppController::exportJson(const QString& fileUrlOrPath)
{
    return m_importExport.exportToJson(toLocalPath(fileUrlOrPath));
}

bool AppController::importJson(const QString& fileUrlOrPath)
{
    const bool ok = m_importExport.importFromJson(toLocalPath(fileUrlOrPath), true);
    if (ok) refreshAll();
    return ok;
}

void AppController::setTransactionTypeFilter(int type)
{
    m_transactions->setTypeFilter(type);
}

QVariantList AppController::expenseByCategory() const
{
    BudgetService service(m_db);
    QVariantList out;
    const auto rows = service.expensesByCategory(m_month);
    for (const auto& r : rows) {
        QVariantMap m;
        m["name"]       = r.name;
        m["color"]      = r.color;
        m["value"]      = static_cast<qlonglong>(r.total);
        m["amountText"] = QString::number(r.total / 100.0, 'f', 2);
        out.push_back(m);
    }
    return out;
}

void AppController::goToPreviousMonth()
{
    const QDate d = QDate::fromString(m_month + "-01", "yyyy-MM-dd").addMonths(-1);
    setCurrentMonth(d.toString("yyyy-MM"));
}

void AppController::goToNextMonth()
{
    const QDate d = QDate::fromString(m_month + "-01", "yyyy-MM-dd").addMonths(1);
    setCurrentMonth(d.toString("yyyy-MM"));
}

void AppController::refreshAll()
{
    m_transactions->reload();
    m_dashboard->refresh();
    m_categories->reload();
    m_people->reload();
    emit dataChanged();
}

QString AppController::toLocalPath(const QString& fileUrlOrPath)
{
    if (fileUrlOrPath.startsWith("file:"))
        return QUrl(fileUrlOrPath).toLocalFile();
    return fileUrlOrPath;
}

} // namespace bt
