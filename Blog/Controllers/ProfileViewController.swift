//
//  ProfileViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var user: User?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                           forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()
    
    let currentEmail : String
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemFill
        setUpSignOutButton()
        setUpSettingsButton()
        setUpTable()
        title = nil
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
    }
    
    
    
    private func setUpTableHeader(profilePhotoUrl : String? = nil, name: String? = nil){
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width/3))
        headerView.backgroundColor = .systemFill
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        tableView.tableHeaderView = headerView
        
        //profile picture
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(x: (view.frame.width-(view.frame.width/4))/2,
                                    y: (headerView.frame.height-(view.frame.width/4))/2.5,
                                    width: view.frame.width/4,
                                    height: view.frame.width/4)
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width/2
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhoto.addGestureRecognizer(tap)
        
        if let name = name{
            title = name
        }
        
        if let ref = profilePhotoUrl{
            StorageManager.shared.downlodaUrlForProfilePicture(path: ref) { url in
                guard let url = url else{
                    return
                }
                let task = URLSession.shared.dataTask(with: url) {data, _, _ in
                    guard let data  = data else{
                        return
                    }
                    DispatchQueue.main.async{
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
        
    }
    
    private func setUpSettingsButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
    }
    
    @objc private func didTapProfilePhoto(){
        guard let myEmail = UserDefaults.standard.string(forKey: "email") else{
            return
        }
        
        guard myEmail == currentEmail else{
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func didTapSettings() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }
    
    private func fetchProfileData(){
        DatabaseManager.shared.getUser(email: currentEmail) {[weak self] user in
            guard let user = user else{
                return
            }
            self?.user = user
            DispatchQueue.main.async{
                self?.setUpTableHeader(
                    profilePhotoUrl: user.profilePictureUrlRef,
                    name: user.name)
            }
        }
    }
    
    
    //sign up func
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign Out", message: "Are you sure you'd like to sign out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        
                        let signInVC = SignInViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
    
    private func setUpSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(didTapSignOut)
        )
    }
    
    //table view
    private var posts : [BlogPost] = []
    
    private func fetchPosts() {
        print("Fetching posts...")

        DatabaseManager.shared.getPosts(for: currentEmail) { [weak self] posts in
            // Sort posts by date of publication in descending order
            let sortedPosts = posts.sorted { $0.date > $1.date }
            self?.posts = sortedPosts
            print("Found \(sortedPosts.count) posts")
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
        
        var isOwnedByCurrentUser = false
        if let email = UserDefaults.standard.string(forKey: "email") {
            isOwnedByCurrentUser = email == currentEmail
        }
        
        if !isOwnedByCurrentUser {
            if IAPManager.shared.canViewPost {
                let vc = ViewPostViewController(
                    post: posts[indexPath.row],
                    isOwnedByCurrentUser: isOwnedByCurrentUser
                )
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = "Post"
                navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = PayWallViewController()
                present(vc, animated: true)
            }
        }
        else {
            // Our post
            let vc = ViewPostViewController(
                post: posts[indexPath.row],
                isOwnedByCurrentUser: isOwnedByCurrentUser
            )
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.title = "Post"
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        StorageManager.shared.uploadProfilePicture(
            email: currentEmail,
            image: image) {
                [weak self] success in
                guard let strongSelf = self else {return}
                if success {
                    //update database
                    DatabaseManager.shared.updateProfilePhoto(email: strongSelf.currentEmail){ updated in
                        guard updated else{
                            return
                        }
                        DispatchQueue.main.async {
                            strongSelf.fetchProfileData()
                        }
                    }
                }
            }
    }
}
