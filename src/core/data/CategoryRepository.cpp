#include "data/CategoryRepository.h"
#include "data/Database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

CategoryRepository::CategoryRepository(Database* db) : m_db(db) {}

QVector<Category> CategoryRepository::list(bool includeArchived) const
{
    QVector<Category> out;
    QString sql = "SELECT id,name,type,color,icon,parent_id,is_archived FROM categories ";
    if (!includeArchived) sql += "WHERE is_archived = 0 ";
    sql += "ORDER BY type DESC, name";

    QSqlQuery q(m_db->connection());
    if (!q.exec(sql)) { qWarning() << "[CatRepo] list:" << q.lastError().text(); return out; }
    while (q.next()) {
        Category c;
        c.id       = q.value("id").toLongLong();
        c.name     = q.value("name").toString();
        c.type     = static_cast<TxType>(q.value("type").toInt());
        c.color    = q.value("color").toString();
        c.icon     = q.value("icon").toString();
        c.parentId = q.value("parent_id").toLongLong();
        c.archived = q.value("is_archived").toInt() != 0;
        out.push_back(c);
    }
    return out;
}

qint64 CategoryRepository::insert(const Category& c)
{
    QSqlQuery q(m_db->connection());
    q.prepare("INSERT INTO categories(name,type,color,icon,parent_id) VALUES(?,?,?,?,?)");
    q.addBindValue(c.name);
    q.addBindValue(static_cast<int>(c.type));
    q.addBindValue(c.color);
    q.addBindValue(c.icon.isEmpty() ? QVariant() : c.icon);
    q.addBindValue(c.parentId > 0 ? QVariant(c.parentId) : QVariant());
    if (!q.exec()) { qWarning() << "[CatRepo] insert:" << q.lastError().text(); return 0; }
    return q.lastInsertId().toLongLong();
}

bool CategoryRepository::update(const Category& c)
{
    QSqlQuery q(m_db->connection());
    q.prepare("UPDATE categories SET name=?, type=?, color=?, icon=?, parent_id=? WHERE id=?");
    q.addBindValue(c.name);
    q.addBindValue(static_cast<int>(c.type));
    q.addBindValue(c.color);
    q.addBindValue(c.icon.isEmpty() ? QVariant() : c.icon);
    q.addBindValue(c.parentId > 0 ? QVariant(c.parentId) : QVariant());
    q.addBindValue(c.id);
    if (!q.exec()) { qWarning() << "[CatRepo] update:" << q.lastError().text(); return false; }
    return true;
}

int CategoryRepository::transactionCount(qint64 id) const
{
    QSqlQuery q(m_db->connection());
    q.prepare("SELECT COUNT(*) FROM transactions WHERE category_id=?");
    q.addBindValue(id);
    if (!q.exec() || !q.next()) {
        qWarning() << "[CatRepo] transactionCount:" << q.lastError().text();
        return 0;
    }
    return q.value(0).toInt();
}

bool CategoryRepository::remove(qint64 id)
{
    QSqlQuery q(m_db->connection());
    q.prepare("DELETE FROM categories WHERE id=?");
    q.addBindValue(id);
    if (!q.exec()) { qWarning() << "[CatRepo] remove:" << q.lastError().text(); return false; }
    return true;
}

bool CategoryRepository::setArchived(qint64 id, bool archived)
{
    QSqlQuery q(m_db->connection());
    q.prepare("UPDATE categories SET is_archived=? WHERE id=?");
    q.addBindValue(archived ? 1 : 0);
    q.addBindValue(id);
    return q.exec();
}

} // namespace bt
