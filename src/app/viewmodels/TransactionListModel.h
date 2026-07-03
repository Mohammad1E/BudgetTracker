#pragma once
#include <QAbstractListModel>
#include <QVector>
#include "domain/Transaction.h"
#include "data/TransactionRepository.h"

namespace bt {

class Database;

// Exposes a filtered list of transactions to QML (ListView / TableView /
// Repeater). Filtering is by month + type for the MVP.
class TransactionListModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TypeRole,            // int (0/1)
        IsExpenseRole,       // bool
        AmountMinorRole,     // qint64
        AmountTextRole,      // "12.50"
        SignedAmountTextRole,// "-12.50" / "+12.50"
        CurrencyRole,
        DateTextRole,        // "2026-06-15"
        CategoryRole,        // name
        CategoryColorRole,
        PersonRole,          // name
        NoteRole,
    };

    explicit TransactionListModel(Database* db, QObject* parent = nullptr);

    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Re-query using the current filter.
    void reload();

    void setMonth(const QString& month);     // "YYYY-MM" ("" = all)
    void setTypeFilter(int type);            // -1 both, 0 expense, 1 income

    QString month() const { return m_filter.month; }

private:
    Database*                m_db;   // not owned
    TransactionRepository    m_repo;
    TransactionRepository::Filter m_filter;
    QVector<Transaction>     m_items;
};

} // namespace bt
