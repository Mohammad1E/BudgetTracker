#pragma once
#include <QString>
#include "domain/Types.h"

namespace bt {

// A wallet / bank account / cash source. MVP can use a single default account.
struct Account {
    qint64  id             = 0;
    QString name;
    Money   openingBalance = 0;       // minor units
    QString currency       = "JOD";
    bool    archived       = false;
};

} // namespace bt
