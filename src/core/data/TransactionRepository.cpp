#include "data/TransactionRepository.h"
#include "data/Database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

TransactionRepository::TransactionRepository(Database* db) : m_db(db) {}

static Transaction readRow(const QSqlQuery& q)
{
    Transaction t;
    t.id           = q.value("id").toLongLong();
    t.type         = static_cast<TxType>(q.value("type").toInt());
    t.amount       = q.value("amount").toLongLong();
    t.currency     = q.value("currency").toString();
    t.date         = QDate::fromString(q.value("occurred_on").toString(), "yyyy-MM-dd");
    t.categoryId   = q.value("category_id").toLongLong();
    t.personId     = q.value("person_id").toLongLong();
    t.accountId    = q.value("account_id").toLongLong();
    t.note         = q.value("note").toString();
    t.categoryName = q.value("category_name").toString();
    t.categoryColor= q.value("category_color").toString();
    t.personName   = q.value("person_name").toString();
    return t;
}

QVector<Transaction> TransactionRepository::list(const Filter& f) const
{
    QVector<Transaction> out;
    QString sql =
        "SELECT t.*, c.name AS category_name, c.color AS category_color, "
        "       p.name AS person_name "
        "FROM transactions t "
        "LEFT JOIN categories c ON c.id = t.category_id "
        "LEFT JOIN people     p ON p.id = t.person_id "
        "WHERE 1=1 ";

    if (!f.month.isEmpty())  sql += "AND substr(t.occurred_on,1,7) = :month ";
    if (f.type >= 0)         sql += "AND t.type = :type ";
    if (f.categoryId > 0)    sql += "AND t.category_id = :cat ";
    if (f.personId > 0)      sql += "AND t.person_id = :person ";
    if (!f.search.isEmpty()) sql += "AND (t.note LIKE :s OR c.name LIKE :s OR p.name LIKE :s) ";
    sql += "ORDER BY t.occurred_on DESC, t.id DESC";

    QSqlQuery q(m_db->connection());
    q.prepare(sql);
    if (!f.month.isEmpty())  q.bindValue(":month", f.month);
    if (f.type >= 0)         q.bindValue(":type", f.type);
    if (f.categoryId > 0)    q.bindValue(":cat", f.categoryId);
    if (f.personId > 0)      q.bindValue(":person", f.personId);
    if (!f.search.isEmpty()) q.bindValue(":s", "%" + f.search + "%");

    if (!q.exec()) { qWarning() << "[TxRepo] list:" << q.lastError().text(); return out; }
    while (q.next())
        out.push_back(readRow(q));
    return out;
}

bool TransactionRepository::getById(qint64 id, Transaction& out) const
{
    QSqlQuery q(m_db->connection());
    q.prepare(
        "SELECT t.*, c.name AS category_name, c.color AS category_color, "
        "       p.name AS person_name "
        "FROM transactions t "
        "LEFT JOIN categories c ON c.id = t.category_id "
        "LEFT JOIN people     p ON p.id = t.person_id "
        "WHERE t.id = ?");
    q.addBindValue(id);
    if (q.exec() && q.next()) { out = readRow(q); return true; }
    return false;
}

qint64 TransactionRepository::insert(const Transaction& t)
{
    QSqlQuery q(m_db->connection());
    q.prepare(
        "INSERT INTO transactions"
        "(type, amount, currency, occurred_on, category_id, person_id, account_id, note) "
        "VALUES(?,?,?,?,?,?,?,?)");
    q.addBindValue(static_cast<int>(t.type));
    q.addBindValue(t.amount);
    q.addBindValue(t.currency);
    q.addBindValue(t.date.toString("yyyy-MM-dd"));
    q.addBindValue(t.categoryId > 0 ? QVariant(t.categoryId) : QVariant());
    q.addBindValue(t.personId   > 0 ? QVariant(t.personId)   : QVariant());
    q.addBindValue(t.accountId  > 0 ? QVariant(t.accountId)  : QVariant());
    q.addBindValue(t.note);
    if (!q.exec()) { qWarning() << "[TxRepo] insert:" << q.lastError().text(); return 0; }
    return q.lastInsertId().toLongLong();
}

bool TransactionRepository::update(const Transaction& t)
{
    QSqlQuery q(m_db->connection());
    q.prepare(
        "UPDATE transactions SET "
        "type=?, amount=?, currency=?, occurred_on=?, category_id=?, person_id=?, "
        "account_id=?, note=?, updated_at=datetime('now') WHERE id=?");
    q.addBindValue(static_cast<int>(t.type));
    q.addBindValue(t.amount);
    q.addBindValue(t.currency);
    q.addBindValue(t.date.toString("yyyy-MM-dd"));
    q.addBindValue(t.categoryId > 0 ? QVariant(t.categoryId) : QVariant());
    q.addBindValue(t.personId   > 0 ? QVariant(t.personId)   : QVariant());
    q.addBindValue(t.accountId  > 0 ? QVariant(t.accountId)  : QVariant());
    q.addBindValue(t.note);
    q.addBindValue(t.id);
    if (!q.exec()) { qWarning() << "[TxRepo] update:" << q.lastError().text(); return false; }
    return true;
}

bool TransactionRepository::remove(qint64 id)
{
    QSqlQuery q(m_db->connection());
    q.prepare("DELETE FROM transactions WHERE id=?");
    q.addBindValue(id);
    if (!q.exec()) { qWarning() << "[TxRepo] remove:" << q.lastError().text(); return false; }
    return true;
}

} // namespace bt
