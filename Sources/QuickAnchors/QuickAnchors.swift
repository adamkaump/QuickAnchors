//
//  QuickAnchors.swift
//  
//
//  Created by Adam Kaump on 5/14/22.
//

import UIKit

typealias Q = QuickAnchor

public struct QuickAnchor {
    let type: QuickAnchorType
    let relatedView: UIView? //defaults to parent
    let constant: CGFloat? //defaults to 0
    
    init(_ type: QuickAnchorType) {
        self.type = type
        self.relatedView = nil
        self.constant = nil
    }
    
    init(_ type: QuickAnchorType, _ constant: CGFloat) {
        self.type = type
        self.relatedView = nil
        self.constant = constant
    }
    
    init(_ type: QuickAnchorType, _ relatedView: UIView?) {
        self.type = type
        self.relatedView = relatedView
        self.constant = nil
    }
    
    init(_ type: QuickAnchorType, _ relatedView: UIView?, _ constant: CGFloat?) {
        self.type = type
        self.relatedView = relatedView
        self.constant = constant
    }
}

enum QuickAnchorType {
    case topToTop, topToBottom, topToSafeArea, leadingToLeading, leadingToTrailing, trailingToTrailing, trailingToLeading, bottomToBottom, bottomToTop, bottomToSafeArea, heightEqualToView, heightEqualToConstant, widthEqualToView, widthEqualToConstant, centerX, centerY
}

/*
 Global functions for creating quick anchors
 */

public func topToTop(_ constant: CGFloat = 0) -> QuickAnchor { Q(.topToTop, constant) }
public func topToTop(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.topToTop, relatedView, constant) }
public func topToSafeArea(_ constant: CGFloat = 0) -> QuickAnchor { Q(.topToSafeArea, constant) }
public func topToBottom(_ constant: CGFloat = 0) -> QuickAnchor { Q(.topToBottom, constant) }
public func topToBottom(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.topToBottom, relatedView, constant) }
public func leadingToLeading(_ constant: CGFloat = 0) -> QuickAnchor { Q(.leadingToLeading, constant) }
public func leadingToLeading(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.leadingToLeading, relatedView, constant) }
public func leadingToTrailing(_ constant: CGFloat = 0) -> QuickAnchor { Q(.leadingToTrailing, constant) }
public func leadingToTrailing(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.leadingToTrailing, relatedView, constant) }
public func trailingToTrailing(_ constant: CGFloat = 0) -> QuickAnchor { Q(.trailingToTrailing, constant) }
public func trailingToTrailing(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.trailingToTrailing, relatedView, constant) }
public func bottomToBottom(_ constant: CGFloat = 0) -> QuickAnchor { Q(.bottomToBottom, constant) }
public func bottomToBottom(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.bottomToBottom, relatedView, constant) }
public func bottomToTop(_ constant: CGFloat = 0) -> QuickAnchor { Q(.bottomToTop, constant) }
public func bottomToTop(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.bottomToTop, relatedView, constant) }
public func bottomToSafeArea(_ constant: CGFloat = 0) -> QuickAnchor { Q(.bottomToSafeArea, constant) }
public func heightToConstant(_ constant: CGFloat = 0) -> QuickAnchor { Q(.heightEqualToConstant, constant) }
public func heightToRelatedView(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.heightEqualToView, relatedView, constant) }
public func widthToConstant(_ constant: CGFloat = 0) -> QuickAnchor { Q(.widthEqualToConstant, constant) }
public func widthToRelatedView(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.widthEqualToView, relatedView, constant) }
public func centerX(_ constant: CGFloat = 0) -> QuickAnchor { Q(.centerX, constant) }
public func centerX(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.centerX, relatedView, constant) }
public func centerY(_ constant: CGFloat = 0) -> QuickAnchor { Q(.centerY, constant) }
public func centerY(_ relatedView: UIView, _ constant: CGFloat = 0) -> QuickAnchor { Q(.centerY, relatedView, constant) }

extension UIView {
    
