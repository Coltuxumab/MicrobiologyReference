//
//  PopupNotificationViewController.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/16/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit

class PopupNotificationViewController: UIViewController {

    @IBOutlet weak var popupLabel: UILabel!
    
    var notificationText = "Default"
    var selfDestruct:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupLabel.text = notificationText
        
        //only apply the blur if the user hasn't disabled transparency effects
        /*if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.view.backgroundColor = UIColor.black
        }*/
        
        self.preferredContentSize = CGSize(width: 300, height: 300)
        
        
        // Check if view should self dismiss
        if (selfDestruct > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(selfDestruct), execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
