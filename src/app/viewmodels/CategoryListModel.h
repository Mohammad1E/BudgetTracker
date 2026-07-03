#pragma once
#include <QAbstractListModel>
#include <QVector>
#include "domain/Category.h"
#include "data/CategoryRepository.h"

namespace bt {

class Database;

// List of categories for management pages and for the picker in the
// add/edit dialog.
class CategoryListModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        TypeRole,        // int 0/1
        ColorRole,
    };

    explicit CategoryListModel(Database* db, QObject* parent = nullptr);

    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reload();

    // Helpers usable from QML.
    Q_INVOKABLE qint64 idAt(int row) const;
    Q_INVOKABLE QString nameAt(int row) const;

private:
    Database*           m_db;   // not owned
    CategoryRepository  m_repo;
    QVector<Category>   m_items;
};

} // namespace bt
