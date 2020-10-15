# AZImagePreview
iOS Framework that makes it easy to preview images on any UIImageView.

## Screenshots
<img src="Screenshots/sc1.gif" width="280" /> <img src="Screenshots/sc2.gif" width="280" /> 


## Installation:

### Cocoa Pods:

```bash
pod 'AZImagePreview'
```

### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `AZImagePreview` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
name: "YOUR_PROJECT_NAME",
dependencies: [
.package(url: "https://github.com/Minitour/AZImagePreview.git", from: "1.2.0"),
]
)
```
Then run `swift build` whenever you get prepared.

### Manual:

Simply drag and drop the ```Sources``` folder to your project.


### Conform to the AZPreviewImageViewDelegate protocol:

```swift

extension ViewController: AZPreviewImageViewDelegate{
    func previewImageViewInRespectTo(_ previewImageView: UIImageView) -> UIView? {
        //return self.view or self.navigationController?.view (if you are using a navigation controller.
        return view
    }

    func previewImageView(_ previewImageView: UIImageView, requestImagePreviewWithPreseneter presenter: AZImagePresenterViewController) {
        present(presenter, animated: false, completion: nil)
    }
}

```

### Set the delegate on the UIImageView:

```swift

@IBOutlet weak var imageView: UIImageView!

override func viewDidLoad(){
    super.viewDidLoad()
    
    imageView.delegate = self
}

```
