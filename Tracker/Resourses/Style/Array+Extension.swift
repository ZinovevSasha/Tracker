//
//  Array+Extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.04.2023.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
