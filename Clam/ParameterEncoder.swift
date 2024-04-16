//
//  QueryStringParameterEncoding.swift
//  QuikRoute
//
//  Created by TPSS on 06/08/20.
//  Copyright © 2020 Jates Co. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices


public typealias Parameter = [String:Any]
public typealias HTTPHeader = [String:String]

enum EncodingType {
    case queryString
    case httpBody
    case httpBodyAsQueryString
    case httpBodyImage
}


public struct ParameterEncoder {
    
    public func encodeQueryStringParameters(request:inout URLRequest,parameters:Parameter) throws {
        guard let url = request.url else {
            throw NetworkError.noURL
        }
        
        var urlQueryItem:[URLQueryItem] = []
        
        for (key, value) in parameters {
            urlQueryItem.append(URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = urlQueryItem
        request.url = urlComponents?.url
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("Application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
    
    public func encodeHttpBodyAsQueryString(request:inout URLRequest, parameters:Parameter) throws {
        do {
            guard let url = request.url else {
                throw NetworkError.noURL
            }
            
            var urlQueryItem:[URLQueryItem] = []
            for (key, value) in parameters {
                urlQueryItem.append(URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
            }
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = urlQueryItem
            let urlStringComponents = urlComponents?.url?.absoluteString.components(separatedBy: "?")
            let queryString = urlStringComponents?.last ?? ""
            request.httpBody = queryString.data(using: String.Encoding.utf8);
            request.httpMethod = HTTPMethod.POST.rawValue
            //            if request.value(forHTTPHeaderField: "Content-type") == nil {
            //                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            //            }
        }
    }
    
    
    public func encodeHttpBodyParameters(request:inout URLRequest, parameters:Parameter) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            if request.value(forHTTPHeaderField: "Content-type") == nil {
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch{
            throw NetworkError.failedToEncode
        }
    }
    
    
    //IMAGE UPLOADING:-
    
    public func encodeHttpBodyWithImageParameters1(request:inout URLRequest, parameters:Parameter) throws {
        let body = NSMutableData()
        let boundary = "Boundary-\(UUID().uuidString)"
        let boundaryPrefix = " — \(boundary)\r\n"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let mimeType = "image/jpg"
       
        for (key, value) in parameters {
            
            if(value is String || value is NSString){
                body.appendString(boundaryPrefix)//.data(using: .utf8)!)//") appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")//.data(using: .utf8)!)// appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")//.data(using: .utf8)!)// .appendString("\(value)\r\n")
                
            } else if(value is [UIImage]){
                
                var dataArray = [Data]()
                for (_,image) in (value as! [UIImage]).enumerated(){
                    if let data = image.jpegData(compressionQuality: 0.1){
                        dataArray.append(data)
                    }
                }
                
                
                for (index,data) in dataArray.enumerated(){
//                    let filename = "image\(index)\(Date().ToLocalStringWithFormat(dateFormat: "yyyy-MM-dd-hh-mm-ss")).jpg"
//                    body.appendString(boundaryPrefix)
//                    body.appendString("Content-Disposition: form-data; name=\"image[\(index)]\"; filename=\"\(filename)\"\r\n")
//                    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//                    body.append(data)
//                    body.appendString("\r\n")
                }
            }
            body.appendString(" — ".appending(boundary.appending(" — ")))
        }
        
        
        
        
        request.httpBody = body as Data
        request.httpMethod = HTTPMethod.POST.rawValue
        
        
    }
    
    
    public func encodeHttpBodyWithImageParameters(request:inout URLRequest, parameters:Parameter) throws {
        
        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            request.httpBody = jsonData
//            if request.value(forHTTPHeaderField: "Content-type") == nil {
//                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
//            }
//        }catch{
//            throw NetworkError.failedToEncode
//        }
        
        
        
        let body = NSMutableData()
        let boundary = "Boundary-\(UUID().uuidString)"
        let boundaryPrefix = " — \(boundary)\r\n"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let mimeType = "image/png"

        var params:[String:Any] = [:]
        for (key, value) in parameters {

            if(value is String || value is NSString){
                body.appendString(boundaryPrefix)//.data(using: .utf8)!)//") appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")//.data(using: .utf8)!)// appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")//.data(using: .utf8)!)// .appendString("\(value)\r\n")
                let jsonData = try JSONSerialization.data(withJSONObject:[key:value], options: [])
                body.append(jsonData)
                params[key] = value
            } else if(value is [UIImage]){

                var dataArray = [Data]()
                for (_,image) in (value as! [UIImage]).enumerated(){
                    if let data = image.jpegData(compressionQuality: 1.0){
                        dataArray.append(data)
                        
                    }
                }
                params[key] = value
                let jsonData = try JSONSerialization.data(withJSONObject:[key:dataArray], options: [])
                               body.append(jsonData)
                
                for (index,data) in dataArray.enumerated(){

//                    let filename = "image\(index)\(Date().ToLocalStringWithFormat(dateFormat: "yyyy-MM-dd-hh-mm-ss"))"
//                    body.appendString(boundaryPrefix)
//                    body.appendString("Content-Disposition: form-data; name=\"image[\(index)]\"; filename=\"\(filename)\"\r\n")
//                    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//                    body.append(data)
//                    body.appendString("\r\n")
                }
            }
        }
       // body.appendString(" — ".appending(boundary.appending(" — ")))

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            request.httpBody = jsonData
            if request.value(forHTTPHeaderField: "Content-type") == nil {
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch{
            throw NetworkError.failedToEncode
        }
        print("request \(request)")
        
    }
    
    
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
