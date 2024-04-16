//
//  extentions.swift
//  Clam
//
//  Created by TechPrastish on 15/04/24.
//

import Foundation
import UIKit

protocol Convertible {
    func convertToString() -> String
}

extension Int: Convertible {
    func convertToString() -> String {
        return String(self)
    }
}

extension Double: Convertible {
    func convertToString() -> String {
        return String(self)
    }
}

extension String: Convertible {
    func convertToString() -> String {
        return self
    }
}

extension UIViewController {
    func isValueString(_ value: Any) -> String {
        if let convertibleValue = value as? Convertible {
            return convertibleValue.convertToString()
        } else {
            return "0"
        }
    }
}

struct Validation {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct StoryBoard {
    static let HOME = UIStoryboard.init(name: "Home", bundle: Bundle.main)
}


enum NetworkEnvironment {
    case development
    case staging
    case live
}

struct NetworkRequestEndPoint {
    var networkEnvironment:NetworkEnvironment = .development
    
    var baseUrl : String {
        
        switch networkEnvironment {
        case .development:
            return  "https://admin.reclam.ca/"
        case .staging:
            return "https://admin.reclam.ca/"
        case .live:
            return "https://admin.reclam.ca/"
        }
    }
}

enum EndPoint : String {
    case register = "api/register"
    case login = "api/login"
}
public enum PopupButtons{
    case cancel
    case ok
    
    
}
extension UIViewController {
    
    func ShowPopupDialog(title: String, message: String, imageName: String, buttons: [PopupButtons]? = [], autoDismissAfter: Int? = 1000000)  {
        DispatchQueue.main.async {
            
            
        }
    }
}
