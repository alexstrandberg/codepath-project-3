//
//  FeedCell.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FeedCell: UITableViewCell {
    @IBOutlet weak var photoView: PFImageView!
    
    var parsetagramPost: PFObject! {
        didSet {
            self.photoView.file = parsetagramPost["media"] as? PFFile
            self.photoView.loadInBackground()
        }
    }
}
