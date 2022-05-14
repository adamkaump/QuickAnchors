
<!--
<div align="center">
  <img src="https://i.imgur.com/xGziEkc.png"/>
</div>
-->


## Quick Anchors ⚓️

Quick Anchors are a way of creating programmatic constraints for UIKit with very little code. It's a system that allows you to create UI that looks like this:

<img width=200 src="https://i.imgur.com/7Oy8b3H.png"/>

With code that looks like this:

```swift
view.quickAdd(redView, [ 
    topToTop(50), 
    leadingToLeading(20), 
    heightToConstant(100) 
])

view.quickAdd(blueView, [ 
    topToTop(redView), 
    leadingToTrailing(redView, 20), 
    trailingToTrailing(-20),
    bottomToBottom(redView), 
    widthToRelatedView(redView) 
])

view.quickAdd(greenView, [ 
    topToBottom(redView, 20), 
    leadingToLeading(redView), 
    trailingToTrailing(blueView), 
    heightToConstant(50) 
])
```

## Contents
* [Explanation](#explanation)
  * [Why Quick Anchors](#why-quick-anchors)
  * [Installation](#installation)
  * [What is a Quick Anchor](#what-is-a-quick-anchor)
  * [Quick Anchor Types](#quick-anchor-types)
  * [Exchanging Quick Anchors for Constraints](#exchanging-quick-anchors-for-constraints)
* [Usage](#usage)
  * [Opt out of Auto Layout](#opt-out-of-auto-layout)
  * [Quick Add](#quick-add)
  * [Mixing Quick Anchors and normal constraints](#mixing-quick-anchors-and-normal-constraints)
  * [Quick add with a constant padding](#quick-add-with-a-constant-padding)
  * [Quick add with an array of Ints](#quick-add-with-an-array-of-ints)
  * [Quick add with an array of (UIView, Int) tuples](#quick-add-with-an-array-of-uiview-int-tuples)
  * [Quick add with an array of (UIView, Int) tuples and an array of Quick Anchors](#quick-add-with-an-array-of-uiview-int-tuples-and-an-array-of-quick-anchors)
* [Style](#style)
  * [Prefer convenience initializers](#prefer-convenience-initializers)
  * [Minimize new lines](#minimize-new-lines)
  * [Prefer explicit numbers over variables](#prefer-explicit-numbers-over-variables)

## Explanation

### Why Quick Anchors

Programmatic NSLayoutConstraints are a great way of writing clear, easily maintainable UIKit code that will not cause merge conflicts (ahem storyboards ahem). However, writing programmatic UIKit constraints involves a ton of boilerplate. Without Quick Anchors, the layout for the example above would look something like this:

```swift
view.addSubview(redView)
NSLayoutConstraint.activate([
    redView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
    redView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    redView.heightAnchor.constraint(equalToConstant: 100)
])

view.addSubview(blueView)
NSLayoutConstraint.activate([
    blueView.topAnchor.constraint(equalTo: redView.topAnchor),
    blueView.leadingAnchor.constraint(equalTo: redView.trailingAnchor, constant: 20),
    blueView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    blueView.bottomAnchor.constraint(equalTo: redView.bottomAnchor),
    blueView.widthAnchor.constraint(equalTo: redView.widthAnchor)
])

view.addSubview(greenView)
NSLayoutConstraint.activate([
    greenView.topAnchor.constraint(equalTo: redView.bottomAnchor, constant: 20),
    greenView.leadingAnchor.constraint(equalTo: redView.leadingAnchor),
    greenView.trailingAnchor.constraint(equalTo: blueView.trailingAnchor),
    greenView.heightAnchor.constraint(equalToConstant: 50)
])
```

For this example, Quick Anchors use fewer than half the number of characters than the stock way of creating constraints (441 vs 1,046).

### Installation

Add QuickAnchor.swift file to your project's code base. It's less than 200 lines of code - you don't need a SPM package or a cocoapod or whatever.

### What is a Quick Anchor

A Quick Anchor is a struct that encapsulates three pieces of information:

* A type of Quick Anchor
* A related view (optional, defaults to the parent view)
* A constant (optional, defaults to 0)

```swift
struct QuickAnchor {
    let type: QuickAnchorType
    let relatedView: UIView? //defaults to parent
    let constant: CGFloat? //defaults to 0
}
```

This is enough information to make a programmatic constraint when adding one view as a subview of another. More on that later.

### Quick Anchor types

The QuickAnchorType enum maps to different kinds of NSLayoutConstraints - the way a view should lay itself out in relation to a constant value (eg: height, width) or in relation to another view (eg: spacing, proportional size).

```swift
enum QuickAnchorType {
    case topToTop
    case topToBottom
    case topToSafeArea
    case heightEqualToView
    // etc
}
```

Not all NSLayoutConstraint types are supported. In order to create a "great than or equal to" constraint, for example, you'll have to use a standard NSLayoutConstraint initializer. For now.

### Exchanging Quick Anchors for Constraints

Quick Anchors are exchanged for normal NSLayoutConstraints behind the scenes. Because of this Quick Anchors can easily be used in combination with normal NSLayoutConstraints. Currently there is no clean way to get a reference to a constraint that is added through the Quick Anchor system - if you need access to a constraint reference that constraint needs to be created through the normal NSLayoutConstraint API.

## Usage

### Opt out of Auto Layout

We want to be explicit about all the constraints being added to our views, this is true whether you're using vanilla NSLayoutConstraints or Quick Anchors. For this reason, it's important to set the translatesAutoresizingMaskIntoConstraints property to false for all your views.

```swift
let view: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
}()
```

### Quick Add 

Quick Anchors extend UIView to add several `.quickAdd` functions that are the heart of the Quick Anchor system. `.quickAdd` functions do two things in a single step:

1. Add one view as a subview of another
2. Translate any Quick Anchors passed in into constraints

For example, say you have two views, `redView` and `blueView`. 

```swift
let redView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .red
    return v
}()

let blueView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .blue
    return v
}()
```

..and say you want to add redView as a subview of blueView, centering redView vertically and horizontally, and giving it an explicit height of 100 and an explicit width of 100. 

If you wanted to accomplish this with programmatic NSLayoutConstraints, your code would look something like this:

```swift
// NSLayoutConstraint
blueView.addSubview(redView)
NSLayoutConstraint.activate([
    redView.centerXAnchor.constraint(equalTo: blueView.centerXAnchor),
    redView.centerYAnchor.constraint(equalTo: blueView.centerYAnchor),
    redView.heightAnchor.constraint(equalToConstant: 100),
    redView.widthAnchor.constraint(equalToConstant: 100)
])
```

Not too bad, but there is a lot of repeated code. Let's see how this could look with Quick Anchors:

```swift
// Quick Anchors - Option 1
blueView.quickAdd(redView, [
    QuickAnchor.init(.centerX),
    QuickAnchor.init(.centerY),
    QuickAnchor.init(.heightEqualToConstant, 100),
    QuickAnchor.init(.widthEqualToConstant, 100)
])
```

Much less code! The first example had 313 characters, but with Quick Anchors its reduced to 190. 

But you can take things even father using available Quick Anchor global initializers.

```swift
// Quick Anchors = Option 2
blueView.quickAdd(redView, [
    centerX(),
    centerY(),
    heightToConstant(100),
    widthToConstant(100)
])
```

108 characters total. The resulting code is so compact, it can easily be parsed if it's written on a single line:

```swift
blueView.quickAdd(redView, [ centerX(), centerY(), heightToConstant(100), widthToConstant(100) ])
```

### Mixing Quick Anchors and normal constraints

It's important to stress that quick anchors are exchanged for normal NSLayoutConstraints behind the scenes and can therefore be used interchangably with them. This can be important if you would like to use a constraint that Quick Anchors do not support, or if you need to assign a constraint to a variable so that it can be modified later.

For example, code like this is perfectly valid:

```swift
blueView.quickAdd(redView, [
    centerX(), centerY()
])
redView.heightAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
redView.widthAnchor.constraint(greaterThanOrEqualTo: blueView.widthAnchor).isActive = true
```

As is code like this:

```swift
blueView.quickAdd(redView, [
    centerX(), centerY(), widthToConstant(100)
])

var c = redView.heightAnchor.constraint(equalToConstant: 100)
c.isActive = true

if someVariable == true {
    c.constant = 200
}
```

### Quick add with a constant padding

It's very common to add one view as a subview of another and set constant padding all around its edges. Instead of having to be explicit about the quick anchors:

```swift
blueView.quickAdd(redView, [
    .topToTop(10), .leadingToLeading(10), .trailingToTrailing(-10), .bottomToBottom(-10)
])
```

You can instead use an overloaded version of `quickAdd` which allows you to pass a single Int to use for the padding of all 4 sides.

```swift
blueView.quickAdd(redView, 10)
```

And if want 0 values along all sides, you may simply omit the Int parameter:

```swift
blueView.quickAdd(redView)
```

### Quick add with an array of Ints

For additional brevity, there is another version of `quickAdd` which accepts an array of `Int?`s, allowing you to supply the paddings you would like to use for the top, left, bottom, and right of a view in relation to its superview. This array must be 4 items long, otherwise a FatalException will be thrown. Pass nil for any edges you would not like padding added to.

```swift
blueView.quickAdd(redView, [10, 20, nil, -20])
```

Because the parameters are not named, they must be passed in the correct order. The order top, left, bottom, and right was chosen because it matches the order when creating a UIEdgeInsets instance.

### Quick add with an array of (UIView, Int) tuples

Sometimes you might want to use the "array of Ints" `quickAdd` function, but instead of giving the padding in relation to the superview, you would like to express the view's padding in relation to another view. To do this, you may simply replace any or all of the Int values passed into `quickAdd` with a (UIView, Int) tuple instead, where UIView is the view that you would like to create your constraint in relation to.

Same stipulations as the previous example still apply. The array's length must be 4, otherwise a fatal exception will be thrown.

This is incredibly useful if you're stacking views along the Y axis.

```swift
blueView.quickAdd(redView, [10, 20, -20, nil])
blueView.quickAdd(greenView, [(redView, 10), 20, -20, -20])
blueView.quickAdd(yellowView, [(green, 40), 20, -20, -20])
```

### Quick add with an array of (UIView, Int) tuples and an array of Quick Anchors

Finally, if you would like to supply top + left + bottom + right paddings AND also supply quick anchors, you may also supply an array of QuickAnchors to the overloaded `quickAdd` function. This array can be any length.

```swift
blueView.quickAdd(redView,
                  [10, 30, 30, nil],
                  [ heightToConstant(100) ]
)
```

## Style

### Prefer convenience initializers

//todo

### Minimize new lines

There are many ways to write the following `quickAdd` function:

```swift
blueView.quickAdd(redView, [
    centerX(),
    centerY(),
    heightToConstant(100),
    widthToConstant(100)
])
```

The above function reads very nicely, but takes up a lot of vertical space. It could be written much more compactly in this way:

```swift
blueView.quickAdd(redView, [
    centerX(), centerY(), heightToConstant(100), widthToConstant(100)
])
```

But the preferred way to write this line would be:

```swift
blueView.quickAdd(redView, [ centerX(), centerY(), heightToConstant(100), widthToConstant(100) ])
```

This allows you to group all layout code together in an extremely compact area of your class.

### Prefer explicit numbers over variables

Obviously, the following example contains some repeated values:

```swift
blueView.quickAdd(redView, [
    topToTop(40), leadingToLeading(20), trailingToTrailing(-20)
])

blueView.quickAdd(greenView, [
    topToBottom(redView, 40), leadingToLeading(20), bottomToBottom(-40), trailingToTrailing(-20)
])
```

It might be tempting to refactor the repeated values out into variables, like this:

```swift
let topBottomPadding = 40
let leftRightPadding = 20

blueView.quickAdd(redView, [
    topToTop(topBottomPadding), leadingToLeading(leftRightPadding), trailingToTrailing(-leftRightPadding)
])

blueView.quickAdd(greenView, [
    topToBottom(redView, topBottomPadding), leadingToLeading(leftRightPadding), bottomToBottom(-topBottomPadding), trailingToTrailing(-leftRightPadding)
])
```

This is obviously helpful in some ways. If the paddings ever change you only have to make the update in a single place, code complete will prevent you from accidentally typing the wrong value, etc.

However, the resulting reduction in brevity usually makes this kind of refactor not worthwhile and should usually be avoided.
