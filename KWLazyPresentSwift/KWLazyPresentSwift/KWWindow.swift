//
//  KWWindow.swift
//  KWLazyPresentSwift
//
//  Created by Kawa on 2020/10/15.
//

import UIKit

public class KWWindow: UIWindow {

    public var kwLazyTag: NSInteger = 0
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestResult = super.hitTest(point, with: event)
        
        if (hitTestResult is KWPassthroughView) {
            return nil
        
        }
        
        return hitTestResult
    }

}
