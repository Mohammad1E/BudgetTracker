#include "services/ImportExportService.h"
#include "data/Database.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

ImportExportService::ImportExportService(Database* db) : m_db(db) {}

static QJsonArray queryToArray(QSqlDatabase db, const QString& sql,
                               const QStringList& cols)
{
    QJsonArray arr;
    QSqlQuery q(db);
    if (!q.exec(sql)) { qWarning() << "[Export]" << q.lastError().text(); return arr; }
    while (q.next()) {
        QJsonObject o;
        for (const QString& c : cols)
            o[c] = QJsonValue::fromVariant(q.value(c));
        arr.append(o);
    }
    return arr;
}

bool ImportExportService::exportToJson(const QString& filePath) const
{
    auto db = m_db->connection();
    QJsonObject root;
    root["version"]    = 1;
    root["exportedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

    root["categories"] = queryToArray(db,
        "SELECT id,name,type,color,icon,parent_id FROM categories",
        {"id","name","type","color","icon","parent_id"});
    root["people"] = queryToArray(db,
        "SELECT id,name,phone,note FROM people",
        {"id","name","phone","note"});
    root["transactions"] = queryToArray(db,
        "SELECT id,type,amount,currency,occurred_on,category_id,person_id,note "
        "FROM transactions",
        {"id","type","amount","currency","occurred_on","category_id","person_id","note"});

    QFile f(filePath);
    if (!f.open(QIODevice::WriteOnly)) {
        qWarning() << "[Export] cannot write" << filePath << f.errorString();
        return false;
    }
    f.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    return true;
}

bool ImportExportService::importFromJson(const QString& filePath, bool replaceExisting)
{
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly)) {
        qWarning() << "[Import] cannot read" << filePath << f.errorString();
        return false;
    }
    QJsonParseError err;
    const QJsonDocument doc = QJsonDocument::fromJson(f.readAll(), &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "[Import] bad JSON:" << err.errorString();
        return false;
    }
    const QJsonObject root = doc.object();
    auto db = m_db->connection();

    if (!db.transaction()) return false;
    QSqlQuery q(db);

    if (replaceExisting) {
        for (const char* t : {"transactions", "budgets", "people", "categories"})
            q.exec(QString("DELETE FROM %1").arg(t));
    }

    for (const QJsonValue v : root["categories"].toArray()) {
        const QJsonObject o = v.toObject();
        q.prepare("INSERT INTO categories(id,name,type,color,icon,parent_id) "
                  "VALUES(?,?,?,?,?,?)");
        q.addBindValue(o["id"].toVariant());
        q.addBindValue(o["name"].toString());
        q.addBindValue(o["type"].toInt());
        q.addBindValue(o["color"].toString("#64748B"));
        q.addBindValue(o["icon"].toVariant());
        q.addBindValue(o["parent_id"].toVariant());
        if (!q.exec()) { qWarning() << "[Import] cat:" << q.lastError().text(); }
    }

    for (const QJsonValue v : root["people"].toArray()) {
        const QJsonObject o = v.toObject();
        q.prepare("INSERT INTO people(id,name,phone,note) VALUES(?,?,?,?)");
        q.addBindValue(o["id"].toVariant());
        q.addBindValue(o["name"].toString());
        q.addBindValue(o["phone"].toVariant());
        q.addBindValue(o["note"].toVariant());
        if (!q.exec()) { qWarning() << "[Import] person:" << q.lastError().text(); }
    }

    for (const QJsonValue v : root["transactions"].toArray()) {
        const QJsonObject o = v.toObject();
        q.prepare("INSERT INTO transactions"
                  "(type,amount,currency,occurred_on,category_id,person_id,note) "
                  "VALUES(?,?,?,?,?,?,?)");
        q.addBindValue(o["type"].toInt());
        q.addBindValue(static_cast<qint64>(o["amount"].toDouble()));
        q.addBindValue(o["currency"].toString("JOD"));
        q.addBindValue(o["occurred_on"].toString());
        q.addBindValue(o["category_id"].toVariant());
        q.addBindValue(o["person_id"].toVariant());
        q.addBindValue(o["note"].toVariant());
        if (!q.exec()) { qWarning() << "[Import] tx:" << q.lastError().text(); }
    }

    return db.commit();
}

} // namespace bt
