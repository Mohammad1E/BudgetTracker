#include "viewmodels/TransactionListModel.h"

#include <QLocale>

namespace bt {

static QString money(Money minor)
{
    return QString::number(minor / 100.0, 'f', 2);
}

TransactionListModel::TransactionListModel(Database* db, QObject* parent)
    : QAbstractListModel(parent), m_db(db), m_repo(db)
{
    reload();
}

int TransactionListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_items.size());
}

QVariant TransactionListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};
    const Transaction& t = m_items.at(index.row());
    const bool expense = (t.type == TxType::Expense);
    switch (role) {
        case IdRole:               return t.id;
        case TypeRole:             return static_cast<int>(t.type);
        case IsExpenseRole:        return expense;
        case AmountMinorRole:      return t.amount;
        case AmountTextRole:       return money(t.amount);
        case SignedAmountTextRole: return (expense ? "-" : "+") + money(t.amount);
        case CurrencyRole:         return t.currency;
        case DateTextRole:         return t.date.toString("yyyy-MM-dd");
        case CategoryRole:         return t.categoryName.isEmpty() ? QStringLiteral("—") : t.categoryName;
        case CategoryColorRole:    return t.categoryColor.isEmpty() ? QStringLiteral("#64748B") : t.categoryColor;
        case PersonRole:           return t.personName;
        case NoteRole:             return t.note;
        default:                   return {};
    }
}

QHash<int, QByteArray> TransactionListModel::roleNames() const
{
    return {
        { IdRole,                "txId" },
        { TypeRole,              "txType" },
        { IsExpenseRole,         "isExpense" },
        { AmountMinorRole,       "amountMinor" },
        { AmountTextRole,        "amountText" },
        { SignedAmountTextRole,  "signedAmount" },
        { CurrencyRole,          "currency" },
        { DateTextRole,          "dateText" },
        { CategoryRole,          "categoryName" },
        { CategoryColorRole,     "categoryColor" },
        { PersonRole,            "personName" },
        { NoteRole,              "note" },
    };
}

void TransactionListModel::reload()
{
    beginResetModel();
    m_items = m_repo.list(m_filter);
    endResetModel();
}

void TransactionListModel::setMonth(const QString& month)
{
    if (m_filter.month == month) return;
    m_filter.month = month;
    reload();
}

void TransactionListModel::setTypeFilter(int type)
{
    if (m_filter.type == type) return;
    m_filter.type = type;
    reload();
}

} // namespace bt
