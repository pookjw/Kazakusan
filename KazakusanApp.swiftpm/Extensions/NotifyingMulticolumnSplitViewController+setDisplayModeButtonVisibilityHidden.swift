import SwiftUI

func setDisplayModeButtonVisibilityHidden() {
    typealias BlockType = @convention(c) (Any, Selector, UISplitViewController.Style) -> Any
    
    let selector: Selector = #selector(UISplitViewController.init(style:))
    let method: Method = class_getInstanceMethod(NSClassFromString("SwiftUI.NotifyingMulticolumnSplitViewController"), selector)!
    let originalImp: IMP = method_getImplementation(method)
    let original: BlockType = unsafeBitCast(originalImp, to: BlockType.self)
    
    let new: @convention(block) (Any, UISplitViewController.Style) -> Any = { (me, arg0) -> Any in
        let object: UISplitViewController = original(me, selector, arg0) as! UISplitViewController
        object.displayModeButtonVisibility = .never
        return object
    }
    
    let newImp: IMP = imp_implementationWithBlock(new)
    method_setImplementation(method, newImp)
}
