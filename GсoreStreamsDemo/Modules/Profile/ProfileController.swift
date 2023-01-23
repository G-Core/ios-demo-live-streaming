import UIKit

final class ProfileController: BaseViewController {
    private let mainView = ProfileMainView()
    
    override func loadView() {
        mainView.delegate = self
        view = mainView
    }
}

extension ProfileController: ProfileMainViewDelegate {
    func signOut() {
        Settings.shared.username = nil
        Settings.shared.userPassword = nil
        Settings.shared.accessToken = nil
        Settings.shared.refreshToken = nil
        view?.window?.rootViewController = LoginViewController()
    }
}
