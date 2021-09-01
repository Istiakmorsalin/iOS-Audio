//
//  Category.swift
//  Listen-to-News
//
//  Created by Jakob Mikkelsen on 21/02/2020.
//  Copyright © 2020 Listen to news. All rights reserved.
//

import UIKit

struct Category: Codable {
    let id: Int
    let name: String?
    var identifier: String?
    let color: String?
    let image: String?
    var subscribed: Bool?
    var description: String?
}
