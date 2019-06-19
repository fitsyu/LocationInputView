//
//  UIKit Extensions.swift
//  LocationInputView
//
//  Created by iOSDev on 19/06/19.
//

import UIKit

extension UIImage {
    
    convenience init?(podAssetName: String) {
        let podBundle = Bundle(for: LocationInputView.self)
        
        guard
            let url = podBundle.url(forResource: "LocationInputView", withExtension: "bundle")
            else {
                return nil
        }
        
        self.init(named: podAssetName, in: Bundle(url: url), compatibleWith: nil)
    }
}


extension UIApplication {
    
    func topViewController() -> UIViewController? {
        
        var top: UIViewController?
        
        top = UIApplication.shared.keyWindow?.rootViewController
        
        while let child = top?.presentedViewController {
            top = child
        }
        
        return top
    }
}
