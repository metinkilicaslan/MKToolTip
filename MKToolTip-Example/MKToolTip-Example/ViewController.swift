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
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor(red: 0.937, green: 0.964, blue: 1.000, alpha: 1.000)
        preference.drawing.bubble.spacing = 10
        preference.drawing.bubble.cornerRadius = 5
        preference.drawing.bubble.inset = 15
        preference.drawing.bubble.border.color = UIColor(red: 0.768, green: 0.843, blue: 0.937, alpha: 1.000)
        preference.drawing.bubble.border.width = 1
        preference.drawing.arrow.tipCornerRadius = 5
        preference.drawing.message.color = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
        preference.drawing.message.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        preference.drawing.button.color = UIColor(red: 0.074, green: 0.231, blue: 0.431, alpha: 1.000)
        preference.drawing.button.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        sender.showToolTip(identifier: "", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", button: "JUSTO", arrowPosition: .top, preferences: preference, delegate: nil)
    }
    
    @IBAction func button1Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
        let preference = ToolTipPreferences()
        preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
        preference.drawing.arrow.tipCornerRadius = 0
        preference.drawing.message.color = .black
        sender.showToolTip(identifier: "", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .left, preferences: preference, delegate: nil)
    }
    
    @IBAction func button2Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.165, green: 0.322, blue: 0.596, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1.000)
        let preference = ToolTipPreferences()
        preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
        sender.showToolTip(identifier: "", title: "Dapibus", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .right, preferences: preference, delegate: nil)
    }
    
    @IBAction func button3Tapped(_ sender: UIButton) {
        let gradientColor = UIColor(red: 0.988, green: 0.714, blue: 0.624, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.988, green: 0.714, blue: 0.624, alpha: 1.000)
        let preference = ToolTipPreferences()
        preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
        sender.showToolTip(identifier: "", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .bottom, preferences: preference, delegate: nil)
    }

    @IBAction func textAlignmentButtonTapped(_ sender: UIButton) {
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor(red: 0.937, green: 0.964, blue: 1.000, alpha: 1.000)
        preference.drawing.bubble.spacing = 10
        preference.drawing.bubble.cornerRadius = 5
        preference.drawing.bubble.inset = 15
        preference.drawing.message.color = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
        preference.drawing.message.alignment = .center
        
        preference.drawing.title.color = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
        preference.drawing.title.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        preference.drawing.title.alignment = .center

        sender.showToolTip(identifier: "", title: "Dapibus", message: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", arrowPosition: .top, preferences: preference, delegate: nil)
    }
}

