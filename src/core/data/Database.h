#pragma once
#include <QString>
#include <QSqlDatabase>

namespace bt {

// Owns the SQLite connection and is responsible for:
//   * opening the database file
//   * applying schema migrations (versioned via PRAGMA user_version)
//   * seeding default categories on first run
//
// One Database instance == one connection. Pass it to repositories/services.
class Database {
public:
    Database();
    ~Database();

    // Opens (creating if needed) the SQLite file at `path`, enables foreign
    // keys + WAL, then migrates and seeds. Returns false on failure.
    bool open(const QString& path);
    void close();

    bool isOpen() const;
    QSqlDatabase connection() const { return m_db; }

    // Current schema version stored in the DB (PRAGMA user_version).
    int schemaVersion() const;

private:
    bool applyPragmas();
    bool migrate();          // runs all migrations newer than current version
    bool seedDefaults();     // inserts starter categories if table is empty

    QSqlDatabase m_db;
    QString      m_connectionName;
};

} // namespace bt
