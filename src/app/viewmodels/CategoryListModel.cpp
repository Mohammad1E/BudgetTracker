#include "viewmodels/CategoryListModel.h"

namespace bt {

CategoryListModel::CategoryListModel(Database* db, QObject* parent)
    : QAbstractListModel(parent), m_db(db), m_repo(db)
{
    reload();
}

int CategoryListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_items.size());
}

QVariant CategoryListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};
    const Category& c = m_items.at(index.row());
    switch (role) {
        case IdRole:    return c.id;
        case NameRole:  return c.name;
        case TypeRole:  return static_cast<int>(c.type);
        case ColorRole: return c.color;
        default:        return {};
    }
}

QHash<int, QByteArray> CategoryListModel::roleNames() const
{
    return {
        { IdRole,    "catId" },
        { NameRole,  "name" },
        { TypeRole,  "catType" },
        { ColorRole, "color" },
    };
}

void CategoryListModel::reload()
{
    beginResetModel();
    m_items = m_repo.list(false);
    endResetModel();
}

qint64 CategoryListModel::idAt(int row) const
{
    if (row < 0 || row >= m_items.size()) return 0;
    return m_items.at(row).id;
}

QString CategoryListModel::nameAt(int row) const
{
    if (row < 0 || row >= m_items.size()) return {};
    return m_items.at(row).name;
}

} // namespace bt
