import UIKit

protocol StreamingViewDelegate: AnyObject {
    func reload()
    func applyFilter(_ filter: String)
    func createStream()
}

final class StreamingView: UIView {
    enum State {
        case empty, proccess, content
    }

    // MARK: - Public properties
    weak var delegate: StreamingViewDelegate?

    var state: State = .proccess {
        didSet {
            switch state {
            case .empty: showEmptyState()
            case .proccess: showProccessState()
            case .content: showContentState()
            }
        }
    }

    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        let footerNib = UINib(nibName: ViewingCollectionFooter.nibName, bundle: nil)
        let footerKind =  UICollectionView.elementKindSectionFooter

        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        table.register(footerNib, forHeaderFooterViewReuseIdentifier: footerId)
        table.backgroundColor = .clear

        table.contentInset.top = 20
        table.contentInset.bottom = 20

        return table
    }()

    let cellId = "Table cell"
    let footerId = ViewingCollectionFooter.reuseId

    // MARK: - Private properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Streaming"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select the stream if you want to stream to or create a new stream."
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .black

        return label
    }()

    private lazy var createStreamButton: UIButton = {
        let button = Button()
        button.addTarget(self, action: #selector(createStream), for: .touchUpInside)
        button.backgroundColor = .grey800
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Create new stream", for: .normal)

        return button
    }()

    private lazy var searchTextField: UITextField = {
        let field = TextField()
        field.placeholder = "Search"
        field.padding.left = 24
        field.delegate = self
        field.leftViewMode = .always
        field.leftView = UIImageView(image: .magnifyingGlassIcon)
        field.borderStyle = .none
        field.clipsToBounds = true
        field.layer.cornerRadius = 4
        field.backgroundColor = .grey200

        let stringAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.grey600 ?? .gray]
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: stringAttr)

        return field
    }()

    private let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .grey800
        view.transform = .init(scaleX: 2, y: 2)
        view.hidesWhenStopped = false
        view.startAnimating()
        return view
    }()

    private lazy var emptyView: EmptyStateView = {
        let view = EmptyStateView()
        view.delegate = self
        view.setTitle("There are no available streams for\nstreaming yet.")
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
        emptyView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
        emptyView.delegate = self
    }

    // MARK: - Private methods
    private func showContentState() {
        indicatorView.isHidden = true
        emptyView.isHidden = true
        tableView.isHidden = false
    }
    
    private func showEmptyState() {
        indicatorView.isHidden = true
        emptyView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showProccessState() {
        indicatorView.isHidden = false
        emptyView.isHidden = true
        tableView.isHidden = true
    }

    @objc private func createStream() {
        delegate?.createStream()
    }
}

// MARK: - Layout
private extension StreamingView {
    func initLayout() {
        let views = [
            titleLabel,
            subtitleLabel,
            createStreamButton,
            searchTextField,
            tableView, 
            indicatorView,
            emptyView
        ]
        
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 0),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

            createStreamButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            createStreamButton.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
            createStreamButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createStreamButton.heightAnchor.constraint(equalToConstant: 48),

            searchTextField.topAnchor.constraint(equalTo: createStreamButton.bottomAnchor, constant: 16),
            searchTextField.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
            searchTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),

            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            emptyView.topAnchor.constraint(equalTo: topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            emptyView.leftAnchor.constraint(equalTo: leftAnchor),
            emptyView.rightAnchor.constraint(equalTo: rightAnchor),

            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - StateViewDelegate
extension StreamingView: StateViewDelegate {
    func tapReloadButton() {
        delegate?.reload()
    }
}

// MARK: - UITextFieldDelegate
extension StreamingView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let newString = (textField.text as? NSString)?.replacingCharacters(in: range, with: string),
              newString.count <= 50
        else {
            return false
        }

        delegate?.applyFilter(newString)
        return true
    }
}