    func constraint(_ quickAnchor: QuickAnchor) -> NSLayoutConstraint {
        
        let relatedView = quickAnchor.relatedView ?? superview!
        let constant: CGFloat = quickAnchor.constant ?? 0
        
        switch quickAnchor.type {
        case .topToTop:
            return topAnchor.constraint(equalTo: relatedView.topAnchor, constant: constant)
        case .topToBottom:
            return topAnchor.constraint(equalTo: relatedView.bottomAnchor, constant: constant)
        case .topToSafeArea:
            return topAnchor.constraint(equalTo: relatedView.safeAreaLayoutGuide.topAnchor, constant: constant)
        case .leadingToLeading:
            return leadingAnchor.constraint(equalTo: relatedView.leadingAnchor, constant: constant)
        case .leadingToTrailing:
            return leadingAnchor.constraint(equalTo: relatedView.trailingAnchor, constant: constant)
        case .trailingToTrailing:
            return trailingAnchor.constraint(equalTo: relatedView.trailingAnchor, constant: constant)
        case .trailingToLeading:
            return trailingAnchor.constraint(equalTo: relatedView.leadingAnchor, constant: constant)
        case .bottomToBottom:
            return bottomAnchor.constraint(equalTo: relatedView.bottomAnchor, constant: constant)
        case .bottomToSafeArea:
            return bottomAnchor.constraint(equalTo: relatedView.safeAreaLayoutGuide.bottomAnchor, constant: constant)
        case .bottomToTop:
            return bottomAnchor.constraint(equalTo: relatedView.topAnchor, constant: constant)
        case .heightEqualToView:
            return heightAnchor.constraint(equalTo: relatedView.heightAnchor)
        case .heightEqualToConstant:
            return heightAnchor.constraint(equalToConstant: constant)
        case .widthEqualToView:
            return widthAnchor.constraint(equalTo: relatedView.widthAnchor, constant: constant)
        case .widthEqualToConstant:
            return widthAnchor.constraint(equalToConstant: constant)
        case .centerX:
            return centerXAnchor.constraint(equalTo: relatedView.centerXAnchor, constant: constant)
        case .centerY:
            return centerYAnchor.constraint(equalTo: relatedView.centerYAnchor, constant: constant)
        }
    }
    
    public func quickAdd(_ subview: UIView, _ quickAnchors: [QuickAnchor]) {
        self.addSubview(subview)
        subview.activateQuickAnchors(quickAnchors)
    }
    
    public func quickAdd(_ subview: UIView, _ padding: [Any?], _ quickAnchors: [QuickAnchor]? = nil) {
        guard padding.count == 4 else { fatalError() }
        
        self.addSubview(subview)
        
        //activate padding ints passed in
        if let c = padding[0] as? Int { subview.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(c)).isActive = true }
        if let c = padding[1] as? Int { subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(c)).isActive = true }
        if let c = padding[2] as? Int { subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(c)).isActive = true }
        if let c = padding[3] as? Int { subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(c)).isActive = true }
        
        //activate padding tuples passed in
        if let tup = padding[0] as? (UIView, Int) { subview.topAnchor.constraint(equalTo: tup.0.bottomAnchor, constant: CGFloat(tup.1)).isActive = true}
        if let tup = padding[1] as? (UIView, Int) { subview.leadingAnchor.constraint(equalTo: tup.0.trailingAnchor, constant: CGFloat(tup.1)).isActive = true }
        if let tup = padding[2] as? (UIView, Int) { subview.bottomAnchor.constraint(equalTo: tup.0.topAnchor, constant: CGFloat(tup.1)).isActive = true }
        if let tup = padding[3] as? (UIView, Int) { subview.trailingAnchor.constraint(equalTo: tup.0.leadingAnchor, constant: CGFloat(tup.1)).isActive = true }
        
        //activate quick anchors
        if let anchors = quickAnchors { subview.activateQuickAnchors(anchors) }
    }
    
    public func quickAdd(_ subview: UIView, _ padding: Int? = 0) {
        let constant: CGFloat = CGFloat(padding ?? 0)
        self.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant)
        ])
    }
    
    public func activateQuickAnchors(_ quickAnchors: [QuickAnchor]) {
        let constraints = quickAnchors.map { a in constraint(a) }
        NSLayoutConstraint.activate(constraints)
    }
}

