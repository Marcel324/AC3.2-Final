//
//  Uploads.swift
//  AC3.2-Final
//
//  Created by Marcel Chaucer on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class Upload {
    var comment: String?
    var imageURL: String?
    
    init(comment: String, imageURL: String) {
        self.comment = comment
        self.imageURL = imageURL
    }
}
