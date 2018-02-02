# Pellicola

[![Version](https://img.shields.io/cocoapods/v/Pellicola.svg?style=flat)](http://cocoapods.org/pods/Pellicola)
[![License](https://img.shields.io/cocoapods/l/Pellicola.svg?style=flat)](http://cocoapods.org/pods/Pellicola)
[![Platform](https://img.shields.io/cocoapods/p/Pellicola.svg?style=flat)](http://cocoapods.org/pods/Pellicola)

A replacement for `UIImagePickerController` with multiple selection support written in Swift.

| | Features |
:---: | --- |
✅ | Replace `UIImagePickerController` adding support to **multiple selection** |
👨🏻‍💻 | Written in Swift with full Objective-C compatibility |
☁️ | iCloud Photo Library support |
🎨 | Customize the UI for your app |
🌍 | Open to string localization |

We use the open source version `master` branch in the [Subito](https://itunes.apple.com/us/app/subito-it/id450775137?ls=1&mt=8) app.

***

## Requirements

* Xcode 9.0+
* iOS 9.0+
* Swift 4.0+
* Interoperability with Objective-C

## Installation

Pellicola is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Pellicola'
```

### Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Getting started

Create a `PellicolaPresenter` object with a style. We provide a `DefaultPellicolaStyle` object which uses a default style for Pellicola. The `didSelectImages` closure provides an array of selected images ordered by the user selection. The `userDidCancel` closure let you know if the user exits from the flow.

Use the method `present(on: UIViewController, maxNumberOfSelections: Int)` to show Pellicolsa and specify the maximum number of selectable images.

and `userDidCancel` closures to get 

```swift

import UIKit
import Pellicola

class ViewController: UIViewController {
    
    var pellicolaPresenter: PellicolaPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pellicolaPresenter = PellicolaPresenter(style: DefaultPellicolaStyle())
        
        pellicolaPresenter.didSelectImages = { images in
            print("User selected \(images.count) images")
        }
        
        pellicolaPresenter.userDidCancel = {
            print("User did cancel the flow")
        }
        
        pellicolaPresenter.present(on: self, maxNumberOfSelections: 10)
    }
}


```

## Authors

* [Francesco Bigagnoli](https://github.com/francybiga) ([@francybiga](https://twitter.com/francybiga))
* [Andrea Antonioni](https://github.com/andreaantonioni) ([@andrea_anto97](https://twitter.com/andrea_anto97))

## Contributing

Feel free to collaborate with ideas, issues and/or pull requests.

P.S. If you use Pellicola in your app we would love to hear about it!

## License

Pellicola is available under the Apache License, Version 2.0. See the [LICENSE file](https://github.com/Subito-it/Pellicola/blob/master/LICENSE) for more info.
