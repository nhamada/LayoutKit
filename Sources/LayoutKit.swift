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
    private enum State {
        case initialized
        case onlyFirstItem
        case needSecondItem
        case specified
    }
    
    var targetView: ViewClass
    var targetViewAttribute: NSLayoutAttribute = .notAnAttribute
    var layoutRelation: NSLayoutRelation = .equal
    var relatedView: ViewClass?
    var relatedViewAttribute: NSLayoutAttribute = .notAnAttribute
    var constant: CGFloat = 0
    
    private var state: State
    
    init(_ targetView: ViewClass) {
        self.targetView = targetView
        self.state = .initialized
    }
    
    func convert() -> NSLayoutConstraint {
        guard state == .specified || state == .onlyFirstItem else {
            fatalError("Constraint is not specified.")
        }
        
        return NSLayoutConstraint.init(item: targetView, attribute: targetViewAttribute, relatedBy: layoutRelation, toItem: relatedView, attribute: relatedViewAttribute, multiplier: 1.0, constant: constant)
    }
    
    func setSingleConstraint(attribute: NSLayoutAttribute, relation: NSLayoutRelation, constant: CGFloat) {
        guard state == .initialized else {
            fatalError("This constraint is already specified.")
        }
        
        targetViewAttribute = attribute
        layoutRelation = relation
        self.constant = constant
        state = .onlyFirstItem
    }
    
    func setViewRelationship(selfAttribute: NSLayoutAttribute, view: ViewClass, attribute: NSLayoutAttribute, relation: NSLayoutRelation, constant: CGFloat) {
        guard state == .initialized else {
            fatalError("This constraint is already specified.")
        }
        
        targetViewAttribute = selfAttribute
        relatedView = view
        relatedViewAttribute = attribute
        layoutRelation = relation
        self.constant = constant
        state = .specified
    }
    
    var specified: Bool {
        switch state {
        case .specified, .onlyFirstItem:
            return true
        default:
            return false
        }
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
        return shared.locate(view)
    }
    
    public func locate(_ view: ViewClass) -> LayoutKit {
        guard components.isEmpty || (!components.isEmpty && current.specified) else {
            fatalError("Previous constraint is not fixed.")
        }
        
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
        current.setSingleConstraint(attribute: .width, relation: .equal, constant: width)
        return self
    }
    
    @discardableResult public func height(_ height: CGFloat) -> LayoutKit {
        current.setSingleConstraint(attribute: .height, relation: .equal, constant: height)
        return self
    }
    
    @discardableResult public func sameWidth(to view: ViewClass) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .width, view: view, attribute: .width, relation: .equal, constant: 0)
        return self
    }
    
    @discardableResult public func sameHeight(to view: ViewClass) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .height, view: view, attribute: .height, relation: .equal, constant: 0)
        return self
    }
    
    @discardableResult public func onLeftSide(of view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .trailing, view: view, attribute: .leading, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func onRightSide(of view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .leading, view: view, attribute: .trailing, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func above(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .bottom, view: view, attribute: .top, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func bottom(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .top, view: view, attribute: .bottom, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func onCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        return self.onVerticalCenter(view, spacing: spacing).locate(current.targetView).onHorizontalCenter(view, spacing: spacing)
    }
    
    @discardableResult public func onVerticalCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .centerX, view: view, attribute: .centerX, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func onHorizontalCenter(_ view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .centerY, view: view, attribute: .centerY, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func fitParent() -> LayoutKit {
        let view = current.targetView
        guard let superview = view.superview else {
            fatalError("view(\(view)) does not have superview.")
        }
        return self.alignedTop(to: superview).locate(view).alignedLeft(to: superview).locate(view).alignedRight(to: superview).locate(view).alignedBottom(to: superview)
    }
    
    @discardableResult public func alignedLeft(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .leading, view: view, attribute: .leading, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func alignedRight(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .trailing, view: view, attribute: .trailing, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func alignedTop(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .top, view: view, attribute: .top, relation: .equal, constant: spacing)
        return self
    }
    
    @discardableResult public func alignedBottom(to view: ViewClass, spacing: CGFloat = 0) -> LayoutKit {
        current.setViewRelationship(selfAttribute: .bottom, view: view, attribute: .bottom, relation: .equal, constant: spacing)
        return self
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
}

