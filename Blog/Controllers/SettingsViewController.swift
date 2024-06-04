//
//  SettingsViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 24/04/2024.
//

import UIKit
import FirebaseAuth
import FirebaseD// Ensure Firebase is imported

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        
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
    
    @objc private func didTapDeleteProfile() {
        // Show an alert for confirmation before deletion
        let alertController = UIAlertController(title: "Delete Profile",
                                                message: "Are you sure you want to delete your profile? This action cannot be undone.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteProfileFromFirebase()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteProfileFromFirebase() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        // Delete the user's profile from Firebase
        let userId = user.uid
        let userRef = Database.database().reference().child("users").child(userId)
        
        userRef.removeValue { error, _ in
            if let error = error {
                // Handle the error
                print("Failed to delete user profile: \(error.localizedDescription)")
                self.showDeletionResultAlert(success: false)
                return
            }
            
            // Also delete the user's authentication record
            user.delete { error in
                if let error = error {
                    // Handle the error
                    print("Failed to delete user authentication record: \(error.localizedDescription)")
                    self.showDeletionResultAlert(success: false)
                    return
                }
                
                // Successfully deleted the profile
                print("User profile deleted successfully.")
                self.showDeletionResultAlert(success: true)
            }
        }
    }
    
    private func showDeletionResultAlert(success: Bool) {
        let title = success ? "Profile Deleted" : "Deletion Failed"
        let message = success ? "Your profile has been deleted successfully." : "There was an error deleting your profile. Please try again later."
        
        let resultAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        resultAlertController.addAction(okAction)
        
        present(resultAlertController, animated: true, completion: nil)
        
        if success {
            // Optionally, navigate the user to the login screen or another appropriate screen
            // For example:
            // self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
