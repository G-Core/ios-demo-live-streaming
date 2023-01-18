import UIKit

final class StreamSettingsController: UIViewController {
    private enum Titles: String {
        case urlType = "URL type"
        case quality = "Quality"
    }

    // MARK: - Public properties
  
    // MARK: - Private properties
    private let settingsView = StreamSettingsView()

    private lazy var doneButton: Button = {
        let button = Button()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private var data: [(title: String, subtitle: String)] = [] {
        didSet { settingsView.data = data }
    }

    private var urlSelectHandler: (Stream.URLPushType) -> Void = { _ in }
    private var qualitySelectHandler: (VideoSettings.VideoType) -> Void = { _ in }

    // MARK: - Public methods
    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func configure(
        currentSettings: (urlType: Stream.URLPushType, quality: VideoSettings.VideoType),
        urlSelectHandler: @escaping (Stream.URLPushType) -> Void,
        qualitySelectHandler: @escaping (VideoSettings.VideoType) -> Void
    ) {
        self.urlSelectHandler = urlSelectHandler
        self.qualitySelectHandler = qualitySelectHandler

        data = [
            (title: Titles.urlType.rawValue, subtitle: currentSettings.urlType.rawValue),
            (title: Titles.quality.rawValue, subtitle: currentSettings.quality.description)
        ]
    }

    // MARK: - Private methods
    private func setupView() {
        title = "Settings"
        settingsView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }

    @objc private func doneButtonTapped() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - StreamSettingsViewDelegate
extension StreamSettingsController: StreamSettingsViewDelegate {
    func cellDidSelect(at index: Int) {
        let vc = StreamSettingsSelectorController()

        switch index {
        case 0:
            guard let tuple = data.first(where: { $0.title == Titles.urlType.rawValue }),
                  let type = Stream.URLPushType(rawValue: tuple.subtitle)
            else {
                return
            }

            vc.type = .url
            vc.selectedURLType = type

            vc.selectURLTypeHandler = { [weak self] type in
                self?.data[0].subtitle = type.rawValue
                self?.urlSelectHandler(type)
            }

        case 1:
            guard let tuple = data.first(where: { $0.title == Titles.quality.rawValue }),
                  let type = VideoSettings.VideoType(description: tuple.subtitle)
            else {
                return
            }

            vc.type = .quality
            vc.selectedQuality = type

            vc.selectQualityHandler = { [weak self] type in
                self?.data[1].subtitle = type.description
                self?.qualitySelectHandler(type)
            }

        default:
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - StreamSettingsNavigationController
final class StreamSettingsNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        navigationBar.tintColor = .orange
    }
}
