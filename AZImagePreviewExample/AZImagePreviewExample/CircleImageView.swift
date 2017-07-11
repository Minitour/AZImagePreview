//
//  CircularImageView.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 12/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit


@IBDesignable
class CircleImageView: UIImageView {
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}
