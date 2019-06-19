//
//  LocationInputViewDelegate.swift
//  LocationInputView
//
//  Created by iOSDev on 19/06/19.
//

import CoreLocation

public protocol LocationInputViewDelegate {
    
    func didInputLocation(location: CLLocation, placemark: CLPlacemark?)
    
    func didClose()
}
