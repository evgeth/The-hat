//
//  Date + Extension.swift
//  thehat
//
//  Created by Nikita Lobanov on 17.02.2022.
//  Copyright © 2022 dpfbop. All rights reserved.
//

import Foundation

extension Date {
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
