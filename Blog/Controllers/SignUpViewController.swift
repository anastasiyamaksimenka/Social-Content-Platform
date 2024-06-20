//
//  SignUpViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // Header View
    private let headerView = SignInHeaderView()
    
    // Name field
    private let nameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Full Name"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Email Address"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Password field
    private let passwordField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Password"
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        
        // Add eye button for toggling password visibility
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        eyeButton.tintColor = .gray
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        field.rightView = eyeButton
        field.rightViewMode = .always
        
        return field
    }()
    
    // Sign Up button
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height / 3)
        
        nameField.frame = CGRect(x: 20, y: headerView.frame.origin.y + headerView.frame.size.height - 55 , width: view.frame.width - 40, height: 50)
        emailField.frame = CGRect(x: 20, y: nameField.frame.origin.y + nameField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        signUpButton.frame = CGRect(x: 20, y: passwordField.frame.origin.y + passwordField.frame.size.height + 30, width: view.frame.width - 40, height: 50)
    }
    
    @objc private func didTapSignUp() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty else {
            // Show alert if any field is empty
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        HapticsManager.shared.vibrateForSelection()
        
        // Create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            if success {
                // Update database
                let newUser = User(name: name, email: email, profilePictureUrlRef: nil)
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }
                    
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    
                    DispatchQueue.main.async {
                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                print("Failed to create account")
            }
        }
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordField.isSecureTextEntry.toggle()
        
        // Fix to retain the password text when toggling
        if let existingText = passwordField.text, passwordField.isSecureTextEntry {
            passwordField.deleteBackward()
            passwordField.insertText(existingText)
        } else if let existingText = passwordField.text {
            passwordField.text = nil
            passwordField.insertText(existingText)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
