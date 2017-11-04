//
//  PreviewImageView.swift
//
//
//  Created by Antonio Zaitoun on 03/07/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit


public typealias AZPresenterHandler = (AZImagePresenterViewController,UIImageView)->Void

public struct AZPresenterAction{
    public var icon: UIImage
    public var handler: AZPresenterHandler
}

// MARK: - AZGestureDirection

public enum AZGestureDirection{
    case yAxis
    case xAxis
    case both
}

// MARK: - AZPreviewDismissDirection

public enum AZPreviewDismissDirection{
    case top
    case bottom
    case both
    case none
}

// MARK: - AZImagePresenterViewController

public class AZImagePresenterViewController: UIViewController{
    
    public class func embedInNavigation(_ controller: AZImagePresenterViewController)->UINavigationController{
        let navigationController = FixedNavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationController.navigationBar.isTranslucent = true
        navigationController.toolbar.isTranslucent = true
        navigationController.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        return navigationController
    }
    
    public func embedInNavigation()->UINavigationController{
        let navigationController = AZImagePresenterViewController.embedInNavigation(self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(done(_:)))
        navigationController.navigationBar.tintColor = tintColor
        return navigationController
    }
    
    
    // MARK: - private property
    
    /// Reference to the original image view
    fileprivate var originalImage: UIImageView?
    
    /// The delegate that was set on the image
    fileprivate weak var delegate: AZPreviewImageViewDelegate?
    
    /// The image that we drag around
    fileprivate var imageView: TrackableImage?
    
    /// The center point of the original image. This property is a computed property and it needs the delegate in order to compute.
    fileprivate var center: CGPoint?{
        if let originalImage = originalImage,let superView = delegate?.previewImageViewInRespectTo(originalImage){
            return superView.convert(originalImage.center, to: nil)
        }
        return nil
    }
    
    /// The rect (frame) of the original image in respect to the view that was provided in the delegate.
    fileprivate var rect: CGRect?{
        if let originalImage = originalImage,let superView = delegate?.previewImageViewInRespectTo(originalImage){
            return originalImage.superview!.convert(originalImage.frame, to: superView)
        }
        return nil
    }
    
    fileprivate var originalContentMode: UIViewContentMode = .scaleAspectFit
    
    fileprivate var actions: [AZPresenterAction?] = []
    
    /// The direction in which the image can be dismissed uppong drag
    public var dismissDirection: AZPreviewDismissDirection = .both
    
    /// The gesture direction
    public var gestureDirection: AZGestureDirection = .both
    
    // The background color
    public var backgroundColor: UIColor = .white
    
    // The animation duration
    public var animationDuration: TimeInterval = 0.2
    
    public var scaleOnDrag: Bool = true
    
    /// 0 or lower means scale to original size.
    public var minimumScale: CGFloat = 0.0
    
    public var tintColor: UIColor = .black {
        didSet{
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.toolbar.tintColor = tintColor
        }
    }
    
