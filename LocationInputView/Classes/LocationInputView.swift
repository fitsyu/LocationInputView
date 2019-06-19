import UIKit
import CoreLocation
import MapKit
import LocationPicker


public class LocationInputView: UIView {
    
    public var delegate: LocationInputViewDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var gear: UIActivityIndicatorView!
    @IBOutlet weak var placeIcon: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var maximizeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    // MARK: Internal Properties
    private var location: CLLocation?
    private var placeMark: CLPlacemark?
    
    private var navigationController: UINavigationController?
    
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
    
    
    // MARK: Construction
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
        searchTextField.addTarget(self, action: #selector(openLocationPicker), for: .editingDidBegin)

        
        
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
    
    
    // MARK: Targets
    @objc func close() {
        delegate?.didClose()
    }
    
    @objc func recenter() {
        if let center = locman.location?.coordinate {
            
            let region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: 100,
                                            longitudinalMeters: 100)
            
            self.mapView.setRegion(region, animated: true)
            
        } else {
            print("no user location")
        }
    }
    
    @objc func insertLocation() {
        if let location = self.location {
            delegate?.didInputLocation(location: location, placemark: self.placeMark)
        }
    }
    
    @objc func maximise() {
        
        var region = mapView.region
        region.span.latitudeDelta += 10
        region.span.longitudeDelta += 10
        
        mapView.setRegion(region, animated: true)
    }
    
    @objc func geocodingCompelete(placeMark: CLPlacemark?) {
        self.placeMark = placeMark
        
        let text = [placeMark?.name,
                    placeMark?.subLocality,
                    placeMark?.subAdministrativeArea,
                    placeMark?.administrativeArea,
                    placeMark?.country
                ]
            .compactMap { $0 }
            .joined(separator: ", ")
        self.locationLabel.text = text
    }
    
    @objc func openLocationPicker() {
        
        // setup the location picker
        let locationPicker = LocationPickerViewController()
        locationPicker.mapType = .standard
        locationPicker.completion = { locationAnnotation in
            
            if let location = locationAnnotation?.location {
                
                let region = MKCoordinateRegion(center: location.coordinate,
                                                latitudinalMeters: 100,
                                                longitudinalMeters: 100)
                
                self.mapView.setRegion(region, animated: true)
                
                self.delegate?.didInputLocation(location: location,
                                                placemark: locationAnnotation?.placemark)
            }
        }
        
        
        // add cancel button to dismiss it
        locationPicker.navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeLocationPicker))
        
        // set the wrapper
        let nc = UINavigationController(rootViewController: locationPicker)
        
        self.navigationController = nc
        
        // show it modally
        UIApplication.shared
            .topViewController()?
            .present(nc, animated: true, completion: {})
    }
    
    // dismiss the modally presented LocationPicker
    @objc func closeLocationPicker() {
        navigationController?.dismiss(animated: true, completion: nil)
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
        
        let targetingIcon = UIImage(podAssetName: "my_location")?
            .withRenderingMode(.alwaysTemplate)
        
        self.placeIcon.image = targetingIcon
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let targetedIcon = UIImage(podAssetName: "place")?.withRenderingMode(.alwaysTemplate)
        self.placeIcon.image = targetedIcon
        self.placeIcon.transform = CGAffineTransform.identity
        
        // change
        locationLabel.isHidden = true
        gear.isHidden = false
        gear.startAnimating()
        
        let center = mapView.centerCoordinate
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        self.location = location
        
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
