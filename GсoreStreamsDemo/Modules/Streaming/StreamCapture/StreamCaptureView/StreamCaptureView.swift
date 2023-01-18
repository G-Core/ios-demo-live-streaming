import UIKit
import AVKit
import HaishinKit

protocol StreamCaptureViewDelegate: AnyObject {
    func dismiss()
    func flipCamera()
    func showSettings()
    func toggleStartStream(isOn: Bool, handler: (Bool) -> Void)
    func toggleMuteMicro(isOn: Bool, handler: (Bool) -> Void)
    func togglePlay(isOn: Bool, handler: (Bool) -> Void)
}

final class StreamCaptureView: UIView {
    // MARK: - Public properties
    weak var delegate: StreamCaptureViewDelegate?

    // MARK: - Private properties
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var sideButtons: [Button]!
    @IBOutlet private var bottomButtonsStackViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var videoDataStackView: UIStackView!
    @IBOutlet private weak var settingsView: UIView!

    @IBOutlet private weak var currentFPSLabel: UILabel!
    @IBOutlet private weak var currentBitrateLabel: UILabel!
    @IBOutlet private weak var streamStatusLabel: UILabel!

    @IBOutlet private weak var togglePlayButton: Button!

    private let hkView = HKView(frame: .zero)

    private lazy var backButton: Button = {
        let button = Button()
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.setImage(.caretLeftIcon, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: button.intrinsicContentSize.width + 10).isActive = true

        if #available(iOS 15, *) {
            button.configuration?.imagePadding = 10
        } else {
            button.titleEdgeInsets.left = 10
        }

        return button
    }()

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
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        hkView.frame = contentView.bounds
    }

    @inline(__always)
    func attachStream(_ stream: NetStream?) {
        hkView.attachStream(stream)
    }

    @inline(__always)
    func setVideoData(fps: Int, bitrate: Int) {
        currentFPSLabel.text = "Current fps: \(fps)"
        currentBitrateLabel.text = "Current bitrate: \(bitrate)"
    }

    // MARK: - Private methods
    @inline(__always)
    private func loadNib() {
        let nibName = String(describing: Self.self)
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @inline(__always)
    private func setupView() {
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        hkView.backgroundColor = .white
        contentView.insertSubview(hkView, at: 0)
        bottomButtonsStackViewWidthConstraint.constant = ScreenSize.width - 32

        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        if #unavailable(iOS 15) {
            sideButtons.forEach {
                guard let imageView = $0.imageView else { return }
                
                let imageDefaultPadding = $0.imageEdgeInsets.right
                let imageSize = imageView.bounds
                
                $0.contentEdgeInsets.left = -imageSize.width
                $0.contentEdgeInsets.top = imageSize.height + imageDefaultPadding
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: $0.topAnchor),
                    imageView.centerXAnchor.constraint(equalTo: $0.centerXAnchor)
                ])
            }
        }
    }

    @inline(__always)
    private func updateViewState(_ view: UIView) {
        let state = view.tag
        
        switch view {
        case _ where view == togglePlayButton:
            guard let button = view as? UIButton else { break }

            let image: UIImage? = state == 1 ? .pauseIcon : .playIcon
            let title = state == 1 ? "Pause" : "Play"

            button.setImage(image, for: .normal)
            button.setTitle(title, for: .normal)

        case _ where view == streamStatusLabel:
            guard let label = view as? UILabel else { break }

            label.backgroundColor = state == 1 ? UIColor.red : UIColor.yellow
            label.text = state == 1 ? "Live" : "Pause"

        default:
            break
        }
    }

    @objc private func backButtonTapped() {
        delegate?.dismiss()
    }

    @IBAction private func settingsButtonTapped(_ sender: Button) {
        delegate?.showSettings()
    }

    @IBAction private func cameraFlipButtonTapped(_ sender: Button) {
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { sender.isEnabled = true }
        delegate?.flipCamera()
    }

    @IBAction private func toggleMuteButtonTapped(_ sender: Button) {
        sender.isEnabled = false
        delegate?.toggleMuteMicro(isOn: sender.tag == 1) { isSuccess in
            sender.isEnabled = true

            guard isSuccess else { return }

            let state = sender.tag == 0 ? 1 : 0
            sender.tag = state

            let image: UIImage? = state == 0 ? .microEnableIcon : .microDisableIcon
            let title = state == 0 ? "Mute" : "Unmute"
            sender.setImage(image, for: .normal)
            sender.setTitle(title, for: .normal)
        }
    }

    @IBAction private func togglePlayButtonTapped(_ sender: Button) {
        sender.isEnabled = false
        delegate?.togglePlay(isOn: sender.tag == 0) { [weak self] isSuccess in
            sender.isEnabled = true

            guard isSuccess, let self = self else { return }

            let state = sender.tag == 0 ? 1 : 0

            sender.tag = state
            self.streamStatusLabel.tag = state

            self.updateViewState(sender)
            self.updateViewState(self.streamStatusLabel)
        }
    }

    @IBAction private func toggleStartButtonTapped(_ sender: Button) {
        sender.isEnabled = false
        delegate?.toggleStartStream(isOn: sender.tag == 0) { [weak self] isSuccess in
            sender.isEnabled = true

            guard isSuccess, let self = self else { return }

            let state = sender.tag == 0 ? 1 : 0
            sender.tag = state

            let title = state == 0 ? "Start stream" : "Stop stream"
            sender.setTitle(title, for: .normal)

            [self.togglePlayButton, self.streamStatusLabel, self.videoDataStackView].forEach {
                $0?.isHidden = state == 0
            }

            [navigationBar, settingsView].forEach { $0?.isHidden = state == 1 }
            [togglePlayButton, streamStatusLabel].forEach { $0?.tag = state}
            
            self.updateViewState(togglePlayButton)
            self.updateViewState(streamStatusLabel)
        }
    }
}
