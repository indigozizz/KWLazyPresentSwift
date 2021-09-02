//
//  NotificationViewController.swift
//  KWLazyPresentSwiftExample
//
//  Created by Kawa on 2020/10/19.
//

import UIKit
import KWLazyPresentSwift

class NotificationViewController: UIViewController {

    let notificationView = UIView()
    var showFrame = CGRect.zero
    var hideFrame = CGRect.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //MARK: Add KWPassthroughView to pass the touches between Windows
        let passthroughView = KWPassthroughView()
        passthroughView.frame = self.view.bounds
        self.view.addSubview(passthroughView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNotificationView(title: "Notification Title", message: "Notification Message")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Just an Dummy Example for Notification View.
    func showNotificationView(title: String, message: String) {
        
        let leftInset: CGFloat = 16.0
        let topInset: CGFloat = 16.0
        
        var topSafeAreaInset: CGFloat = 0.0
        
        if #available(iOS 11.0, *) {
            let edgeInsets = UIApplication.shared.windows.first?.safeAreaInsets
            topSafeAreaInset = edgeInsets?.top ?? 0
        }
        
        let x: CGFloat = leftInset
        let y: CGFloat = topInset + topSafeAreaInset
        let width: CGFloat = self.view.frame.size.width - leftInset * 2
        let height: CGFloat = 110.0
        
        showFrame = CGRect(x: x, y: y, width: width, height: height)
        hideFrame = CGRect(x: x, y: -height, width: width, height: height)
        
        notificationView.frame = hideFrame
        notificationView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        notificationView.layer.cornerRadius = 13.0
        
        notificationView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.9).cgColor
        notificationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        notificationView.layer.shadowRadius = 4.0
        notificationView.layer.shadowOpacity = 0.1
        
        let button = UIButton.init(type: .system)
        button.frame = notificationView.bounds
        button.addTarget(self, action: #selector(notificationDismiss), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.lightGray
        titleLabel.text = title
        titleLabel.frame = CGRect(x: x, y: 0, width: width, height: height / 2)
        
        let messageLabel = UILabel()
        messageLabel.font = UIFont.boldSystemFont(ofSize: 13)
        messageLabel.textColor = UIColor.darkGray
        messageLabel.text = message
        messageLabel.numberOfLines = 2
        messageLabel.frame = CGRect(x: x, y: height / 2, width: width, height: height / 2)
        
        notificationView.addSubview(titleLabel)
        notificationView.addSubview(messageLabel)
        notificationView.addSubview(button)
        
        self.view.addSubview(notificationView)
        
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut) {
            self.notificationView.frame = self.showFrame
        } completion: { (finished) in
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.75) {
            self.notificationDismiss()
        }

    }
    
    @objc func notificationDismiss() {
        self.notificationView.layer.removeAllAnimations()
        self.notificationView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut) {
            self.notificationView.frame = self.hideFrame
        } completion: { (finished) in
            self.notificationView.removeFromSuperview()
            //self.lazyDismiss(animated: false, completion: nil)
            self.dismiss(animated: false, completion: nil)
        }
    }

}
