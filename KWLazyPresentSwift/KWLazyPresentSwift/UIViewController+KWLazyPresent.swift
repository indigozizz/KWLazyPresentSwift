//
//  UIViewController+KWLazyPresent.swift
//  KWLazyPresentSwift
//
//  Created by Kawa on 2020/10/15.
//

import UIKit

public enum KWLazyPresentType {
    case defaultStyle
    case inAppNotification
}

public typealias completion = () -> Void
public typealias checkCompletion = (_ granted: Bool, _ linkedViewController: UIViewController?) -> Void

//MARK: - Private Extention (AssociatedKeys)
extension UIViewController {
    private struct AssociatedKeys {
        static var kwPresentWindow = "kwPresentWindow"
        static var kwLinkedViewController = "kwLinkedViewController"
        static var tag = "tag"
    }
    
    var kwPresentWindow: KWWindow? {
        get {
            return getAssociated(associatedKey: &AssociatedKeys.kwPresentWindow)
        }
        set {
            setAssociated(value: newValue, associatedKey: &AssociatedKeys.kwPresentWindow)
        }
    }
    
    var kwLinkedViewController: UIViewController? {
        get {
            return getAssociated(associatedKey: &AssociatedKeys.kwLinkedViewController)
        }
        set {
            setAssociated(value: newValue, associatedKey: &AssociatedKeys.kwLinkedViewController)
        }
    }
    
    public var tag: NSInteger? {
        get {
            let tagNumber = objc_getAssociatedObject(self, &AssociatedKeys.tag) as? NSNumber
            return tagNumber?.intValue
        }
        set {
            let tagNumber = NSNumber.init(value: newValue ?? 0)
            setAssociated(value: tagNumber, associatedKey: &AssociatedKeys.tag)
        }
    }
}

//MARK: - KWLazyPresent Extention
extension UIViewController {
    
    private func kw_checkLifeCycleLinkingStatus(checkCompletion: checkCompletion? = nil) {
        if let checkCompletion = checkCompletion {
            if let kwLinkedViewController = self.kwLinkedViewController {
                checkCompletion(true, kwLinkedViewController)
            }
            else {
                checkCompletion(false, nil)
            }
        }
    }
    
    public func kw_linkLifeCycleWith(viewController: UIViewController) {
        self.kwLinkedViewController = viewController
    }

    public func kw_unlinkLifeCycle() {
        self.kwLinkedViewController = nil
    }
    
    
    public func lazyPresent(animated: Bool = true, alertType: KWLazyPresentType = .defaultStyle, completion: completion? = nil) {
        
        var window: UIWindow?
        
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                
                window = windowScene.windows.first
                
                kwPresentWindow = KWWindow(windowScene: windowScene)
                kwPresentWindow?.frame = UIScreen.main.bounds
                kwPresentWindow?.kwLazyTag = self.tag ?? 0
            }
        }
        
        if (kwPresentWindow == nil) {
            kwPresentWindow = KWWindow(frame: UIScreen.main.bounds)
        }
        
        self.kwPresentWindow?.rootViewController = UIViewController()
        
        if (window == nil) {
            print("Window not found in SceneDelegate")
            window = UIApplication.shared.windows.first
        }
        
        if (window == nil) {
            print("Window not found in AppDelegate")
        }
        
        if let window = window {
            self.kwPresentWindow?.tintColor = window.tintColor
        }
        
        
        switch alertType {
        case .inAppNotification:
            self.kwPresentWindow?.windowLevel = UIWindow.Level.alert - 1
            
        case .defaultStyle:
            self.kwPresentWindow?.windowLevel = kwGetSuitableWindowLevel()
        }
        
        self.kwPresentWindow?.makeKeyAndVisible()
        self.kwPresentWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
    public func lazyDismiss(tag: NSInteger, animtaion:Bool = false) -> Bool {
        if let viewController = self.kwViewControllerWithTag(tag) {
            viewController.dismiss(animated: animtaion, completion: {})
            return true
        }
        return false
    }
    
    //@available(*, deprecated, renamed: "loadData")
    @available(*, deprecated, renamed: "dismiss(animated:completion:)")
    public func lazyDismiss(animated: Bool = true, completion: completion? = nil) {

        self.dismiss(animated: animated) {
            self.kwPresentWindow?.isHidden = true
            self.kwPresentWindow = nil

            if let completion = completion {
                completion()
            }
        }
    }
    
}

//MARK: - Utils Extention
extension UIViewController {
    
    public func lazyAlert(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(action)
        alertController.lazyPresent()
    }
    
    fileprivate func kwGetSuitableWindowLevel() -> UIWindow.Level {
        
        let notificationLevel = UIWindow.Level.alert - 1
        var windowLevel = notificationLevel - 1
        
        for window in (UIApplication.shared.windows).reversed() {
            
            if (window.windowLevel >= notificationLevel - 1) {
                continue
            }
            
            windowLevel = window.windowLevel + 1;
        }
        
        return windowLevel
    }
    
