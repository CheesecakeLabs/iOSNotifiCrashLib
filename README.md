<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/15795270/ic_laucher_soft_shadow.png" alt="NotifiCrash" title="NotifiCrash">
</p>

NotifiCrash is a very simple to use library that can catch any unhandled crash in your app and send information regarding
it to a remote server that will, just in time, notify you about the issue in you smartphone or tablet screen.

# NotifiCrash

[![Version](https://img.shields.io/cocoapods/v/NotifiCrash.svg?style=flat)](http://cocoadocs.org/docsets/NotifiCrash)
[![License](https://img.shields.io/cocoapods/l/NotifiCrash.svg?style=flat)](http://cocoadocs.org/docsets/NotifiCrash)
[![Platform](https://img.shields.io/cocoapods/p/NotifiCrash.svg?style=flat)](http://cocoadocs.org/docsets/NotifiCrash)

## Installation with CocoaPods

To install it, simply add the following line to your Podfile:

    pod "NotifiCrash"
    
## Usage

To use the library in your project, only add the following line of code in the end of your AppDelegate didFinishLaunchingWithOptions function.

    [NotifiCrash initWithSerialNumber:@"<app_serial_number>"];

## Author

Pedro Henrique Prates Peralta, pedro@ckl.io

## License

NotifiCrash is available under the MIT license. See the LICENSE file for more info.
