#pragma once
#include <QVector>
#include <QString>
#include "domain/Transaction.h"

namespace bt {

class Database;

// CRUD + filtered queries for transactions.
class TransactionRepository {
public:
    explicit TransactionRepository(Database* db);

    // Optional filter for list(). Empty/zero fields are ignored.
    struct Filter {
        QString month;        // "YYYY-MM"  (empty = all months)
        int     type   = -1;  // -1 = both, 0 = expense, 1 = income
        qint64  categoryId = 0;
        qint64  personId   = 0;
        QString search;       // matches note / category / person name
    };

    QVector<Transaction> list(const Filter& f = {}) const;
    bool                 getById(qint64 id, Transaction& out) const;

    qint64 insert(const Transaction& t);   // returns new id, 0 on failure
    bool   update(const Transaction& t);
    bool   remove(qint64 id);

private:
    Database* m_db;   // not owned
};

} // namespace bt
