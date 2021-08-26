//
//  APIAlamofireDriver.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit
import Alamofire
import Cashier

class APIAlamofireDriver: APIManagerProtocol {
    
    private var baseURL: String = ""
    private var headers: HTTPHeaders = ["auth": "",
                                        "Content-Type": "application/json"]
    
    private var cache: Cashier! {
        let cache = NOPersistentStore.cache(withId: "\(APIAlamofireDriver.self)")
        cache?.persistent = true
        return cache
    }
    
    func setup(withBaseURL baseURL: String) {
        self.baseURL = baseURL
    }
    
    func setAuthorizationHeader(withAccessToken accessToken: String) {
        headers["auth"] = accessToken
    }
    
    func removeAuthorizationHeader() {
        headers["auth"] = ""
    }

    func callAPI<T>(of type: T.Type, decoder: JSONDecoder, withRequest request: APIRequest, completion: @escaping (Result<T, APIError>) -> Void) where T : Codable {

        var parameters = request.parameters == nil ? [String: Any]() : (request.parameters! as Parameters)
        parameters["auth"] = headers["auth"]
        
        var queryString = "?" + generateQueryString(from: parameters)
        if headers["auth"]?.isEmpty ?? true {
            queryString = ""
        }
        
        // If the method is not .get - we want to add it as a parameter
        var tmpParamenter: Parameters? = nil
        if request.method != .get {
            do {
                tmpParamenter = parameters
                queryString = ""
            }
        }
        if request.excludeAuth {
            tmpParamenter?.removeValue(forKey: "auth")
        }
        let url = baseURL + request.endpoint.rawValue + queryString
        
        // MARK: Return the cached data for this url if possible
        if request.isCacheAllowed, let cachedData = self.cache.data(forKey: request.endpoint.rawValue + queryString) {
            do {
                let decodedCachedData = try JSONDecoder.istiakCast.decode(T.self, from: cachedData)
                print("[APIManager] - returning cached url", request.endpoint.rawValue + queryString)
                completion(.success(decodedCachedData))
            } catch let error {
                print(error)
            }
        }
        
        debugPrint(url)
        AF.request(url, method: HTTPMethod(rawValue: request.method.rawValue), parameters: tmpParamenter, encoding: JSONEncoding.default, headers: headers, interceptor: nil).validate().responseDecodable (decoder: decoder) { (response: DataResponse<T, AFError>) in
            
            switch response.result {
            case .success(let value):
                completion(.success(value))
                print("[APIManager] - returning live url", response.request?.urlRequest?.url ?? "")

                // Save the response data to json cache
                guard request.isCacheAllowed else { return }
                
                do {
                    let encoded = try JSONEncoder().encode(value)
                    self.cache.setData(encoded, forKey: request.endpoint.rawValue + queryString)
                } catch let error {
                    print(error)
                }
                
            case .failure(let error):
                
                if error.asAFError?.responseCode == 401 {
                    debugPrint("Not authorized - show logins screen.")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "401ErrorShowAuthView"), object: nil)
                }
                
                completion(.failure(APIError(statusCode: error._code, localizedDescription: error.localizedDescription)))
                
            }
        }
        
    }
    
    func downloadFile(withURL url: URL, toDestination destination: URL, progressBlock: @escaping (_ progress: Double) -> Void, completion: @escaping (Result<Data, APIError>) -> Void) {
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (destination, [.removePreviousFile, .createIntermediateDirectories])
        }

        let utilityQueue = DispatchQueue.global(qos: .background)
        AF.download(url, to: destination).downloadProgress(queue: utilityQueue, closure: { (progress) in
            // progressBlock(progress.fractionCompleted)
        }).responseData { response in
            if let data = response.value {
                completion(.success(data))
            } else if let error = response.error, error._code != NSURLErrorTimedOut {
                let errorDesc = error.localizedDescription + "\n" + (error.underlyingError?.localizedDescription ?? "")
                completion(.failure(APIError(statusCode: error.responseCode ?? 0, localizedDescription: errorDesc)))
            }
        }
        
    }
 
    
    // MARK: - Helper function
    
    private func generateQueryString(from parameters: [String: Any?]?) -> String {
        guard let parameters = parameters?.sorted(by: { $0.key < $1.key }) else { return "" }
        
        var queryString = ""
        parameters.forEach { item in
            if let value = item.value {
                queryString += "\(item.key)=\(value)&"
            }
        }
        if queryString.last != nil { queryString.removeLast() }
        //plus was turning into white space when turned into data
        queryString = queryString.replacingOccurrences(of: "+", with: "%2B")
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
}

