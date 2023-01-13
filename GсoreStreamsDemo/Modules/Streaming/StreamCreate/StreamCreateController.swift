import UIKit

final class StreamCreateController: BaseViewController {
    var streamDidCreate: (Stream) -> Void = { _ in }

    private let streamCreateView = StreamCreateView()

    override func loadView() {
        view = streamCreateView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        streamCreateView.delegate = self
        navigationController?.navigationBar.isHidden = false
    }

    override func errorHandle(_ error: Error) {
        print((error as NSError).description)
    }
}

extension StreamCreateController: StreamCreateViewDelegate {
    func createStream(with name: String) {
        guard let token = Settings.shared.accessToken else {
            refreshToken()
            return
        }

        let http = HTTPCommunicator()
        let requst = CreateStreamRequest(token: token, name: name)
        http.request(requst) { [weak self] result in
            switch result {
            case .success(let stream):
                self?.streamDidCreate(stream)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self?.errorHandle(error)
            }
        }
        
    }
}
