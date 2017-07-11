//
//  ViewController.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 11/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBAction func showTableView(_ sender: UIBarButtonItem) {
        let controller = TableViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView1.delegate = self
        imageView2.delegate = self
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView2.layer.cornerRadius = imageView2.frame.height/2
    }


}

extension ViewController: AZPreviewImageViewDelegate{
    func previewImageViewInRespectTo(_ previewImageView: UIImageView) -> UIView? {
        return view
    }

    func previewImageView(_ previewImageView: UIImageView, requestImagePreviewWithPreseneter presenter: AZImagePresenterViewController) {
        present(presenter, animated: false, completion: nil)
    }
}

