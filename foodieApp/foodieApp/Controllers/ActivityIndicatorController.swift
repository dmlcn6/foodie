//
//  ActivityIndicatorController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/9/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
//

import UIKit

class ActivityIndicatorController: UIActivityIndicatorView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setup(parentView: UIView){
        self.center = parentView.center
        parentView.addSubview(self)
        parentView.bringSubview(toFront: self)
    }
    
    func start(){
        self.color = UIColor.red
        self.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    func stop(){
        self.hidesWhenStopped = true
        stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
