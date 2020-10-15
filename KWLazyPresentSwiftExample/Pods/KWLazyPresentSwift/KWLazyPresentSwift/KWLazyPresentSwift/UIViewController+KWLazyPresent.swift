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
    
    var alertWindow: KWWindow? {
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

        self.alertWindow = KWWindow(frame: UIScreen.main.bounds)
        
        self.alertWindow?.rootViewController = UIViewController()
        
        var window: UIWindow?
        
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
              return
            }
            
            window = windowScene.windows.first
        }
        
        if (window == nil) {
            print("Window not found in SceneDelegate")
            //window = (UIApplication.shared.delegate?.window)!
            window = UIApplication.shared.windows.first
        }
        
        if (window == nil) {
            print("Window not found in AppDelegate")
        }
        
        if let window = window {
            self.alertWindow?.tintColor = window.tintColor
        }
        
        
        switch alertType {
        case .defaultStyle:
            self.alertWindow?.windowLevel = UIWindow.Level.alert - 1
        case .inAppNotification:
            self.alertWindow?.windowLevel = kwGetSuitableWindowLevel()
            
        }
        
        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
    
    public func lazyDismiss(animated: Bool = true, completion: completion? = nil) {
        
        self.dismiss(animated: animated) {
            self.alertWindow?.isHidden = true
            self.alertWindow = nil
            
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
