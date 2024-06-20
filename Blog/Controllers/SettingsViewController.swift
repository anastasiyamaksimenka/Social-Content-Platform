//
//  SettingsViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 24/04/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        // Cancel Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Profile", for: .normal)
        deleteButton.addTarget(self, action: #selector(didTapDeleteProfile), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDeleteProfile() {
        // Show an alert for confirmation before deletion
        let alertController = UIAlertController(title: "Delete Profile", message: "Are you sure you want to delete your profile? This action cannot be undone.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteProfile()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteProfile() {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        // Delete user data from Firestore
        userRef.delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                // Show an error alert to the user
                self.showDeleteErrorAlert()
                return
            }
            
            // Delete user authentication account
            user.delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                    // Show an error alert to the user
                    self.showDeleteErrorAlert()
                    return
                }
                
                // Successfully deleted user
                print("User profile deleted successfully")
                // Optionally, navigate to a different screen or show a success message
                self.showDeleteSuccessAlert()
            }
        }
    }
    
    private func showDeleteSuccessAlert() {
        let successAlert = UIAlertController(title: "Success", message: "Your profile has been deleted successfully.", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Navigate to the Sign In screen
            let signInVC = SignInViewController()
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }))
        present(successAlert, animated: true, completion: nil)
    }
    
    private func showDeleteErrorAlert() {
        let errorAlert = UIAlertController(title: "Error", message: "There was an error deleting your profile. Please try again later.", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
