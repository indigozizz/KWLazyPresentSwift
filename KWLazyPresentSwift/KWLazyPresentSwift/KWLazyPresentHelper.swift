//
//  KWLazyPresentHelper.swift
//  KWLazyPresentSwift
//
//  Created by Kawa on 2021/9/7.
//

import Foundation

public class KWLazyPresentHelper {
    
    public static let shared = KWLazyPresentHelper()
    
    var isEnable = false
    
    private init() {
        
    }
    
    
    public func enable() {
        if (!isEnable) {
            //MARK: Only swizzle once due to SwizzleStatic.once
            UIViewController.swizzle()
            isEnable = !isEnable
            addObserver()
        }
    }
    
    //TODO: Is this method needed?
    public func disable() {
        if (!isEnable) {
            isEnable = !isEnable
            removeObserver()
        }
    }

    private func addObserver() {
        if (isEnable) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(kw_viewControllerWillDealloc(notification:)),
                name: NSNotification.Name(rawValue: "VIEW_CONTROLLER_WILL_DEALLOC"),
                object: nil)
        }
    }
    
    private func removeObserver() {
        if (!isEnable) {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    public func notifyOberver(viewController: UIViewController) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VIEW_CONTROLLER_WILL_DEALLOC"), object: viewController)
    }
    
    deinit {
        removeObserver()
    }
    
    @objc func kw_viewControllerWillDealloc(notification: NSNotification) {
//        guard (self.isEqual(notification.object)) else {
//            return
//        }
        if let viewController = notification.object as? UIViewController {
            let duration = viewController.dismissDuration
            
            if (duration > 0) {
                viewController.dismissDuration = -1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.releaseLazyWindow(viewController: viewController)
                }
            }
            else if (duration == 0) {
                releaseLazyWindow(viewController: viewController)
            }
        }
    }
    
    func releaseLazyWindow(viewController: UIViewController) {

        if let window = viewController.kwPresentWindow {
            
            print("\nviewController: \(viewController), \n\nwindow: \(window), \n\nviewController.kwPresentWindow: \(viewController.kwPresentWindow!) ")
            
            window.rootViewController?.dismiss(animated: false, completion: {
                viewController.kwPresentWindow!.isHidden = true
                viewController.kwPresentWindow!.rootViewController = nil
                viewController.kwPresentWindow = nil
            })
        }
    }
    
}
