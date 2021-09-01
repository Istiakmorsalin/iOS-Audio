//
//  APIManagerProtocol.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

struct APIError: Error {
    let statusCode: Int
    let localizedDescription: String
}

struct APIRequest {
    let endpoint: APIEndpoint
    let method: APIMethod
    let isCacheAllowed: Bool
    let parameters: [String : Any?]?
    let excludeAuth: Bool
    
    init(endpoint: APIEndpoint, method: APIMethod, isCacheAllowed: Bool, parameters: [String : Any?]?, excludeAuth: Bool = false) {
        self.endpoint = endpoint
        self.method = method
        self.isCacheAllowed = isCacheAllowed
        self.parameters = parameters
        self.excludeAuth = excludeAuth
    }
}

enum APIMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public struct APIEndpoint: RawRepresentable, Equatable, Hashable {
    
    //
    // MARK: - THIS ARE ENDPOINTS
    //
    /// `get All clips`
    public static let getAllClips = APIEndpoint(rawValue: "/api/v1/projects/DG2hZB09UGec39fqB127ZQtt")

    
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}

protocol APIManagerProtocol {
    func setup(withBaseURL baseURL: String)
    func setAuthorizationHeader(withAccessToken accessToken: String)
    func removeAuthorizationHeader()
    func callAPI<T: Codable>(of type: T.Type, decoder: JSONDecoder, withRequest request: APIRequest, completion: @escaping (Result<T, APIError>) -> Void)
    func downloadFile(withURL url: URL, toDestination destination: URL, progressBlock: @escaping (_ progress: Double) -> Void, completion: @escaping (Result<Data, APIError>) -> Void)
}
