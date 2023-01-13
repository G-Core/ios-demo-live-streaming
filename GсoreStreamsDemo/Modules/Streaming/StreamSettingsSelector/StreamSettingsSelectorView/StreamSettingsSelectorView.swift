import UIKit
protocol StreamSettingsSelectorViewDelegate: AnyObject {
    func cellDidSelect(at index: Int)
}

final class StreamSettingsSelectorView: UIView {
    // MARK: - Public properties
    weak var delegate: StreamSettingsSelectorViewDelegate?
    var selectedType = ""

    var data: [String] = [] {
        didSet { tableView.reloadData() }
    }

    // MARK: - Private properties
    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var tableView: UITableView!

    private let cellId = StreamSettingsSelectorCell.reuseId

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
    private func loadNib() {
        let nibName = String(describing: Self.self)
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    private func setupView() {
        let nib = UINib(nibName: StreamSettingsSelectorCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
}

// MARK: - UITableViewDelegate
extension StreamSettingsSelectorView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        delegate?.cellDidSelect(at: indexPath.row)

        if #available(iOS 15, *) {
            tableView.visibleCells.forEach {
                var config = $0.contentConfiguration as? UIListContentConfiguration 
                config?.textProperties.color = .grey800 ?? .black
                $0.contentConfiguration = config
            }

            var config = cell.contentConfiguration as? UIListContentConfiguration
            config?.textProperties.color = .orange ?? .black
            cell.contentConfiguration = config

            selectedType = config?.text ?? ""

        } else {
            tableView.visibleCells.forEach { $0.textLabel?.textColor = .grey800 }
            cell.textLabel?.textColor = .orange
            selectedType = cell.textLabel?.text ?? ""
        }

        tableView.visibleCells.forEach { $0.accessoryType = .none }
        cell.accessoryType = .checkmark

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension StreamSettingsSelectorView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! StreamSettingsSelectorCell

        switch indexPath.row {
        case 0: cell.firstCellSetup()
        case data.count - 1: cell.lastCellSetup()
        default: cell.commonSetup()
        }

        let text = data[indexPath.row]
        if #available(iOS 15, *) {
            var config = UIListContentConfiguration.cell()
            config.text = text
            config.textProperties.font = .systemFont(ofSize: 17)

            if selectedType == text {
                config.textProperties.color = .orange ?? .black
            } else {
                config.textProperties.color = .grey800 ?? .black
            }
            
            cell.contentConfiguration = config

        } else {
            cell.textLabel?.text = text
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = text == selectedType ? .orange : .grey800
        }

        cell.tintColor = .orange
        cell.accessoryType = text == selectedType ? .checkmark : .none

        return cell
    }
}
