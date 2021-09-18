//
//  APIManager.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

class APIManager: APIManagerProtocol {
    
    public static let shared = APIManager()
    
    private var baseURL: String = "https://api.audioboom.com/"
    private let drivers: [APIManagerProtocol]
    
    init() {
        drivers = [APIAlamofireDriver()]
    }
    
    func setup(withBaseURL baseURL: String) {
        drivers.forEach { $0.setup(withBaseURL: baseURL) }
    }
    
    func setAuthorizationHeader(withAccessToken accessToken: String) {
        drivers.forEach { $0.setAuthorizationHeader(withAccessToken: accessToken) }
    }
    
    func removeAuthorizationHeader() {
        drivers.forEach { $0.removeAuthorizationHeader() }
    }
    
    func callAPI<T: Codable>(of type: T.Type, decoder: JSONDecoder, withRequest request: APIRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        drivers.forEach { $0.callAPI(of: type, decoder: decoder, withRequest: request, completion: completion) }
    }
    
    func downloadFile(withURL url: URL, toDestination destination: URL, progressBlock: @escaping (Double) -> Void, completion: @escaping (Result<Data, APIError>) -> Void) {
        drivers.forEach { $0.downloadFile(withURL: url, toDestination: destination, progressBlock: progressBlock, completion: completion) }
    }
    
}
