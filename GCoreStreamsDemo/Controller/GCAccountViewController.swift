//
//  GCAccountViewController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit

final class GCAccountViewController: UIViewController {
    lazy var networkManager = NetworkManager(delegate: self)
    var selectedLogin = ""
    var selectedPassword = ""
    
    let model = GCModel.shared
    let gcoreTitle = GCHeaderLabel()
    let userTextField = UITextField()
    let currentUserLabel = GCSelectedUserView()
    let passwordTextField = UITextField()
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func loadView() {
        super.loadView()
        view.addSubview(gcoreTitle)
        view.addSubview(activityIndicator)
        view.addSubview(currentUserLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTextField(userTextField)
        setupTextField(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        userTextField.placeholder = NSLocalizedString("Enter the login", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Enter the password", comment: "")
        createConstraints()
    }
    
    private func setupTextField(_ field: UITextField) {
        view.addSubview(field)
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.textColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.6)
        field.font = UIFont.systemFont(ofSize: 14)
        field.keyboardType = .asciiCapable
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        field.leftViewMode = .always
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            userTextField.heightAnchor.constraint(equalToConstant: userTextField.intrinsicContentSize.height + 10),
            passwordTextField.heightAnchor.constraint(equalToConstant: passwordTextField.intrinsicContentSize.height + 10),
        ])
    }
    
    private func createConstraints() {
        gcoreTitle.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        currentUserLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let userTextFieldCenterCons =  userTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        userTextFieldCenterCons.priority = .init(999)
        
        NSLayoutConstraint.activate([
            gcoreTitle.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20),
            gcoreTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            gcoreTitle.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -20),
            gcoreTitle.heightAnchor.constraint(equalToConstant: 40),
            
            userTextFieldCenterCons,
            userTextField.topAnchor.constraint(greaterThanOrEqualTo: currentUserLabel.bottomAnchor, constant: 5),
            userTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: userTextField.bottomAnchor, constant: 10),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 5),
            
            currentUserLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentUserLabel.topAnchor.constraint(equalTo: gcoreTitle.bottomAnchor, constant: 10),
            currentUserLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            currentUserLabel.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 9),
        ])
    }
}

extension GCAccountViewController {
    private func checkAccount() {
        guard let user = userTextField.text, let password = passwordTextField.text
        else { return }
        
        guard user != selectedLogin && (user != "" || password != "")
        else {
            pushErrorAllert(with: .invalidUserOrPassword)
            return
        }
        
        activityIndicator.startAnimating()
        tabBarController?.tabBar.isUserInteractionEnabled = false
        networkManager.authorization(login: user, password: password)
    }
    
    private func pushErrorAllert(with error: HTTPError) {
        DispatchQueue.main.async { [unowned self] in
            defer {
                activityIndicator.stopAnimating()
                tabBarController?.tabBar.isUserInteractionEnabled = true
            }
            
            let alert = UIAlertController.init(title: NSLocalizedString("Error!", comment: "") ,
                                               message: "",
                                               preferredStyle: .actionSheet)
            
            switch error {
            case .absentInternet: alert.message = NSLocalizedString("connection failed.", comment: "")
            case .invalidUserOrPassword: alert.message = NSLocalizedString("invalid user or password.", comment: "")
            default: alert.message = NSLocalizedString("unexpected error.", comment: "")
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }
}

//MARK: - UITextFieldDelegate
extension GCAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            checkAccount()
        }
        
        return textField.resignFirstResponder()
    }
}

extension GCAccountViewController: NetworkManagerDelegate {
    func authorizationSuccess(userInfo: [String : String]) {
        model.accessToken = userInfo["accessToken"] ?? ""
        model.refreshToken = userInfo["refreshToken"] ?? ""
        networkManager.token = model.accessToken
        networkManager.downloadAllStreams()
    }
    
    func streamsDidDownload(_ streams: [GCStream]) {
        model.streams = streams
        var streamIDs: [Int] = []
        streams.forEach({ streamIDs += [$0.id] })
        networkManager.downloadHLS(for: streamIDs)
        var broadcastsID: Set<String> = []
        
        for stream in streams {
            stream.broadcastIDs.forEach { broadcastsID.insert(String($0)) }
        }
        
        for id in broadcastsID {
            networkManager.downloadBroadcastWith(id: id)
        }
        
        currentUserLabel.updateUser(userTextField.text ?? "")
        activityIndicator.stopAnimating()
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func broadcastDidDownload(_ broadcast: GCBroadcast) {
        model.broadcasts += [broadcast]
    }
    
    func streamHLSDidDownload(_ hls: URL, streamID: Int) {
        guard let index = model.streams.firstIndex(where: { $0.id == streamID })
        else { return }
        model.streams[index].hls = hls
    }
    
    func broadcastsDidDownload(_ broadcasts: [GCBroadcast]) {
        model.broadcasts = broadcasts
        currentUserLabel.updateUser(userTextField.text ?? "")
        activityIndicator.stopAnimating()
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func failedRequest(error: HTTPError) {
        pushErrorAllert(with: error)
    }
}
