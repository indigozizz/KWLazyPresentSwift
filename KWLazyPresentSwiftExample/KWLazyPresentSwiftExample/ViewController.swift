//
//  ViewController.swift
//  KWLazyPresentSwiftExample
//
//  Created by Kawa on 2020/10/15.
//

import UIKit
import KWLazyPresentSwift

class ViewController: UIViewController {
    
    let windowCountLabel = UILabel()
    let notificationButton = UIButton()
    let alertButton = UIButton()
    let showButton = UIButton()
    let dismissButton = UIButton()
    let logButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        layoutInitialize()
    }
    
    func layoutInitialize() {
        self.view.backgroundColor = UIColor.random()
        let count = UIApplication.shared.windows.count
        
        windowCountLabel.frame = CGRect(x: 10, y: 10, width: self.view.frame.width, height: 60)
        windowCountLabel.text = "\(count)"
        windowCountLabel.font = UIFont.boldSystemFont(ofSize: 45)
        windowCountLabel.textColor = UIColor.random()
        windowCountLabel.shadowColor = UIColor.black
        windowCountLabel.shadowOffset = CGSize(width: -1, height: -1)
        
        
        notificationButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        notificationButton.setTitle("Show InApp Notification", for: .normal)
        notificationButton.setTitleColor(UIColor.white, for: .normal)
        notificationButton.backgroundColor = UIColor.purple
        notificationButton.addTarget(self, action: #selector(notificationButtonClick), for: .touchUpInside)
        
        notificationButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        notificationButton.setTitle("Show InApp Notification", for: .normal)
        notificationButton.setTitleColor(UIColor.white, for: .normal)
        notificationButton.backgroundColor = UIColor.purple
        notificationButton.addTarget(self, action: #selector(notificationButtonClick), for: .touchUpInside)
        
        alertButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        alertButton.setTitle("Show Alert", for: .normal)
        alertButton.setTitleColor(UIColor.black, for: .normal)
        alertButton.backgroundColor = UIColor.yellow
        alertButton.addTarget(self, action: #selector(alertButtonClick), for: .touchUpInside)
        
        showButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        showButton.setTitle("Present ViewController", for: .normal)
        showButton.setTitleColor(UIColor.black, for: .normal)
        showButton.backgroundColor = UIColor.gray
        showButton.addTarget(self, action: #selector(showButtonClick), for: .touchUpInside)
        
        dismissButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.setTitleColor(UIColor.black, for: .normal)
        dismissButton.backgroundColor = UIColor.gray
        dismissButton.addTarget(self, action: #selector(dismissButtonClick), for: .touchUpInside)
        
        logButton.frame = CGRect(x: 0, y: 0, width: 180, height: 60)
        logButton.setTitle("Print Log", for: .normal)
        logButton.setTitleColor(UIColor.black, for: .normal)
        logButton.backgroundColor = UIColor.gray
        logButton.addTarget(self, action: #selector(logButtonClick), for: .touchUpInside)
        
        
        notificationButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 140)
        
        alertButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 70)
        
        showButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        
        dismissButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 70)
        
        logButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 140)
        
        
        self.view.addSubview(notificationButton)
        self.view.addSubview(alertButton)
        self.view.addSubview(showButton)
        self.view.addSubview(dismissButton)
        self.view.addSubview(logButton)
    }
    
    @objc func notificationButtonClick()
    {
        //TODO
    }
    
    @objc func alertButtonClick()
    {
        //TODO
    }
    
    @objc func showButtonClick()
    {
        //TODO
    }
    
    @objc func dismissButtonClick()
    {
        //TODO
    }
    
    @objc func logButtonClick()
    {
        //TODO
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
