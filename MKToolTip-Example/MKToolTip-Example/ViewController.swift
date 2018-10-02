//
//  ViewController.swift
//  MKToolTip-Example
//
//  Created by Metin Kilicaslan on 15.07.2018.
//  Copyright © 2018 Metin Kilicaslan. All rights reserved.
//

import UIKit
import MKToolTip

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func barButton1Tapped(_ sender: UIBarButtonItem) {
        MKToolTip.show(item: sender, identifier: "", title: "Pharetra", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .top, delegate: nil)
    }
    
    @IBAction func button1Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
        let preference = Preferences()
        preference.drawing.bubbleGradientColors = [gradientColor, gradientColor2]
        preference.drawing.arrowTipCornerRadius = 0
        preference.drawing.messageColor = .black
        MKToolTip.show(view: sender, identifier: "", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .left, preferences: preference, delegate: nil)
    }
    
    @IBAction func button2Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.165, green: 0.322, blue: 0.596, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1.000)
        let preference = Preferences()
        preference.drawing.bubbleGradientColors = [gradientColor, gradientColor2]
        MKToolTip.show(view: sender, identifier: "", title: "Dapibus", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .right, preferences: preference, delegate: nil)
    }
    
    @IBAction func button3Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.988, green: 0.714, blue: 0.624, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.988, green: 0.714, blue: 0.624, alpha: 1.000)
        let preference = Preferences()
        preference.drawing.bubbleGradientColors = [gradientColor, gradientColor2]
        MKToolTip.show(view: sender, identifier: "", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .bottom, preferences: preference, delegate: nil)
    }
}

