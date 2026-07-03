#include "data/PersonRepository.h"
#include "data/Database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

PersonRepository::PersonRepository(Database* db) : m_db(db) {}

QVector<Person> PersonRepository::list(bool includeArchived) const
{
    QVector<Person> out;
    QString sql = "SELECT id,name,phone,note,is_archived FROM people ";
    if (!includeArchived) sql += "WHERE is_archived = 0 ";
    sql += "ORDER BY name";

    QSqlQuery q(m_db->connection());
    if (!q.exec(sql)) { qWarning() << "[PersonRepo] list:" << q.lastError().text(); return out; }
    while (q.next()) {
        Person p;
        p.id       = q.value("id").toLongLong();
        p.name     = q.value("name").toString();
        p.phone    = q.value("phone").toString();
        p.note     = q.value("note").toString();
        p.archived = q.value("is_archived").toInt() != 0;
        out.push_back(p);
    }
    return out;
}

qint64 PersonRepository::insert(const Person& p)
{
    QSqlQuery q(m_db->connection());
    q.prepare("INSERT INTO people(name,phone,note) VALUES(?,?,?)");
    q.addBindValue(p.name);
    q.addBindValue(p.phone.isEmpty() ? QVariant() : p.phone);
    q.addBindValue(p.note.isEmpty()  ? QVariant() : p.note);
    if (!q.exec()) { qWarning() << "[PersonRepo] insert:" << q.lastError().text(); return 0; }
    return q.lastInsertId().toLongLong();
}

bool PersonRepository::update(const Person& p)
{
    QSqlQuery q(m_db->connection());
    q.prepare("UPDATE people SET name=?, phone=?, note=? WHERE id=?");
    q.addBindValue(p.name);
    q.addBindValue(p.phone.isEmpty() ? QVariant() : p.phone);
    q.addBindValue(p.note.isEmpty()  ? QVariant() : p.note);
    q.addBindValue(p.id);
    if (!q.exec()) { qWarning() << "[PersonRepo] update:" << q.lastError().text(); return false; }
    return true;
}

bool PersonRepository::hasTransactions(qint64 id) const
{
    QSqlQuery q(m_db->connection());
    q.prepare("SELECT 1 FROM transactions WHERE person_id=? LIMIT 1");
    q.addBindValue(id);
    if (!q.exec()) { qWarning() << "[PersonRepo] hasTransactions:" << q.lastError().text(); return true; }
    return q.next();
}

bool PersonRepository::remove(qint64 id)
{
    QSqlQuery q(m_db->connection());
    q.prepare("DELETE FROM people WHERE id=?");
    q.addBindValue(id);
    if (!q.exec()) { qWarning() << "[PersonRepo] remove:" << q.lastError().text(); return false; }
    return true;
}

bool PersonRepository::setArchived(qint64 id, bool archived)
{
    QSqlQuery q(m_db->connection());
    q.prepare("UPDATE people SET is_archived=? WHERE id=?");
    q.addBindValue(archived ? 1 : 0);
    q.addBindValue(id);
    return q.exec();
}

} // namespace bt
