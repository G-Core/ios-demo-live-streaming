import UIKit

final class TextField: UITextField {
    var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.rightViewRect(forBounds: bounds)
        bounds.origin.x -= 15
        return bounds
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.leftViewRect(forBounds: bounds)
        bounds.origin.x = 4
        return bounds
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func resignFirstResponder() -> Bool {
        layer.borderColor = UIColor.grey200?.cgColor
        return super.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        layer.borderColor = UIColor.orange?.cgColor
        return super.becomeFirstResponder()
    }

    private func setupView() {
        isSecureTextEntry = false
        
        backgroundColor = .grey200
        tintColor = .orange
        textColor = .grey800
        
        font = .systemFont(ofSize: 17, weight: .regular)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.grey200?.cgColor
        layer.cornerRadius = 4
    }
}
