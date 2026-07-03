#pragma once
#include <QString>
#include <QDate>
#include "domain/Types.h"

namespace bt {

// One income or expense record.
// `categoryName` / `personName` are filled by repository JOINs for display
// convenience; they are NOT persisted columns.
struct Transaction {
    qint64  id         = 0;
    TxType  type       = TxType::Expense;
    Money   amount     = 0;          // minor units, always positive
    QString currency   = "JOD";
    QDate   date       = QDate::currentDate();   // occurred_on
    qint64  categoryId = 0;          // 0 = none
    qint64  personId   = 0;          // 0 = none
    qint64  accountId  = 0;          // 0 = none
    QString note;

    // joined / display-only
    QString categoryName;
    QString categoryColor;
    QString personName;
};

} // namespace bt
