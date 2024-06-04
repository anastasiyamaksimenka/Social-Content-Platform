//
//  StorageManager.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import Foundation
import FirebaseStorage


final class StorageManager{
    static let shared = StorageManager()
    
    private let container = Storage.storage()
    
    private init(){}
    
    public func uploadProfilePicture(
        email: String,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ){
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        guard let pngData = image?.pngData() else{
            return
        }
        
        container
            .reference(withPath: "profile_pictures/\(path)/photo.png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else{
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    public func downlodaUrlForProfilePicture(
        path: String,
        completion: @escaping (URL?) -> Void
    ){
        container.reference(withPath: path)
            .downloadURL{ url, _ in
                completion(url)
            }
    }
    
    public func uploadBlogHeaderImage(
        email: String,
        image: UIImage,
        postId: String,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        guard let pngData = image.pngData() else {
            return
        }
        
        container
            .reference(withPath: "post_headers/\(path)/\(postId).png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    public func uploadBlogHeaderImage(
        blogPost: BlogPost,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ){
        
    }
    
    public func downloadUrlForPostHeader(
        email: String,
        postId: String,
        completion: @escaping (URL?) -> Void
    ) {
        let emailComponent = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        container
            .reference(withPath: "post_headers/\(emailComponent)/\(postId).png")
            .downloadURL { url, _ in
                completion(url)
            }
    }
}
