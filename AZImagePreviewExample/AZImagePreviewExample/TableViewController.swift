//
//  TableViewController.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 11/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController{
    
    
    lazy var data: [UIImage] = [#imageLiteral(resourceName: "image_1"),
                                #imageLiteral(resourceName: "image_2"),
                                #imageLiteral(resourceName: "image_3"),
                                #imageLiteral(resourceName: "image_4"),
                                #imageLiteral(resourceName: "image_5"),
                                #imageLiteral(resourceName: "image_6"),
                                #imageLiteral(resourceName: "image_7"),
                                #imageLiteral(resourceName: "image_8"),
                                #imageLiteral(resourceName: "image_9")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(ImageCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ImageCell {
            cell.imageView?.image = data[indexPath.row]
            cell.imageView?.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let imageSize = data[indexPath.row].size
        
        return view.frame.width * (imageSize.height/imageSize.width)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}

extension TableViewController: AZPreviewImageViewDelegate{
    func previewImageViewInRespectTo(_ previewImageView: UIImageView) -> UIView? {
        return navigationController?.view
    }
    
    func previewImageView(_ previewImageView: UIImageView, requestImagePreviewWithPreseneter presenter: AZImagePresenterViewController) {
        present(presenter, animated: false, completion: nil)
    }
}

class ImageCell: UITableViewCell{
    
    private var customImage: UIImageView!
    
    override var imageView: UIImageView?{
        return customImage
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customImage = UIImageView()
        customImage.contentMode = .scaleToFill
        addSubview(customImage)
        customImage.translatesAutoresizingMaskIntoConstraints = false
        customImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        customImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        customImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        customImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
