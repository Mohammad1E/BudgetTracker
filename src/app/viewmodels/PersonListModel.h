#pragma once
#include <QAbstractListModel>
#include <QVector>
#include "domain/Person.h"
#include "data/PersonRepository.h"

namespace bt {

class Database;

class PersonListModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        PhoneRole,
    };

    explicit PersonListModel(Database* db, QObject* parent = nullptr);

    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reload();

    Q_INVOKABLE qint64 idAt(int row) const;     // row 0 reserved meaning handled in QML

private:
    Database*         m_db;   // not owned
    PersonRepository  m_repo;
    QVector<Person>   m_items;
};

} // namespace bt
