import UIKit

class BaseViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }
    
    final func refreshToken() {
        print("Refresh token")
        guard let token = Settings.shared.refreshToken else {
            relogin()
            return
        }
        
        let http = HTTPCommunicator()
        let request = RefreshTokenRequest(token: token)
      
        http.request(request) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {   
                switch result {
                case .failure(let error): 
                    if let error = error as? ErrorResponse, error == .invalidToken {
                        Settings.shared.refreshToken = nil
                        self.relogin()
                    } else {
                        self.errorHandle(error)
                    }

                case .success(let tokens): 
                    print(tokens)
                    Settings.shared.accessToken = tokens.access
                    Settings.shared.refreshToken = tokens.refresh
                    self.tokenDidUpdate()
                }
            }
        }
    }
    
    final func relogin() {
        print("User begin relogin")
        guard let name = Settings.shared.username, let password = Settings.shared.userPassword else {
            view.window?.rootViewController = LoginViewController()
            return
        }
        
        let http = HTTPCommunicator()
        let request = AuthenticationRequest(username: name, password: password)
        
        http.request(request) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error): 
                    if let error = error as? ErrorResponse, error == .invalidCredentials {
                        Settings.shared.username = nil
                        Settings.shared.userPassword = nil
                    }
                    self.errorHandle(error)

                case .success(let tokens): 
                    Settings.shared.accessToken = tokens.access
                    Settings.shared.refreshToken = tokens.refresh
                    self.tokenDidUpdate()
                }
            }
        }
    }
    
    func errorHandle(_ error: Error) {
        fatalError("Subclass must be overriding this method")
    }
    
    func tokenDidUpdate() {
        fatalError("Subclass must be overriding this method")
    }
    
    func createAlert(
        title: String = "Unexpected error", 
        message: String? = nil, 
        actionTitle: String = "Cancel",
        actionHandler: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: actionTitle, style: .cancel, handler: actionHandler)
        alertController.addAction(action)
        return alertController
    }   
}
