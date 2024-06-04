//
//  SignInHeaderView.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 30/01/2024.
//

import UIKit

class SignInHeaderView: UIView {
    
    private let imageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mainicon"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemMint
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        //addSubview(label)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let size: CGFloat = frame.width/4
        imageView.frame = CGRect(x: (frame.width-size)/2, y: 10, width: size, height: size)        
    }
    
}