    /// hide/show status bar
    public var isStatusBarHidden = false{
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// change status bar style
    public var statusBarStyle: UIStatusBarStyle = .default{
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    // MARK: - UIViewController
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .fade
    }
    
    override public var prefersStatusBarHidden: Bool{
        return isStatusBarHidden
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        super.loadView()
        imageView = TrackableImage()
        view.addSubview(imageView!)
    }
    
    fileprivate var isNavigationBarHidden = false
    
    fileprivate var isToolBarHidden = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        isToolBarHidden = navigationController?.isToolbarHidden ?? false
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true
        
 
        imageView?.image = originalImage?.image
        imageView?.contentMode = .scaleAspectFit
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    public func addAction(_ action: AZPresenterAction){
        actions.append(action)
        
        setupActions()
    }
    
    public func removeAction(at index: Int){
        if index >= actions.count{ return }
        
        actions.remove(at: index)
        
        setupActions()
    }
    
    func setupActions(){
        
        if let navigationController = self.navigationController, let toolBar = navigationController.toolbar{
            toolBar.items?.removeAll()
            
            var items = [UIBarButtonItem]()
            
            var index = 0
            for action in actions{
                let item = UIBarButtonItem(image: action?.icon,
                                           landscapeImagePhone: nil,
                                           style: .plain,
                                           target: self,
                                           action: #selector(didSelectToolBarItem(sender:)))
                item.tag = index
                index += 1
                items.append(item)
            }
            
            if items.count == 0 {
                navigationController.setToolbarHidden(true, animated: true)
            }else{
                setToolbarItems(items, animated: false)
                if navigationController.isToolbarHidden {
                    navigationController.setToolbarHidden(false, animated: true)
                }
            }
        }
    }
    
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentView()
        setupActions()
    }
    
    // MARK: - Helpers
    
    fileprivate var isPortrait: Bool{
        return view.frame.height > view.frame.width
    }
    
    fileprivate(set) open var isDragging: Bool = false{
        didSet{
            if let item = navigationItem.leftBarButtonItem{
                item.isEnabled = !isDragging
            }
        }
    }
    
    fileprivate var scale: CGFloat{
        let ratio = originalImage!.frame.width / view.frame.width
        return ratio >= 1.0 ? 1.0 : ratio
    }
    
    
    fileprivate func setup(){
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    fileprivate func prepareForDismiss(){
        originalImage?.isHidden = false
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Gesture Handler
    
    @objc internal func handlePanGesture(_ sender: UIPanGestureRecognizer){
        
        let animationDuration = self.animationDuration
        
        let baseView = imageView!
        let translation = sender.translation(in: self.view)
        
        let allowX: Bool = gestureDirection == .both || gestureDirection == .xAxis
        let allowY: Bool = gestureDirection == .both || gestureDirection == .yAxis
        
        baseView.center = CGPoint(x: baseView.lastLocation.x + (translation.x * (allowX ? 1.0 : 0.0)),
                                  y: baseView.lastLocation.y + (translation.y * (allowY ? 1.0 : 0.0)))
        
        func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let xDist = a.x - b.x
            let yDist = a.y - b.y
            return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        }
        
        let alpha = 1.0 - max(min(distance(baseView.center, view.center)/distance(view.frame.origin, view.center), 1.0),0)
        
        let scale: CGFloat = scaleOnDrag ? max(min(minimumScale > 0.0 ? (minimumScale < alpha ? alpha : minimumScale) : alpha,1.0),self.scale) : 1.0
        
        imageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.view.backgroundColor = self.backgroundColor.withAlphaComponent(alpha)
        
        let returnToCenter:(CGPoint,Bool)->Void = { (finalPoint,animate) in
            
            self.hideBars(hide: false)
            
            if !animate {
                baseView.center = finalPoint
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                self.imageView?.transform = .identity
                return
            }
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                baseView.center = finalPoint
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                self.imageView?.transform = .identity
            }, completion: { (complete) -> Void in
            })
        }
        
        
        let dismissInDirection: (CGPoint)->Void = { [weak self] (point) in
            
            
            self?.dismissDirection(baseView,scale: scale,finalPoint: point)
        }
        
        var finalPoint = (baseView.superview?.center)!
        
        hideBars(hide: true)
        
        isDragging = true
        
        if sender.state == .ended{
            isDragging = false
            let velocity = sender.velocity(in: view)
            let mag = sqrtf(Float(velocity.x * velocity.x) + Float(velocity.y * velocity.y))
            let slideMult = mag / 200
            let dismissWithGesture = dismissDirection != .none ? true : false
            
            if dismissWithGesture && slideMult > 1 {
                //dismiss
                if velocity.y > 0{
                    //dismiss downward
                    if dismissDirection == .bottom || dismissDirection == .both {
                        finalPoint.y = (baseView.superview?.frame.maxY)! + (baseView.bounds.midY)
                        dismissInDirection(finalPoint)
                    }else{
                        returnToCenter(finalPoint,true)
                    }
                }else{
                    
                    //dismiss upward
                    if dismissDirection == .top || dismissDirection == .both {
                        finalPoint.y = -(baseView.bounds.midY)
                        dismissInDirection(finalPoint)
                    }else{
                        returnToCenter(finalPoint,true)
                    }
                }
            }else{
                //return to center
                returnToCenter(finalPoint,true)
            }
        }
        
        if sender.state == .cancelled || sender.state == .failed{
            returnToCenter(finalPoint,false)
            isDragging = false
        }
    }
    
    @objc internal func done(_ sender: UIBarButtonItem){
        if let imageView = imageView, !isDragging{
            var safePoint = imageView.center
            safePoint.y = view.frame.maxY + imageView.bounds.midY
            dismissDirection(imageView,scale: 1.0,finalPoint: safePoint)
        }
    }
    
    @objc internal func didSelectToolBarItem(sender: UIBarButtonItem){
        actions[sender.tag]?.handler(self,originalImage ?? imageView!)
    }
    
