import UIKit

public class LocationInputView: UIView {
    
    @IBOutlet weak var maximizeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
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
        
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        searchTextField.inputView = nil
        searchTextField.becomeFirstResponder()
        
    }
    
    @objc func close() {
        // self.superview?.endEditing(true) // not working
    }
    
}

