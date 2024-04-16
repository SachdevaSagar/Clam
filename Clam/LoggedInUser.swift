//
//  LoggedInUser.swift
//  QuikRoute
//
//  Created by TPSS on 08/08/20.
//  Copyright © 2020 Jates Co. All rights reserved.
//

import Foundation

struct LoggedInUser: Codable {
    
    var success : Int?
    var message : String?
    var accessToken: String?
   
    enum CodingKeys : String, CodingKey {
        case success
        case message
        case accessToken="access_token"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Int.self, forKey: .success)
        message = try container.decode(String.self, forKey: .message)
        accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}
