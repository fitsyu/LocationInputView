//
//  ViewController.swift
//  LocationInputView
//
//  Created by fitsyu on 06/18/2019.
//  Copyright (c) 2019 fitsyu. All rights reserved.
//

import UIKit
import LocationInputView

class ViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    
    
    var locationView: LocationInputView {
        let bounds = CGRect(x: 0, y: 0,
                           width:  view.frame.width,
                           height: view.frame.height * 0.45)
        let inputView = LocationInputView(frame: bounds)
        return inputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.inputView = locationView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationTextField.becomeFirstResponder()
    }
    
    @IBAction func close() {
        locationTextField.resignFirstResponder()
    }
    
    
    
}

