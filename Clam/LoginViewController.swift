//
//  ViewController.swift
//  Clam
//
//  Created by TechPrastish on 15/04/24.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    
    
    private var cancellables = Set<AnyCancellable>()
    let validations = Validations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text else {
            showAlert(message: "Email or password text field is nil")
            return
        }
        
        do {
            let validatedEmail = try validations.validateEmail(email)
            let validatedPassword = try validations.validatePassword(password)
            login(email: validatedEmail, password: validatedPassword)
        } catch let error {
            if let validationError = error as? ValidationError {
                showAlert(message: validationError.error ?? "Unknown validation error")
            } else {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func login(email: String, password: String) {
        authenticateUser(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { loggedInUser in
                if let success = loggedInUser.success, success == 1 {
                    let token = self.isValueString(loggedInUser.accessToken as Any)
                    let nextVc = StoryBoard.HOME.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    nextVc.token = token
                    self.navigationController?.pushViewController(nextVc, animated: true)
                } else {
                    self.showAlert(message: loggedInUser.message ?? "Login failed")
                }
            })
            .store(in: &cancellables)
    }

    private func authenticateUser(email: String, password: String) -> AnyPublisher<LoggedInUser, Error> {
        let url = URL(string: NetworkRequestEndPoint().baseUrl + EndPoint.login.rawValue)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "device_id": "",
            "current_date": currentDate,
            "platform": "ios",
            "role": "client"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> LoggedInUser in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoder = JSONDecoder()
                let loggedInUser = try decoder.decode(LoggedInUser.self, from: data)
                return loggedInUser
            }
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    var currentDate: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //2021-02-11 14:38:50 //yyyy-MM-dd hh:mm:ss +zzzz
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateInFormat = formatter.string(from: date)
        return dateInFormat
    }
}

