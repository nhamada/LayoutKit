#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

#if os(iOS)
public typealias ViewClass = UIView
#elseif os(OSX)
public typealias ViewClass = NSView
#endif

// MARK: - File private classes
fileprivate class InternalLayoutComponent {
    var targetView: ViewClass
    var targetViewAttribute: NSLayoutAttribute = .notAnAttribute
    var layoutRelation: NSLayoutRelation = .equal
    var relatedView: ViewClass?
    var relatedViewAttribute: NSLayoutAttribute = .notAnAttribute
    var constant: CGFloat = 0
    
    init(_ targetView: ViewClass) {
        self.targetView = targetView
    }
    
    func convert() -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: targetView, attribute: targetViewAttribute, relatedBy: layoutRelation, toItem: relatedView, attribute: relatedViewAttribute, multiplier: 1.0, constant: constant)
    }
}

private extension ViewClass {
    func disableResizing() {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

// MARK: - Framework classes
public class LayoutKit {
    // MARK: - Singleton
    private static let shared: LayoutKit = LayoutKit()
    private init() { }
    
    // MARK: - Properties
    private var components: [InternalLayoutComponent] = []
    private var activeConstraints: [NSLayoutConstraint] = []
    private var inactiveConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Public methods
    public static func locate(_ view: ViewClass) -> LayoutKit {
        view.disableResizing()
        shared.components.append(InternalLayoutComponent(view))
        return shared
    }
    
    public func locate(_ view: ViewClass) -> LayoutKit {
        view.disableResizing()
        self.components.append(InternalLayoutComponent(view))
        return self
    }
    
    @discardableResult public static func apply() -> [NSLayoutConstraint] {
        return shared.apply()
    }
    
    @discardableResult public func apply() -> [NSLayoutConstraint] {
        let constraints = components.map { $0.convert() }
        NSLayoutConstraint.activate(constraints)
        activeConstraints.append(contentsOf: constraints)
        return constraints
    }
    
    @discardableResult public func size(_ size: CGSize) -> LayoutKit {
        return self.width(size.width).locate(current.targetView).height(size.height)
    }
    
    @discardableResult public func width(_ width: CGFloat) -> LayoutKit {
        current.targetViewAttribute = .width
        current.layoutRelation = .equal
        current.constant = width
        return self
    }
    
    @discardableResult public func height(_ height: CGFloat) -> LayoutKit {
        current.targetViewAttribute = .height
        current.layoutRelation = .equal
        current.constant = height
        return self
    }
    
    @discardableResult public func sameWidth(to view: ViewClass) -> LayoutKit {
        current.targetViewAttribute = .width
        current.relatedView = view
        current.relatedViewAttribute = .width
        current.constant = 0
        return self
    }
    
    @discardableResult public func sameHeight(to view: ViewClass) -> LayoutKit {
        current.targetViewAttribute = .height
        current.relatedView = view
        current.relatedViewAttribute = .height
        current.constant = 0
        return self
    }
    
    @discardableResult public func onLeftSide(of view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .trailing
        current.relatedView = view
        current.relatedViewAttribute = .leading
        return self.spacing(spacing)
    }
    
    @discardableResult public func onRightSide(of view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .leading
        current.relatedView = view
        current.relatedViewAttribute = .trailing
        return self.spacing(spacing)
    }
    
    @discardableResult public func above(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .bottom
        current.relatedView = view
        current.relatedViewAttribute = .top
        return self.spacing(spacing)
    }
    
    @discardableResult public func bottom(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .top
        current.relatedView = view
        current.relatedViewAttribute = .bottom
        return self.spacing(spacing)
    }
    
    @discardableResult public func onCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        return self.onVerticalCenter(view, spacing: spacing).locate(current.targetView).onHorizontalCenter(view, spacing: spacing)
    }
    
    @discardableResult public func onVerticalCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .centerX
        current.relatedView = view
        current.relatedViewAttribute = .centerX
        return self.spacing(spacing)
    }
    
    @discardableResult public func onHorizontalCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .centerY
        current.relatedView = view
        current.relatedViewAttribute = .centerY
        return self.spacing(spacing)
    }
    
    @discardableResult public func fitParent() -> LayoutKit {
        let view = current.targetView
        guard let superview = view.superview else {
            fatalError("view(\(view)) does not have superview.")
        }
        return self.alignedTop(to: superview).locate(view).alignedLeft(to: superview).locate(view).alignedRight(to: superview).locate(view).alignedBottom(to: superview)
    }
    
    @discardableResult public func alignedLeft(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .leading
        current.relatedView = view
        current.relatedViewAttribute = .leading
        return self.spacing(spacing)
    }
    
    @discardableResult public func alignedRight(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .trailing
        current.relatedView = view
        current.relatedViewAttribute = .trailing
        return self.spacing(spacing)
    }
    
    @discardableResult public func alignedTop(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .top
        current.relatedView = view
        current.relatedViewAttribute = .top
        return self.spacing(spacing)
    }
    
    @discardableResult public func alignedBottom(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.targetViewAttribute = .bottom
        current.relatedView = view
        current.relatedViewAttribute = .bottom
        return self.spacing(spacing)
    }
    
    public func and() -> LayoutKit {
        return self.locate(current.targetView)
    }
    
    // MARK: - Private methods
    private var current: InternalLayoutComponent {
        guard let component = components.last else {
            fatalError("There are no layout specification.")
        }
        return component
    }
    
    @discardableResult private func spacing(_ spacing: CGFloat) -> LayoutKit {
        current.constant = spacing
        return self
    }
}

