 import UIKit

protocol StreamSettingsViewDelegate: AnyObject {
    func cellDidSelect(at index: Int)
}

final class StreamSettingsView: UIView {
    // MARK: - Public properties
    weak var delegate: StreamSettingsViewDelegate?

    var data: [(title: String, subtitle: String)] = [] {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Private properties
    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var collectionView: UICollectionView!

    private let cellId = StreamSettingsCell.reuseId
    private let cellSize = CGSize(width: ScreenSize.width - 32, height: 44)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        setupView()
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
    private func setupView() {
        let cellNib = UINib(nibName: StreamSettingsCell.nibName, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellId)
    }
}

// MARK: - UICollectionViewDataSource
extension StreamSettingsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StreamSettingsCell
        let data = data[indexPath.row]
        cell.configure(title: data.title, secondaryTitle: data.subtitle)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension StreamSettingsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cellDidSelect(at: indexPath.row)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StreamSettingsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
}
