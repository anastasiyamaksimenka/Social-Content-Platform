//
//  ViewPostViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import UIKit

class ViewPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let post: BlogPost
    private let isOwnedByCurrentUser: Bool

    init(post: BlogPost, isOwnedByCurrentUser: Bool = false) {
        self.post = post
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(PostHeaderTableViewCell.self, forCellReuseIdentifier: PostHeaderTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setupConstraints()

        if isOwnedByCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePost))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePost))
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func deletePost() {
        guard isOwnedByCurrentUser else {
            // Display an error message if the user doesn't own the post
            showAlert(title: "Error", message: "You don't have permission to delete this post.")
            return
        }
        
        // If user owns the post, show a confirmation dialog
        showAlert(title: "Delete Post", message: "Are you sure you want to delete this post?", confirmAction: {
            // Call the deletion logic
            self.deletePostConfirmed()
        })
    }

    private func deletePostConfirmed() {
        // Show a loading indicator while the deletion is being processed
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        // Simulate network deletion request (replace with actual network request)
        DispatchQueue.global().async {
            sleep(2) // Simulate network delay
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                // Handle success response
                self.showAlert(title: "Success", message: "The post has been deleted.", confirmAction: {
                    self.navigationController?.popViewController(animated: true)
                })
                
                // Handle error response (Uncomment if handling actual network request)
                // self.showAlert(title: "Error", message: "Failed to delete the post.")
            }
        }
    }

    private func showAlert(title: String, message: String, confirmAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let confirmAction = confirmAction {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                confirmAction()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func sharePost() {
        // Share post logic
        let shareText = "Check out this post:"
        if let postURL = URL(string: post.link) {
            let activityViewController = UIActivityViewController(activityItems: [shareText, postURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(activityViewController, animated: true, completion: nil)
        } else {
            // Handle the case where the URL is invalid
            let alert = UIAlertController(title: "Error", message: "Unable to share the post link.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = .systemFont(ofSize: 25, weight: .bold)
            cell.textLabel?.text = post.title
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostHeaderTableViewCell.identifier, for: indexPath) as? PostHeaderTableViewCell else {
                fatalError()
            }
            cell.selectionStyle = .none
            cell.configure(with: .init(imageUrl: post.headerImageUrl))
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = post.text
            return cell
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        switch index {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 250
        case 2:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
}
