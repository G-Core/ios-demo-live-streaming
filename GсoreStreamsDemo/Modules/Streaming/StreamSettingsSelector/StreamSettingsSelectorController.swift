import UIKit

enum SettingsType {
    case url, quality
}

final class StreamSettingsSelectorController: UIViewController {
    // MARK: - Public properties
    var type: SettingsType?

    var selectedQuality: VideoSettings.VideoType?
    var selectedURLType: Stream.URLPushType?

    var selectQualityHandler: (VideoSettings.VideoType) -> Void = { _ in }
    var selectURLTypeHandler: (Stream.URLPushType) -> Void = { _ in }

    // MARK: - Private properties
    private let selectorView = StreamSettingsSelectorView()

    private let qualityData: [VideoSettings.VideoType] = VideoSettings.VideoType.allCases
    private let urlTypeData: [Stream.URLPushType] = Stream.URLPushType.allCases

    // MARK: - Life cycle 
    override func loadView() {
        view = selectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Private methods
    private func setupView() {
        selectorView.delegate = self

        switch type {
        case .url:
            guard let urlType = selectedURLType else { return }
            selectorView.selectedType = urlType.rawValue
            selectorView.data = urlTypeData.map { $0.rawValue }
        case .quality :
            guard let quality = selectedQuality else { return }
            selectorView.selectedType = quality.description
            selectorView.data = qualityData.map { $0.description }
        default:
            break
        }

        title = type == .quality ? "Quality" : "URL type"
    }
}

// MARK: - StreamSettingsSelectorViewDelegate
extension StreamSettingsSelectorController: StreamSettingsSelectorViewDelegate {
    func cellDidSelect(at index: Int) {
        switch type {
        case .quality: selectQualityHandler(qualityData[index])
        case .url: selectURLTypeHandler(urlTypeData[index])
        default: break
        }
    }
}
