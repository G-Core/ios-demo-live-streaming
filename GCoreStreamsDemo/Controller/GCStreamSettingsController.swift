//
//  GCStreamSettingsController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 21.11.2021.
//

import UIKit

protocol GCStreamSettingsControllerDelegate: AnyObject {
    func select(stream: GCStream?)
    func closeSettings()
    func deleteStream()
    func createStream(name: String)
    func selectVideoSetting(type: VideoSettings.VideoType)
    
    var videoType: VideoSettings.VideoType { get set }
}

final class GCStreamSettingsController: UIViewController {
    weak var delegate: GCStreamSettingsControllerDelegate?
    var model: GCModel!
   
    private let configureStreamButton = GCButton()
    private let videoSettingView = GCVideoSettingView()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.closeImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        
        return button
    }()

    private lazy var selectStreamView: GCSelectStreamView = {
        let view = GCSelectStreamView(delegate: self)
        self.view.insertSubview(view, at: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        return view
    }()

    private let createNewStreamButton: GCButton = {
        let button = GCButton()
        button.setTitle("New stream", for: .normal)
        button.addTarget(self, action: #selector(tapNewStreamButton), for: .touchUpInside)
        
        return button
    }()

    private let broadcastsButton: GCButton = {
        let button = GCButton()
        button.setTitle("Broadcasts", for: .normal)
        button.addTarget(self, action: #selector(tapBroadcastsButton), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.frame.size.height = view.frame.height/2
        view.roundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 30)
        view.addSubview(closeButton)
        view.addSubview(broadcastsButton)
        view.addSubview(createNewStreamButton)
        view.addSubview(configureStreamButton)
        view.addSubview(videoSettingView)
        videoSettingView.delegate = self
        videoSettingView.alpha = 0
        addGesture()

        createConstraints()
        configureStreamButton.addTarget(self, action: #selector(tapConfigureButton), for: .touchUpInside)
        updateType()
        
        guard let delegate = delegate
        else { return }
        
        videoSettingView.setupView(selected: delegate.videoType)
    }

    private func createConstraints() {
        NSLayoutConstraint.activate([
            selectStreamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectStreamView.topAnchor.constraint(equalTo: configureStreamButton.bottomAnchor, constant: 10),
            selectStreamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 200),
            selectStreamView.heightAnchor.constraint(equalToConstant: selectStreamView.intrinsicContentSize.height),

            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            createNewStreamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 90),
            createNewStreamButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -5),

            broadcastsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -90),
            broadcastsButton.centerYAnchor.constraint(equalTo: createNewStreamButton.centerYAnchor),

            configureStreamButton.topAnchor.constraint(equalTo:view.topAnchor, constant: 20),
            configureStreamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            configureStreamButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 200),

            videoSettingView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            videoSettingView.topAnchor.constraint(equalTo: view.topAnchor),
            videoSettingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoSettingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func updateType() {
        guard let delegate = delegate
        else { return }
        
        switch delegate.videoType {
        case .lq: configureStreamButton.setTitle("LQ", for: .normal)
        case .sq: configureStreamButton.setTitle("SQ", for: .normal)
        case .hq: configureStreamButton.setTitle("HQ", for: .normal)
        case .shq: configureStreamButton.setTitle("SHQ", for: .normal)
        case .hd720: configureStreamButton.setTitle("HD 720", for: .normal)
        }
    }

    @objc private func tapConfigureButton() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.videoSettingView.alpha = 1
        }
    }

    @objc private func tapCloseButton() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    @objc private func tapNewStreamButton() {
        let alertVC = UIAlertController(title: "Print the name", message: nil, preferredStyle: .alert)
        var textField: UITextField!
        
        alertVC.addTextField { field in
            field.delegate = self
            field.placeholder = "Name..."
            textField = field
        }

        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVC.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            self?.delegate?.createStream(name: textField.text ?? "")
        }))

        present(alertVC, animated: true)
    }

    @objc private func tapBroadcastsButton() {
        guard let streamIndex = model.streams.firstIndex(where: { $0.name == selectStreamView.text ?? "" }),
              let parentVC = parent
        else { return }
        
        let vc = GCBroadcastSettingsController()
        vc.streamIndex = streamIndex
        parentVC.present(vc, animated: true)

    }

    func updateData() {
        selectStreamView.pickerView.reloadAllComponents()
        selectStreamView.pickerView.selectRow(0, inComponent: 0, animated: true)
    }

    func updateStreamName(_ name: String) {
        selectStreamView.text = name
    }

    @objc func tapSelf() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.videoSettingView.alpha = 0
        }
    }

    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
    }

}

extension GCStreamSettingsController: GCSelectStreamViewDelegate {
    func tapDeleteButton() {
        delegate?.deleteStream()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        model.streams.count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        row == 0 ? "Stream not chosen" : model.streams[row-1].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectStreamView.text = "Stream not chosen"
            delegate?.select(stream: nil)
        } else {
            selectStreamView.text = model.streams[row-1].name
            delegate?.select(stream: model.streams[row-1])
        }
    }
}

extension GCStreamSettingsController: GCVideoSettingViewDelegate {
    func settingDidChange(type: VideoSettings.VideoType, typeString: String) {
        delegate?.selectVideoSetting(type: type)
        configureStreamButton.setTitle(typeString, for: .normal)
    }
}

extension GCStreamSettingsController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view?.isDescendant(of: videoSettingView) == true ? false : true
    }
}

private extension UIView {
   func roundCorners(corners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}


