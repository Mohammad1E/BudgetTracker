#include "data/Database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

namespace bt {

// Bump this when you add a new migration step below.
static constexpr int kTargetSchemaVersion = 1;

Database::Database() : m_connectionName("bt_main") {}

Database::~Database() { close(); }

bool Database::isOpen() const { return m_db.isValid() && m_db.isOpen(); }

bool Database::open(const QString& path)
{
    if (QSqlDatabase::contains(m_connectionName))
        m_db = QSqlDatabase::database(m_connectionName);
    else
        m_db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);

    m_db.setDatabaseName(path);
    if (!m_db.open()) {
        qWarning() << "[Database] open failed:" << m_db.lastError().text();
        return false;
    }
    if (!applyPragmas())  return false;
    if (!migrate())       return false;
    if (!seedDefaults())  return false;

    qInfo() << "[Database] ready at" << path << "schema v" << schemaVersion();
    return true;
}

void Database::close()
{
    if (m_db.isOpen())
        m_db.close();
    m_db = QSqlDatabase();
    if (QSqlDatabase::contains(m_connectionName))
        QSqlDatabase::removeDatabase(m_connectionName);
}

int Database::schemaVersion() const
{
    QSqlQuery q(m_db);
    if (q.exec("PRAGMA user_version") && q.next())
        return q.value(0).toInt();
    return -1;
}

bool Database::applyPragmas()
{
    QSqlQuery q(m_db);
    // Enforce relations and use WAL for better concurrent read/write.
    if (!q.exec("PRAGMA foreign_keys = ON"))   { qWarning() << q.lastError(); return false; }
    if (!q.exec("PRAGMA journal_mode = WAL"))  { qWarning() << q.lastError(); return false; }
    return true;
}

// ---- Migrations ------------------------------------------------------------
// Each migration takes the DB from version N-1 to N. To evolve the schema,
// add a new `if (from < 2) { ... }` block and bump kTargetSchemaVersion.
bool Database::migrate()
{
    const int from = schemaVersion();
    if (from >= kTargetSchemaVersion)
        return true;

    if (!m_db.transaction()) {
        qWarning() << "[Database] cannot begin migration tx:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery q(m_db);
    auto run = [&](const char* sql) -> bool {
        if (!q.exec(QString::fromUtf8(sql))) {
            qWarning() << "[Database] migration SQL failed:" << q.lastError().text()
                       << "\n  >>" << sql;
            return false;
        }
        return true;
    };

    // ---- v1: initial schema ----
    if (from < 1) {
        const char* schema[] = {
            "CREATE TABLE categories ("
            "  id          INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  name        TEXT    NOT NULL,"
            "  type        INTEGER NOT NULL,"                 // 0=expense 1=income
            "  color       TEXT    NOT NULL DEFAULT '#3B82F6',"
            "  icon        TEXT,"
            "  parent_id   INTEGER REFERENCES categories(id) ON DELETE SET NULL,"
            "  is_archived INTEGER NOT NULL DEFAULT 0,"
            "  created_at  TEXT    NOT NULL DEFAULT (datetime('now')))",

            "CREATE TABLE people ("
            "  id          INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  name        TEXT    NOT NULL,"
            "  phone       TEXT,"
            "  note        TEXT,"
            "  is_archived INTEGER NOT NULL DEFAULT 0,"
            "  created_at  TEXT    NOT NULL DEFAULT (datetime('now')))",

            "CREATE TABLE accounts ("
            "  id              INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  name            TEXT    NOT NULL,"
            "  opening_balance INTEGER NOT NULL DEFAULT 0,"
            "  currency        TEXT    NOT NULL DEFAULT 'JOD',"
            "  is_archived     INTEGER NOT NULL DEFAULT 0,"
            "  created_at      TEXT    NOT NULL DEFAULT (datetime('now')))",

            "CREATE TABLE transactions ("
            "  id          INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  type        INTEGER NOT NULL,"                 // 0=expense 1=income
            "  amount      INTEGER NOT NULL,"                 // minor units, positive
            "  currency    TEXT    NOT NULL DEFAULT 'JOD',"
            "  occurred_on TEXT    NOT NULL,"                 // 'YYYY-MM-DD'
            "  category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,"
            "  person_id   INTEGER REFERENCES people(id)     ON DELETE SET NULL,"
            "  account_id  INTEGER REFERENCES accounts(id)   ON DELETE SET NULL,"
            "  note        TEXT,"
            "  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),"
            "  updated_at  TEXT    NOT NULL DEFAULT (datetime('now')))",

            "CREATE INDEX idx_tx_occurred_on ON transactions(occurred_on)",
            "CREATE INDEX idx_tx_category    ON transactions(category_id)",
            "CREATE INDEX idx_tx_person      ON transactions(person_id)",
            "CREATE INDEX idx_tx_type        ON transactions(type)",

            "CREATE TABLE budgets ("
            "  id             INTEGER PRIMARY KEY AUTOINCREMENT,"
            "  month          TEXT    NOT NULL,"              // 'YYYY-MM'
            "  category_id    INTEGER REFERENCES categories(id) ON DELETE CASCADE,"
            "  planned_amount INTEGER NOT NULL,"
            "  UNIQUE(month, category_id))",

            "CREATE TABLE monthly_income_plan ("
            "  month          TEXT PRIMARY KEY,"              // 'YYYY-MM'
            "  planned_salary INTEGER NOT NULL DEFAULT 0)",
        };
        for (const char* stmt : schema)
            if (!run(stmt)) { m_db.rollback(); return false; }
    }

    // ---- future migrations go here ----
    // if (from < 2) { ... }

    if (!run("PRAGMA user_version = 1")) { m_db.rollback(); return false; }

    if (!m_db.commit()) {
        qWarning() << "[Database] migration commit failed:" << m_db.lastError().text();
        return false;
    }
    return true;
}

bool Database::seedDefaults()
{
    QSqlQuery q(m_db);
    if (!q.exec("SELECT COUNT(*) FROM categories") || !q.next())
        return false;
    if (q.value(0).toInt() > 0)
        return true;   // already seeded / user data present

    struct Seed { const char* name; int type; const char* color; };
    const Seed seeds[] = {
        { "الراتب",     1, "#16A34A" },
        { "مكافأة",      1, "#22C55E" },
        { "طعام",        0, "#EF4444" },
        { "مواصلات",     0, "#F59E0B" },
        { "فواتير",      0, "#3B82F6" },
        { "تسوّق",       0, "#A855F7" },
        { "صحة",         0, "#06B6D4" },
        { "ترفيه",       0, "#EC4899" },
        { "أخرى",        0, "#64748B" },
    };

    if (!m_db.transaction()) return false;
    for (const auto& s : seeds) {
        q.prepare("INSERT INTO categories(name,type,color) VALUES(?,?,?)");
        q.addBindValue(QString::fromUtf8(s.name));
        q.addBindValue(s.type);
        q.addBindValue(QString::fromUtf8(s.color));
        if (!q.exec()) { qWarning() << q.lastError(); m_db.rollback(); return false; }
    }
    return m_db.commit();
}

} // namespace bt