    fileprivate func presentView(){
        
        if let navigationController = navigationController{
            
            if !isNavigationBarHidden{
                navigationController.setNavigationBarHidden(false, animated: true)
            }
            
            if !isToolBarHidden {
                navigationController.setToolbarHidden(false, animated: true)
            }
            
        }
        
        //make position of uiimageview same as the original one (apply rect)
        if let rect = rect{
            imageView?.frame = rect
        }
        
        let isRounded = true//self.isRounded
        
        if isRounded {
            imageView!.layer.cornerRadius = originalImage!.layer.cornerRadius//imageView!.frame.height / 2
            imageView?.layer.masksToBounds = true
        }
        
        switch originalImage!.contentMode{
        case .scaleAspectFit,
             .scaleAspectFill,
             .scaleToFill:
            originalContentMode = originalImage!.contentMode
        default:
            originalContentMode = .scaleAspectFit
        }
        
        imageView?.contentMode = originalContentMode
        
        //hide make original image hidden
        originalImage?.isHidden = true
        
        //animate to center
        view.backgroundColor = .clear
        
        if isRounded{
            
            self.imageView!
                .addCornerRadiusAnimation(from: imageView!.cornerRadius,
                                          to: 0, duration: animationDuration)
        }
        
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            if let this = self{
                let width = this.imageView?.image?.size.width
                let height = this.imageView?.image?.size.height
                
                let scale = width!/height!
                let sWidth: CGFloat
                let sHeight: CGFloat
                
                if this.isPortrait{
                    sWidth = this.view.frame.width
                    sHeight = sWidth/scale
                }else{
                    sHeight = this.view.frame.height
                    sWidth = sHeight * scale
                }
                
                
                this.imageView?.frame = CGRect(x: 0, y: 0, width: sWidth, height: sHeight)
                this.imageView?.center = this.view.center
                this.view.backgroundColor = this.backgroundColor
            }
        }){ (bool) in
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.frame = self.view.frame
            self.imageView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }
    }
    
    fileprivate func hideBars(hide: Bool){
        self.navigationController?.setNavigationBarHidden(hide, animated: true)
        self.navigationController?.setToolbarHidden(hide, animated: true)
    }
    
    fileprivate func dismissDirection(_ baseView: TrackableImage , scale: CGFloat, finalPoint: CGPoint){
        
        hideBars(hide: true)
        
        //here we are resizing the trackable image in order to make the animation smooth
        baseView.transform = .identity
        //get the width and height of the image
        let width = baseView.image?.size.width
        let height = baseView.image?.size.height
        
        //calculate the aspect ratio of the image
        let ratio: CGFloat = width!/height!
        
        //calculate the new size
        let sWidth: CGFloat
        let sHeight: CGFloat
        
        if self.isPortrait{
            sWidth = self.view.frame.width
            sHeight = sWidth/ratio
        }else{
            sHeight = self.view.frame.height
            sWidth = sHeight * ratio
        }
        
        //calculate the new center
        let newCenter = baseView.center//CGPoint(x: baseView.frame.midX * ratio, y: baseView.frame.midY * ratio)
        
        //update the image
        baseView.frame.size.height = sHeight
        baseView.frame.size.height = sWidth
        baseView.center = newCenter
        baseView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        //change the content mode to the original content mode
        baseView.contentMode = self.originalContentMode
        
        baseView.addCornerRadiusAnimation(from: baseView.cornerRadius, to: originalImage!.cornerRadius * (1/scale), duration: animationDuration)
        
        //animate
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            
            //animate the background color to clear
            self.view.backgroundColor = .clear
            
            guard let center = self.center, let rect = self.rect else {
                baseView.center = finalPoint
                return
            }
            
            //animate rect to original image center and same rect size
            baseView.center = center
            baseView.frame = rect
            
            
            
            
        }, completion: { (complete) -> Void in
            self.prepareForDismiss()
        })
    }
    
    
    // MARK: - TrackableImage class
    
    fileprivate class TrackableImage: UIImageView{
        
        var lastLocation = CGPoint(x: 0, y: 0)
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            lastLocation = self.center
            super.touchesBegan(touches, with: event)
        }
    }
    
}

// MARK: - Private class helper, used to add stored extension properties.

fileprivate final class ObjectAssociation<T: Any> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

fileprivate class FixedNavigationController: UINavigationController{
    override var childViewControllerForStatusBarStyle: UIViewController?{
        return viewControllers.first
    }
}

fileprivate extension UIView
{
    func addCornerRadiusAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.add(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
    }
    
    var cornerRadius: CGFloat{
        return layer.cornerRadius
    }
}

fileprivate extension CGSize{
    var area: CGFloat{
        return width * height
    }
    
    var isSquare: Bool{
        return width == height
    }
}


public extension UIImageView{
    
    private static let association = ObjectAssociation<AZPreviewImageViewDelegate>()
    
    public var delegate: AZPreviewImageViewDelegate? {
        
        get {
            return UIImageView.association[self] }
        set {
            UIImageView.association[self] = newValue
            setup()
        }
    }
    
    private func setup(){
        isUserInteractionEnabled = true
    }
    
    private func preparePresenter()->AZImagePresenterViewController{
        let presenter = AZImagePresenterViewController()
        presenter.originalImage = self
        presenter.delegate = delegate
        return presenter
    }
    
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let tap:UITouch = touches.first!
        let point = tap.location(in: self)
        if self.bounds.contains(point) && image != nil{
            //touch-up-inside
            delegate?.previewImageView(self, requestImagePreviewWithPreseneter: preparePresenter())
        }
    }
}




