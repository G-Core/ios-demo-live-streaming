import UIKit

protocol StreamCreateViewDelegate: AnyObject {
    func createStream(with name: String)
}

final class StreamCreateView: UIView {
    // MARK: - Public properties
    weak var delegate: StreamCreateViewDelegate?

    // MARK: - Private properties
    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var streamNameTextField: TextField!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    // MARK: - Public methods

    // MARK: - Private methods
    @inline(__always)
    private func loadNib() {
        let nibName = String(describing: Self.self)
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addContentView(contentView)
    }

    @inline(__always)
    private func createStream() {
        if let name = streamNameTextField.text {
            delegate?.createStream(with: name)
        } else {
            streamNameTextField.layer.borderColor = UIColor.orange?.cgColor
        }
    }

    @IBAction func createStreamButtonTapped(_ sender: Button) {
        createStream()
    }
}

extension StreamCreateView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createStream()
        return textField.resignFirstResponder()
    }
}
