//
//  TabBarViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpControllers()
        
    }
    
    private func setUpControllers(){
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        
        let home = HomeViewController()
        home.title = "Home"
        
        let profile = ProfileViewController(currentEmail: currentUserEmail)
        profile.title = "Profile"
        
        home.navigationItem.largeTitleDisplayMode = .always
        profile.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)
        
        
        let search = SearchViewController()
        search.title = "Search"
        let nav3 = UINavigationController(rootViewController: search)
        nav3.navigationBar.prefersLargeTitles = true
        nav3.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3)
                
        setViewControllers([nav1, nav2, nav3], animated: true)
        
    }
    
    
}
