//
//  JSONDecoder.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import Foundation

extension JSONDecoder {
    static var istiakCast: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
