//
//  AuthorProfileViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 11/06/2024.
//

import UIKit

class AuthorProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var author: User?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                           forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()
    
    private let authorEmail: String
    
    init(author: User) {
        self.authorEmail = author.email
        self.author = author
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
        title = nil
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
    }
    
    private func setUpTableHeader(profilePhotoUrl: String? = nil, name: String? = nil) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width / 3))
        headerView.backgroundColor = .systemBackground
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        tableView.tableHeaderView = headerView
        
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(x: (view.frame.width - (view.frame.width / 4)) / 2,
                                    y: (headerView.frame.height - (view.frame.width / 4)) / 2.5,
                                    width: view.frame.width / 4,
                                    height: view.frame.width / 4)
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        headerView.addSubview(profilePhoto)
        
        if let name = name {
            title = name
        }
        
        if let ref = profilePhotoUrl {
            StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
    
    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: authorEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.author = user
            DispatchQueue.main.async {
                self?.setUpTableHeader(
                    profilePhotoUrl: user.profilePictureUrlRef,
                    name: user.name)
            }
        }
    }
    
    private var posts: [BlogPost] = []
    
    private func fetchPosts() {
        DatabaseManager.shared.getPosts(for: authorEmail) { [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifier, for: indexPath) as? PostPreviewTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = ViewPostViewController(
            post: posts[indexPath.row],
            isOwnedByCurrentUser: false
        )
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
}
