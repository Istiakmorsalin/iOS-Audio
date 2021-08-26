//
//  Clips.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

class Clip: Codable {
    var id: Int
    var title: String
    var body: String
    var link: String
    
    init(id: Int, title: String, body: String, link: String) {
        self.id = id
        self.title = title
        self.body = body
        self.link = link
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, body, link
    }
}
