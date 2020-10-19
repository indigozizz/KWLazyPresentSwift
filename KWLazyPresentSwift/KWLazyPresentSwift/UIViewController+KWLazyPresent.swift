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

//MARK: - Private Extention (AssociatedKeys)
extension UIViewController {
    private struct AssociatedKeys {
        static var kwPresentWindow = "kwPresentWindow"
    }
    
    var kwPresentWindow: KWWindow? {
        get {
            return getAssociated(associatedKey: &AssociatedKeys.kwPresentWindow)
        }
        set {
            setAssociated(value: newValue, associatedKey: &AssociatedKeys.kwPresentWindow)
        }
    }
}

//MARK: - KWLazyPresent Extention
extension UIViewController {

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
    
    
    public func lazyDismiss(animated: Bool = true, completion: completion? = nil) {
        
        self.dismiss(animated: animated) {
            self.kwPresentWindow?.isHidden = true
            self.kwPresentWindow = nil
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    public func lazyAlert(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(action)
        alertController.lazyPresent()
    }
    
}

//MARK: - Utils Extention
extension UIViewController {
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
}
