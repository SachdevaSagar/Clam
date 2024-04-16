//
//  NetworkManager.swift
//  QuikRoute
//
//  Created by TPSS on 06/08/20.
//  Copyright © 2020 Jates Co. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}
struct ErrorObject: Codable{
    var error:String
    var errorDescription:String
    
    enum CodingKeys: String, CodingKey {
        case error = "error"
        case errorDescription = "error_description"
    }
}

public enum Result<String> {
    case success
    case failure(String)
    case badrequest(String)
}

public enum NetworkError : String, Error {
    case noURL = "URL is nil"
    case noParameters =   "Parameter is nil"
    case failedToEncode = "Failed to encode parameters"
}

public enum NetworkResponse : String {
    case success
    case authenticationError = "Authentication error."
    case badRequest = "Bad requrest."
    case outdated = "The url is outdate. Please use new one."
    case failed = "Network request failed."
    case noData = "Server returned no data."
    case unableToDecode = "Unable to decode the server response"
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init(){}
    
    private var task:URLSessionDataTask?
    private let requestTimeoutInterval = 60.0
    
    func request(method:HTTPMethod,baseUrl:String,endPoint:EndPoint, parameters:Parameter? = [:],httpHeader:HTTPHeader? = [:], parameterEncoding:EncodingType? = .httpBodyAsQueryString, putId:String? = "", getId:String? = "", completionHandler: @escaping (_ data:Data?,_ error:String?) -> ()){
        
        let session = URLSession.shared
        guard var url = URL(string: "\(baseUrl)\(endPoint.rawValue)") else {
            return
        }
       
        if getId != "" {
            url.appendPathComponent("\(getId ?? "")")
        }
        if method == .PUT{
            url = URL(string: "\(baseUrl)\(endPoint.rawValue)\(putId!)")!
        }
        print("url\(url)")
        print("parameters\(parameters ?? [:])")
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: requestTimeoutInterval)
        request.httpMethod = method.rawValue
        
        createRequest(requeset: &request, parameters: parameters, httpHeaders: httpHeader, parameterEncoding: parameterEncoding)
        
       
        
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if data != nil{
                
            }
//            let responseDATA = String(data: data!, encoding: .utf8)
//            print(responseDATA)
           guard let httpResponse = response as? HTTPURLResponse,
                 (200...299).contains(httpResponse.statusCode) else {
               print("Server Error")
                    completionHandler(nil,NetworkResponse.failed.rawValue)
               return
           }
            
            let httpURLResponse = response as? HTTPURLResponse
            let responseStatus = self?.handleResponse(response: httpURLResponse!)
            
            switch responseStatus {
            case .success:
                print("")
                
                if  data != nil {
                    
                    completionHandler(data,nil)
                    
//                    do {
//                        let loggedInUser = try JSONDecoder().decode(LoggedInUser.self, from: data!)
//
//                        print("loggedInUser \(loggedInUser.lastNameFirstName)")
//
//                        //let obj: Result = try JSONDecoder().decode(Result.self, from: data)
//                        //let json = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments,.mutableContainers])
//                    } catch {
//                        // Failed to decode
//                        print(error)
//                    }
                }else{
                    completionHandler(nil,NetworkResponse.noData.rawValue)
                    // no data returned error
                }
                case .badrequest:
                           
                print("");
                
                if  data != nil {
                    var errorMessage = ""
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorObject.self, from: data!)
                        errorMessage = errorObject.errorDescription
                        
                    }catch{
                        
                    }
                    completionHandler(nil,errorMessage)
                    
                }else{
                    completionHandler(nil,NetworkResponse.noData.rawValue)
                }
            case .failure(let networkFailureError):
                completionHandler(nil,networkFailureError)
            case .none:
                print("")
            }
        })
        task?.resume()
    }
    
    private func createRequest(requeset:inout URLRequest, parameters:Parameter?, httpHeaders:HTTPHeader?, parameterEncoding:EncodingType? = .httpBody ){
        if parameters?.count ?? 0 > 0{
            configureParameters(requeset: &requeset, parameters: parameters!,parameterEncoding: parameterEncoding!)
        }
        if httpHeaders?.count ?? 0 > 0{
            configureHTTPHeaders(request: &requeset, httpHeaders: httpHeaders!)
        }
    }
    
    private func configureHTTPHeaders(request:inout URLRequest, httpHeaders:HTTPHeader){
        
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func configureParameters(requeset:inout URLRequest, parameters:Parameter , parameterEncoding:EncodingType){
        
        switch parameterEncoding {
        case .httpBody:
            do{
                try ParameterEncoder().encodeHttpBodyParameters(request: &requeset, parameters: parameters)
            }catch{
                
            }
        case .queryString:
            do{
                try ParameterEncoder().encodeQueryStringParameters(request: &requeset, parameters: parameters)
            }catch{
                
            }
        case .httpBodyAsQueryString:
            do{
                try ParameterEncoder().encodeHttpBodyAsQueryString(request: &requeset, parameters: parameters)
            }catch{
                
            }
        case .httpBodyImage:
            do{
                try ParameterEncoder().encodeHttpBodyWithImageParameters(request: &requeset, parameters: parameters)
            }catch{
                
            }
            
        }
    }
    
    private func handleResponse(response:HTTPURLResponse) -> Result<String> {
        
        switch response.statusCode {
        case 200...299:
            return .success
            
        case 401...499:
            return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599:
            return .failure(NetworkResponse.badRequest.rawValue)
        case 600:
            return .failure(NetworkResponse.outdated.rawValue)
        default:
            return .failure(NetworkResponse.failed.rawValue)
        }
        
    }
}
