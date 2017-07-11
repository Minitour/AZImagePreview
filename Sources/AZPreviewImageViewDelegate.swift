//
//  AZPreviewImageViewDelegate.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 11/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit

// MARK: - AZPreviewImageViewDelegate

public protocol AZPreviewImageViewDelegate: class{
    
    func previewImageView(_ previewImageView: UIImageView,requestImagePreviewWithPreseneter presenter: AZImagePresenterViewController)
    
    func previewImageViewInRespectTo(_ previewImageView: UIImageView)->UIView?
    
}
