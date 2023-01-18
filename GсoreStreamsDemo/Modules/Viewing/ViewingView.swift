import UIKit

protocol ViewingViewDelegate: AnyObject {
    func reload()
}

final class ViewingView: UIView {
    enum State {
        case empty, proccess, content
    }

    weak var delegate: ViewingViewDelegate?

    var state: State = .proccess {
        didSet {
            switch state {
            case .empty: showEmptyState()
            case .proccess: showProccessState()
            case .content: showContentState()
            }
        }
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let cellNib = UINib(nibName: StreamViewingCell.nibName, bundle: nil)
        let footerNib = UINib(nibName: ViewingCollectionFooter.nibName, bundle: nil)
        let footerKind =  UICollectionView.elementKindSectionFooter
        
        view.register(cellNib, forCellWithReuseIdentifier: StreamViewingCell.reuseId)
        view.register(footerNib, forSupplementaryViewOfKind: footerKind, withReuseIdentifier: ViewingCollectionFooter.reuseId)
        view.backgroundColor = .white
        
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "View streams"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "View streams that are already active."
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .grey800
        view.transform = .init(scaleX: 2, y: 2)
        view.hidesWhenStopped = false
        view.startAnimating()
        return view
    }()
    
    private let emptyView = EmptyStateView()
    
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
    
    private func showContentState() {
        indicatorView.isHidden = true
        emptyView.isHidden = true
        collectionView.isHidden = false
    }
    
    private func showEmptyState() {
        indicatorView.isHidden = true
        emptyView.isHidden = false
        collectionView.isHidden = true
    }
    
    private func showProccessState() {
        indicatorView.isHidden = false
        emptyView.isHidden = true
        collectionView.isHidden = true
    }
}

private extension ViewingView {
    func initLayout() {
        let views = [
            titleLabel,
            subtitleLabel,
            collectionView, 
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

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),

            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            emptyView.topAnchor.constraint(equalTo: topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            emptyView.leftAnchor.constraint(equalTo: leftAnchor),
            emptyView.rightAnchor.constraint(equalTo: rightAnchor),

            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension ViewingView: StateViewDelegate {
    func tapReloadButton() {
        delegate?.reload()
    }
}
