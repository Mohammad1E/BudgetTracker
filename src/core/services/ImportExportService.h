#pragma once
#include <QString>

namespace bt {

class Database;

// Phase-1 "sync": dump the whole database to a portable JSON file and load it
// back. This is the offline, no-server backup/restore + manual-sync mechanism.
//
// JSON shape (version 1):
// {
//   "version": 1,
//   "exportedAt": "2026-06-15T17:00:00Z",
//   "categories": [ { "id":.., "name":.., "type":.., "color":.. }, ... ],
//   "people":     [ { "id":.., "name":.., "phone":.., "note":.. }, ... ],
//   "transactions":[ { "type":.., "amount":.., "currency":.., "date":..,
//                      "categoryId":.., "personId":.., "note":.. }, ... ]
// }
class ImportExportService {
public:
    explicit ImportExportService(Database* db);

    // Writes the full DB to `filePath`. Returns false on failure.
    bool exportToJson(const QString& filePath) const;

    // Reads `filePath`. If replaceExisting, clears tables first (full restore);
    // otherwise appends imported rows (simple merge).
    bool importFromJson(const QString& filePath, bool replaceExisting = true);

private:
    Database* m_db;   // not owned
};

} // namespace bt
