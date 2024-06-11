//
//  BlogPost.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 14/01/2024.
//

import Foundation

struct BlogPost{
    let identifier: String
    let title: String
    let timestamp: TimeInterval
    let headerImageUrl: URL?
    let text: String
    let link: String
    var date: Date {
            return Date(timeIntervalSince1970: timestamp)
        }
}
