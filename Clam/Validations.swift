//
//  Validations.swift
//  Clam
//
//  Created by TechPrastish on 15/04/24.
//

import Foundation

struct Validations {
    
    func validateEmail(_ email: String?) throws -> String {
        guard let email = email else { throw ValidationError.invalidInput }
        guard Validation.isValidEmail(email) else  { throw ValidationError.invalidEmail }
        return email
    }
    func validatePassword(_ password: String?) throws -> String {
        guard let password = password else { throw ValidationError.invalidInput }
        guard password.count > 5 else { throw ValidationError.shortPassword }
        return password
    }
}


enum ValidationError: LocalizedError {
    
    case invalidInput
    case invalidEmail
    case shortPassword
    
    var error: String? {
        switch self {
        case .invalidInput:
            return "Pleas enter valid input"
        case .invalidEmail:
            return "You have entered wrong email address"
        case .shortPassword:
            return "Password is too short"
        }
    }
}