    public func kwViewControllerWithTag(_ tag: NSInteger) -> UIViewController? {
        for window in (UIApplication.shared.windows).reversed() {
            guard (window.isKind(of: KWWindow.self)) else {
                continue
            }
            
            if let kwWindow = window as? KWWindow{
                if (kwWindow.kwLazyTag == tag) {
                    return kwWindow.rootViewController?.presentedViewController
                }
            }
        }
        return nil
    }
}

//[Reference] https://www.codenong.com/7aa9fe2a2218d4d42d88/
public extension UIViewController {
    private struct SwizzleStatic {
        static var once = true
    }

    @available(*, deprecated, message: "Please use 'KWLazyPresentHelper.shared.enable()' instead")
    class func swizzle() {
        guard SwizzleStatic.once else {
            return
        }
        SwizzleStatic.once = false
        let swizzleMethod = { (original: Selector, swizzled: Selector) in
            guard let originalMethod = class_getInstanceMethod(self, original),
                let swizzledMethod = class_getInstanceMethod(self, swizzled) else {
                    return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        //let swizzleClassMethod = { (original: Selector, swizzled: Selector) in
        let _ = { (original: Selector, swizzled: Selector) in
            guard let originalMethod = class_getClassMethod(self, original),
                let swizzledMethod = class_getClassMethod(self, swizzled) else {
                    assertionFailure("The methods are not found!")
                    return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        /*
        Method origin_dealloc_method = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method swizzle_dealloc_method = class_getInstanceMethod([self class], @selector(swizzle_dealloc));
        */
        self.kw_replaceDealloc()
        
//        swizzleMethod(#selector(UIViewController.viewDidLoad),
//                      #selector(UIViewController.swizzle_viewDidLoad))
        
        swizzleMethod(#selector(UIViewController.viewWillAppear(_:)),
                      #selector(UIViewController.swizzle_viewWillAppear(_ :)))
        
        swizzleMethod(#selector(UIViewController.viewDidAppear(_:)),
                      #selector(UIViewController.swizzle_viewDidAppear(_ :)))
        
        swizzleMethod(#selector(UIViewController.viewWillDisappear(_:)),
                      #selector(UIViewController.swizzle_viewWillDisappear(_ :)))
        
        swizzleMethod(#selector(UIViewController.viewDidDisappear(_:)),
                      #selector(UIViewController.swizzle_viewDidDisappear(_ :)))

    }
    
//    @objc func kw_viewControllerTriggerDealloc(notification: NSNotification) {
////        guard (self.isEqual(notification.object)) else {
////            return
////        }
//        print("triggerDealloc: \(self) - \(notification.object)")
//    }
    
    
//    @objc func swizzle_viewDidLoad() {
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(kw_viewControllerTriggerDealloc(notification:)),
//            name: NSNotification.Name(rawValue: "VIEW_CONTROLLER_WILL_DEALLOC"),
//            object: nil)
//
//        swizzle_viewDidLoad()
//    }
    
    @objc func swizzle_viewWillAppear(_ animated: Bool) {
        print("swizzle_viewWillAppear: \(self)" )
        if (KWLazyPresentHelper.shared.isEnable && self.isBeingPresented) {
            kw_checkLifeCycleLinkingStatus { (linked, linkedViewController) in
                if (linked) {
                    if let kwLinkedViewController = self.kwLinkedViewController {
                        kwLinkedViewController.viewWillDisappear(animated)
                    }
                }
            }
        }
        swizzle_viewWillAppear(animated)
    }
    
    @objc func swizzle_viewDidAppear(_ animated: Bool) {
        print("swizzle_viewDidAppear: \(self)")
        if (KWLazyPresentHelper.shared.isEnable && self.isBeingPresented) {
            kw_checkLifeCycleLinkingStatus { (linked, linkedViewController) in
                if (linked) {
                    if let kwLinkedViewController = self.kwLinkedViewController {
                        kwLinkedViewController.viewDidDisappear(animated)
                    }
                }
            }
        }
        swizzle_viewDidAppear(animated)
    }
    
    @objc func swizzle_viewWillDisappear(_ animated: Bool) {
        print("swizzle_viewWillDisappear: \(self)")
        if (KWLazyPresentHelper.shared.isEnable && self.isBeingDismissed) {
            kw_checkLifeCycleLinkingStatus { (linked, linkedViewController) in
                if (linked) {
                    if let kwLinkedViewController = self.kwLinkedViewController {
                        kwLinkedViewController.viewWillAppear(animated)
                    }
                }
            }
        }
        swizzle_viewWillDisappear(animated)
    }
    
    @objc func swizzle_viewDidDisappear(_ animated: Bool) {
        print("swizzle_viewDidDisappear: \(self)")
        if (KWLazyPresentHelper.shared.isEnable && self.isBeingDismissed) {
            kw_checkLifeCycleLinkingStatus { (linked, linkedViewController) in
                if (linked) {
                    if let kwLinkedViewController = self.kwLinkedViewController {
                        kwLinkedViewController.viewDidAppear(animated)
                    }
                }
            }
            
            KWLazyPresentHelper.shared.notifyOberver(viewController: self)
            
        }
        swizzle_viewDidDisappear(animated)
    }

}
