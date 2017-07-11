//
//  CollectionViewController.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 12/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class CollectionViewController: UICollectionViewController{
    
    lazy var images: [UIImage] = [#imageLiteral(resourceName: "image_1"),
                                #imageLiteral(resourceName: "image_2"),
                                #imageLiteral(resourceName: "image_3"),
                                #imageLiteral(resourceName: "image_4"),
                                #imageLiteral(resourceName: "image_5"),
                                #imageLiteral(resourceName: "image_6"),
                                #imageLiteral(resourceName: "image_7"),
                                #imageLiteral(resourceName: "image_8"),
                                #imageLiteral(resourceName: "image_9"),
                                #imageLiteral(resourceName: "image_1"),
                                #imageLiteral(resourceName: "image_2"),
                                #imageLiteral(resourceName: "image_3"),
                                #imageLiteral(resourceName: "image_4"),
                                #imageLiteral(resourceName: "image_5"),
                                #imageLiteral(resourceName: "image_6"),
                                #imageLiteral(resourceName: "image_7"),
                                #imageLiteral(resourceName: "image_8"),
                                #imageLiteral(resourceName: "image_9"),
                                #imageLiteral(resourceName: "image_1"),
                                #imageLiteral(resourceName: "image_2"),
                                #imageLiteral(resourceName: "image_3"),
                                #imageLiteral(resourceName: "image_4"),
                                #imageLiteral(resourceName: "image_5"),
                                #imageLiteral(resourceName: "image_6"),
                                #imageLiteral(resourceName: "image_7"),
                                #imageLiteral(resourceName: "image_8"),
                                #imageLiteral(resourceName: "image_9"),
                                #imageLiteral(resourceName: "image_1"),
                                #imageLiteral(resourceName: "image_2"),
                                #imageLiteral(resourceName: "image_3"),
                                #imageLiteral(resourceName: "image_4"),
                                #imageLiteral(resourceName: "image_5"),
                                #imageLiteral(resourceName: "image_6"),
                                #imageLiteral(resourceName: "image_7"),
                                #imageLiteral(resourceName: "image_8"),
                                #imageLiteral(resourceName: "image_9")
    ]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCell", for: indexPath) as? CustomCollectionCell{
            
            
            
            cell.image.image = images[indexPath.item]
            if cell.image.delegate == nil{
                cell.image.delegate = self
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
}

extension CollectionViewController: AZPreviewImageViewDelegate{
    public func previewImageViewInRespectTo(_ previewImageView: UIImageView) -> UIView? {
        return view
    }
    
    public func previewImageView(_ previewImageView: UIImageView, requestImagePreviewWithPreseneter presenter: AZImagePresenterViewController) {
        //presenter.isStatusBarHidden = true
        presenter.statusBarStyle = .default
        presenter.backgroundColor = .white
        presenter.dismissDirection = .both
        presenter.animationDuration = 0.2
        presenter.minimumScale = 0.5
        presenter.tintColor = UIButton().tintColor
        let nav = presenter.embedInNavigation()
        nav.isToolbarHidden = false
        
        presenter.addAction(AZPresenterAction(icon:
        #imageLiteral(resourceName: "ic_file_download")){ (presenter,imageView) in
            
            presenter.addAction(AZPresenterAction(icon: #imageLiteral(resourceName: "ic_file_download")) { (presenter, image) in
            })
            
        })
        
        self.present(nav, animated: false, completion: nil)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 4
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

public class CustomCollectionCell: UICollectionViewCell{
    
    @IBOutlet weak var image: CircleImageView!
}
