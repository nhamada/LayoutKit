# LayoutKit
`LayoutKit` provides DSL-like class to add layout constraint for iOS/macOS app development.

## Install
1. Clone repository
2. Copy `LayoutKit.swift` to your project

## Usage
```
let view0 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view0.backgroundColor = UIColor.brown
view.addSubview(view0)

let view1 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view1.backgroundColor = UIColor.blue
view.addSubview(view1)

let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view2.backgroundColor = UIColor.green
view.addSubview(view2)

let view3 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view3.backgroundColor = UIColor.red
view.addSubview(view3)

let view4 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view4.backgroundColor = UIColor.purple
view.addSubview(view4)

let view5 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view5.backgroundColor = UIColor.magenta
view.addSubview(view5)

LayoutKit.locate(view0).fitParent()
LayoutKit.locate(view1).onCenter(view)
LayoutKit.locate(view1).size(CGSize(width: 150, height: 150))
LayoutKit.locate(view2).onHorizontalCenter(view1).and().onRightSide(of: view1)
LayoutKit.locate(view2).width(100).and().sameHeight(to: view1)
LayoutKit.locate(view3).onHorizontalCenter(view1).and().onLeftSide(of: view1)
LayoutKit.locate(view3).width(50).and().height(100)
LayoutKit.locate(view4).onVerticalCenter(view1, spacing: 10).and().above(view1)
LayoutKit.locate(view4).width(100).and().height(100)
LayoutKit.locate(view5).onVerticalCenter(view1, spacing: 10).and().bottom(view1)
LayoutKit.locate(view5).width(10).and().height(10)

LayoutKit.apply()
```

Starting layout, call `locate(_:)` method to specify view instance.
Then, call

* one of `onLeftSide(of:spacing:)`/`onRightSide(of:spacing:)`/`above(_:spacing:)`/`bottom(_:spacing:)`/`onCenter(_:spacing:)`/`onVerticalCenter(_:spacing:)`/`onHorizontalCenter(_:spacing:)` methods to place
* `size(_:)`/`width(_:)`/`height(_:)`/`sameWidth(to:)`/`sameHeight(_:)` to determine view size
* `fitParent()` method to fill parent view

After giving layout constraints, call `apply()` method to layout.

## Current limitation
`LayoutKit` layouts subviews during an view initialization.
View layout cannot be changed and modified after initialization.

If you have any idea of a feature, please open an issue.

## Future implementation
* Constrain view aspect ratio
* Relative view size to another view

## Notice
Currently, `LayoutKit` is under pre-alpha stage.
`LayoutKit` is provided "as-is" and no warranty.
