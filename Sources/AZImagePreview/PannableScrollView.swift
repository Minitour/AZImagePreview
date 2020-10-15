//
//  PannableScrollView.swift
//  AZImagePreviewExample
//
//  Created by Antonio Zaitoun on 12/10/2018.
//  Copyright © 2018 Antonio Zaitoun. All rights reserved.
//

import UIKit

class PannableScrollView: UIScrollView,UIScrollViewDelegate {

    open var view: UIView! {
        didSet {
            setupView()
        }
    }

    override public var frame: CGRect {
        didSet {
            if frame.size != oldValue.size { setZoomScale() }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
    }

    func setupView() {
        for view in subviews { view.removeFromSuperview() }
        view.sizeToFit()
        addSubview(view)
        contentSize = view.bounds.size

    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setZoomScale() {
        view.sizeToFit()
        view.frame.origin = .zero
        let widthScale = frame.size.width / view.bounds.width
        let heightScale = frame.size.height / view.bounds.height
        let minScale = min(widthScale, heightScale)
        minimumZoomScale = minScale
        zoomScale = minScale
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return view
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let view = view {
            let viewSize = view.frame.size
            let scrollViewSize = scrollView.bounds.size
            let verticalInset = viewSize.height < scrollViewSize.height ? (scrollViewSize.height - viewSize.height) / 2 : 0
            let horizontalInset = viewSize.width < scrollViewSize.width ? (scrollViewSize.width - viewSize.width) / 2 : 0
            scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        }
    }
}
