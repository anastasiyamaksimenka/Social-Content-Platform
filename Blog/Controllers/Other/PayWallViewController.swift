//
//  PayWallViewController.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 18/01/2024.
//

import UIKit

class PayWallViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpCloseButton()
        
    }
    
    private func setUpCloseButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapClose))
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    
}
