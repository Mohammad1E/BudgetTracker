#pragma once
#include <QString>
#include "domain/Types.h"

namespace bt {

struct Category {
    qint64  id       = 0;
    QString name;
    TxType  type     = TxType::Expense;
    QString color    = "#3B82F6";
    QString icon;                 // optional icon name
    qint64  parentId = 0;         // 0 = top-level
    bool    archived = false;
};

} // namespace bt
