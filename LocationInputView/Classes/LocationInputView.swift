import UIKit
import CoreLocation
import MapKit

public protocol LocationInputViewDelegate {
    
    func didInputLocation(location: CLLocation, placemark: CLPlacemark?)
    
    func didClose()
}

public class LocationInputView: UIView {
    
    public var delegate: LocationInputViewDelegate?
    
    @IBOutlet weak var gear: UIActivityIndicatorView!
    @IBOutlet weak var placeIcon: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var maximizeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    private var locman = CLLocationManager()
    
    private var view: UIView!
    
    private lazy var bundle: Bundle = {
        
        let url = Bundle(for: self.classForCoder).url(forResource: "LocationInputView", withExtension: "bundle")
        if url == nil {
            print("failed to load bundle")
        }
        
        let bundle = Bundle(url: url!)
        if bundle == nil {
            print("failed to load bundle")
        }
        
        return bundle!
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        
        print("awake from nib")
        
        let nib = bundle.loadNibNamed("View", owner: self, options: nil)
        
        view = nib?.first as? UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        searchTextField.inputView = UIView()
        searchTextField.becomeFirstResponder()
        
        
        locman.requestWhenInUseAuthorization()
        locman.delegate = self

        if ( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ) {
            locman.desiredAccuracy = kCLLocationAccuracyBest
            locman.distanceFilter = 20.0 // 20 m
            locman.startUpdatingLocation()
        } else {
            print("location is not permitted")
        }
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        maximizeButton.addTarget(self, action: #selector(maximise), for: .touchUpInside)
        centerButton.addTarget(self, action: #selector(recenter), for: .touchUpInside)
        
        useButton.addTarget(self, action: #selector(insertLocation), for: .touchUpInside)
        
        recenter()
        
        [cancelButton, maximizeButton, centerButton].forEach {
            let bgImg = $0?.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            $0?.setImage(bgImg, for: .normal)
        }
        
        placeIcon.image = placeIcon.image?.withRenderingMode(.alwaysTemplate)
    }
    
    @objc func close() {
        delegate?.didClose()
    }
    
    @objc func recenter() {
        if let center = locman.location?.coordinate {
            
            let region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: 50,
                                            longitudinalMeters: 50)
            
            self.mapView.setRegion(region, animated: true)
            
        } else {
            print("no user location")
        }
    }
    
    @objc func insertLocation() {
        if let location = locman.location {
            delegate?.didInputLocation(location: location, placemark: self.placeMark)
        }
    }
    
    @objc func maximise() {
        
        // not working
//        print(self.frame)
//        self.frame.size.height += 200
//        self.layoutIfNeeded()
//        self.setNeedsLayout()
    }
    
    var placeMark: CLPlacemark?
    @objc func geocodingCompelete(placeMark: CLPlacemark?) {
        self.placeMark = placeMark
        
        let text = [placeMark?.name, placeMark?.subLocality, placeMark?.country]
            .compactMap { $0 }
            .joined(separator: ", ")
        self.locationLabel.text = text
    }
}


extension LocationInputView: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("oh no! error has occured")
        print(error)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse ) {
            manager.startUpdatingLocation()
        } else {
            print("location is not permitted")
        }
    }
}


extension LocationInputView: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // change
        locationLabel.isHidden = true
        gear.isHidden = false
        gear.startAnimating()
        
        let center = mapView.centerCoordinate
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location,
                                            completionHandler: { (places, error) in
                                                
                                                let place = places?.first
                                                self.geocodingCompelete(placeMark: place)
                                                
                                                // restore
                                                self.gear.stopAnimating()
                                                self.gear.isHidden = true
                                                self.locationLabel.isHidden = false
        })
        
    }
}
