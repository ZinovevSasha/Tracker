//
//  Date+Extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.04.2023.
//

import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
}

func dateString(for date: Date) -> String {
    Date.dateFormatter.dateFormat = "yyyy-MM-dd"
    return Date.dateFormatter.string(from: date)
}
