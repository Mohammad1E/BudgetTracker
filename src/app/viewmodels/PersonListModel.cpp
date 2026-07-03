#include "viewmodels/PersonListModel.h"

namespace bt {

PersonListModel::PersonListModel(Database* db, QObject* parent)
    : QAbstractListModel(parent), m_db(db), m_repo(db)
{
    reload();
}

int PersonListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_items.size());
}

QVariant PersonListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};
    const Person& p = m_items.at(index.row());
    switch (role) {
        case IdRole:    return p.id;
        case NameRole:  return p.name;
        case PhoneRole: return p.phone;
        default:        return {};
    }
}

QHash<int, QByteArray> PersonListModel::roleNames() const
{
    return {
        { IdRole,    "personId" },
        { NameRole,  "name" },
        { PhoneRole, "phone" },
    };
}

void PersonListModel::reload()
{
    beginResetModel();
    m_items = m_repo.list(false);
    endResetModel();
}

qint64 PersonListModel::idAt(int row) const
{
    if (row < 0 || row >= m_items.size()) return 0;
    return m_items.at(row).id;
}

} // namespace bt
