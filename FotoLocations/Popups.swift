//
//  Popups.swift
//  FotoLocations
//
//  Created by Marc Felden on 01/01/2020.
//  Copyright © 2020 madeTK.com. All rights reserved.
//

import UIKit

protocol PopupMessageProtocol {
    func popupMessagesOrSwiping(popupMessagesOrSwiping:PopupMessagesOrSwiping, didSelect:String)
}


class PopupMessagesOrSwiping:UIViewController {

    @IBOutlet weak var popupView: UIVisualEffectViewX!
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var eatButton: UIButtonX!
    @IBOutlet weak var drinkButton: UIButtonX!
    @IBOutlet weak var shopButton: UIButtonX!
    @IBOutlet weak var noneButton: UIButtonX!

    var delegate:PopupMessageProtocol!

    
    var message:String!
    var closure:(()->())!

    @IBAction func getPremiumAction(_ sender: Any) {
        delegate.popupMessagesOrSwiping(popupMessagesOrSwiping: self, didSelect: "eat")
    }
    @IBAction func getPremiumAction1(_ sender: Any) {
        delegate.popupMessagesOrSwiping(popupMessagesOrSwiping: self, didSelect: "drink")
    }
    @IBAction func getPremiumAction2(_ sender: Any) {
        delegate.popupMessagesOrSwiping(popupMessagesOrSwiping: self, didSelect: "shop")
    }
    @IBAction func getPremiumAction3(_ sender: Any) {
        delegate.popupMessagesOrSwiping(popupMessagesOrSwiping: self, didSelect: "none")
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.popupView.transform = CGAffineTransform(scaleX: 0.5, y: 1.8)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
            self.popupView.transform = .identity
        }) { (_) in
            //
        }
    }
}
