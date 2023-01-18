import UIKit

protocol ProfileMainViewDelegate: AnyObject {
    func signOut()
}

final class ProfileMainView: UIView {
    weak var delegate: ProfileMainViewDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Account"
        label.font = .systemFont(ofSize: 28, weight: .bold)

        return label
    }()

    private let usernameLabel: Label = {
        let label = Label()
        label.text = Settings.shared.username
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .grey600
        label.textAlignment = .left
        label.backgroundColor = .grey200
        label.layer.cornerRadius = 4

        return label
    }()

    private let signOutButton: Button = {
        let button = Button()
        button.layer.cornerRadius = 4
        button.setTitle("Sign out", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .grey200
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        initLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        initLayout()
    }

    private func initLayout() {
        [titleLabel, usernameLabel, signOutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 0),
            
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            usernameLabel.heightAnchor.constraint(equalToConstant: 37),
            usernameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            usernameLabel.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
            
            signOutButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 32),
            signOutButton.heightAnchor.constraint(equalToConstant: 48),
            signOutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
        ])
    }
    
    @objc private func signOutButtonTapped() {
        delegate?.signOut()
    }
}


