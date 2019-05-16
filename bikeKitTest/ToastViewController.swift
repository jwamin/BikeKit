//
//  ToastViewController.swift
//  bikeKitTest
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

class ToastViewController: UIViewController, ToastDelegate {

    var toastLabel:UILabel!
    var toastInFlight:Bool = false
    var blurView:UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.text = "toast!"
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        blurView.layer.opacity = 0.0
        // Do any additional setup after loading the view.
        
        blurView.contentView.addSubview(toastLabel)
        
        self.view.addSubview(blurView)
        
        toastLabel.isUserInteractionEnabled = false
        
        toastLabel.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        toastLabel.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        
        let views:[String:Any] = ["toastlabel":toastLabel!]
        
        var pinConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[toastlabel]-|", options: [], metrics: nil, views: views)
        pinConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[toastlabel]-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(pinConstraints)
        
        blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.bottomAnchor.constraint(equalToSystemSpacingBelow: blurView.bottomAnchor, multiplier: 20).isActive = true
        
    }
    

    func flyToast(str:String){
        if toastInFlight{
            return
        }
        toastInFlight = true
        toastLabel.text = str
        toastLabel.sizeToFit()
        blurView.layer.opacity = 1.0
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 10, options: [], animations: {
            self.blurView.transform = CGAffineTransform(translationX: 0, y: -100)
        }) { (complete) in
            if(complete){
                
                UIView.animate(withDuration: 0.5, animations: {
                     self.blurView.layer.opacity = 0.0
                }, completion: { (complete) in
                    self.blurView.transform = .identity
                     self.toastInFlight = false
                })
                
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


protocol ToastDelegate {
    func flyToast(str:String)
}
