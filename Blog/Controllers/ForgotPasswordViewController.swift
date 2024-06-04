//
//  ForgotPasswordViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 21/04/2024.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UITabBarController {

    // Header View
    private let headerView = SignInHeaderView()

    // Email text field
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Email Address"
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    //reset button
    private let resetButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Forgot Password"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(resetButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height / 3)
        
        emailField.frame = CGRect(x: 20, y: headerView.frame.origin.y + headerView.frame.size.height - 60, width: view.frame.width - 40, height: 50)
        resetButton.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 30, width: view.frame.width - 40, height: 50)
    }

    @objc func resetPassword() {
        guard let email = emailField.text, !email.isEmpty else {
            // Show error message if email is empty
            print("Please enter your email")
            return
        }
        
        // Send password reset email using Firebase
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Password reset error: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully")
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }
}
