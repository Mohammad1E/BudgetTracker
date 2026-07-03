#pragma once
#include <QVector>
#include "domain/Person.h"

namespace bt {

class Database;

class PersonRepository {
public:
    explicit PersonRepository(Database* db);

    QVector<Person> list(bool includeArchived = false) const;
    qint64 insert(const Person& p);     // returns new id, 0 on failure
    bool   update(const Person& p);
    bool   setArchived(qint64 id, bool archived);

private:
    Database* m_db;   // not owned
};

} // namespace bt
