//
//  Extensions+UIViewController.swift
//  nextBoyQA
//
//  Created by Marc Felden on 08.11.18.
//  Copyright © 2018 Marc Felden. All rights reserved.
//

import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    func presentMessage(message:String) {
        let alertController = UIAlertController(title: "Note", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }    
}

// FIXME: kein Zwangs Slider bewergen mehr
// FIXME: alle Screens in Fullscreen (use Storyboard Instantiation)

