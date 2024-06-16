//
//  ForgotPasswordViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 21/04/2024.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

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
    
    // Reset button
    private let resetButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
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
            showAlert(title: "Error", message: "Please enter your email.")
            return
        }
        
        // Send password reset email using Firebase
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showAlert(title: "Error", message: "Password reset error: \(error.localizedDescription)")
            } else {
                strongSelf.showAlert(title: "Success", message: "Password reset email sent successfully.", completion: {
                    strongSelf.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    // Helper function to show alert
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true, completion: nil)
    }
}
