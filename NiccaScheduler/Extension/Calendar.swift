//
//  extensions.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/06/15.
//

import Foundation

extension Calendar {
    // https://qiita.com/tamadeveloper/items/8e4f68d586cc5b0f9a5a

    //MARK: - Day operations

    func endOfDay(for date:Date) -> Date {
        return nextDay(for: date)
    }

    func previousDay(for date:Date) -> Date {
        return move(date, byDays: -1)
    }

    func nextDay(for date:Date) -> Date {
        return move(date, byDays: 1)
    }

    //MARK: - Move operation

    func move(_ date:Date, byDays days:Int) -> Date {
        return self.date(byAdding: .day, value: days, to: startOfDay(for: date))!
    }
}
