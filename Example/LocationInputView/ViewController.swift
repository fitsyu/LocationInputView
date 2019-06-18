//
//  ViewController.swift
//  LocationInputView
//
//  Created by fitsyu on 06/18/2019.
//  Copyright (c) 2019 fitsyu. All rights reserved.
//

import UIKit
import LocationInputView
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    
    
    var locationView: LocationInputView {
        let bounds = CGRect(x: 0, y: 0,
                           width:  view.frame.width,
                           height: view.frame.height * 0.45)
        let inputView = LocationInputView(frame: bounds)
        inputView.delegate = self
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


extension ViewController: LocationInputViewDelegate {
    
    func didInputLocation(location: CLLocation, placemark: CLPlacemark?) {
        let t: String = [
                 placemark?.name,
                 placemark?.subThoroughfare,
                 placemark?.subLocality,
                 placemark?.subAdministrativeArea,
                 placemark?.administrativeArea,
                 placemark?.country]
            .compactMap { $0 }
            .joined(separator: ", ")
        
        
        self.locationTextField.text = t
    }
    
    func didClose() {
        self.locationTextField.resignFirstResponder()
    }
}
