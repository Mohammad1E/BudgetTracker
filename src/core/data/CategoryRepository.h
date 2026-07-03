#pragma once
#include <QVector>
#include "domain/Category.h"

namespace bt {

class Database;

class CategoryRepository {
public:
    explicit CategoryRepository(Database* db);

    // includeArchived = false hides archived categories.
    QVector<Category> list(bool includeArchived = false) const;
    qint64 insert(const Category& c);     // returns new id, 0 on failure
    bool   update(const Category& c);
    int    transactionCount(qint64 id) const;
    bool   remove(qint64 id);
    bool   setArchived(qint64 id, bool archived);

private:
    Database* m_db;   // not owned
};

} // namespace bt
