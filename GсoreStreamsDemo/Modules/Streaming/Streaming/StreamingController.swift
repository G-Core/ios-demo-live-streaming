import UIKit
import AVFoundation

final class StreamingController: BaseViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13, *) else { return .lightContent }
        return .darkContent
    }

    private let streamingView = StreamingView()
    
    private var activitiIndicatorFooter: ViewingCollectionFooter?
    private var data: [Stream] = []

    private var filter = "" {
        didSet { streamingView.tableView.reloadData() }
    }

    private var filteredData: [Stream] {
        data.filter { $0.name.hasPrefix(filter) }
    }

    private var currentPage = 1
    
    override func loadView() {
        streamingView.delegate = self
        view = streamingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadStreams(page: currentPage)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    private func setupView() {
        streamingView.backgroundColor = .white
        streamingView.state = .proccess
        streamingView.tableView.delegate = self
        streamingView.tableView.dataSource = self
    }

    private func loadStreams(page: Int) {
        guard let token = Settings.shared.accessToken else {
            return refreshToken()
        }
        
        if streamingView.state == .empty {
            streamingView.state = .proccess
        }

        let http = HTTPCommunicator()
        let requst = StreamsRequest(token: token, page: page)

        http.request(requst) { [self] result in
            DispatchQueue.main.async { [self] in   
                switch result {
                case .failure(let error): 
                    if let error = error as? ErrorResponse, error == .invalidToken {
                        Settings.shared.accessToken = nil
                        refreshToken()
                    } else {
                        errorHandle(error)
                    }

                case .success(let streams):
                    for stream in streams where !data.contains(where: { $0.id == stream.id }) {
                        data += [stream]
                    }
                    
                    if data.count >= currentPage * 25 {
                        currentPage += 1
                    }

                    guard !data.isEmpty else {
                        streamingView.state = .empty
                        return
                    }
                    
                    streamingView.tableView.reloadData()
                    streamingView.state = .content
                    
                    activitiIndicatorFooter?.activityIndicator.stopAnimating()
                    activitiIndicatorFooter?.activityIndicator.transform = .init(scaleX: 0, y: 0)
                    activitiIndicatorFooter?.isLoading = false

                    guard !data.isEmpty else {
                        streamingView.state = .empty
                        return
                    }
                }
            }
        }
    }
    
    override func errorHandle(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.data.isEmpty {
                self.streamingView.state = .empty
            }
            
            if let error = error as? ErrorResponse {
                
                switch error {
                case .invalidCredentials:
                    let action: ((UIAlertAction) -> Void)? = { _ in
                        self.streamingView.window?.rootViewController = LoginViewController()
                    }
                    
                    let alert = self.createAlert(title: error.rawValue, actionHandler: action)
                    self.present(alert, animated: true)
                    
                default:
                    self.present(self.createAlert(title: error.rawValue), animated: true)
                }
            } else {
                self.present(self.createAlert(), animated: true)
            }
            
            self.activitiIndicatorFooter?.activityIndicator.stopAnimating()
            self.activitiIndicatorFooter?.activityIndicator.transform = .init(scaleX: 0, y: 0)
            self.activitiIndicatorFooter?.isLoading = false
        }
    }
    
    override func tokenDidUpdate() {
        loadStreams(page: currentPage)
    }

    private func checkPermissions() -> Bool {
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
            AVCaptureDevice.requestAccess(for: .audio) { _ in
                if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                    AVCaptureDevice.requestAccess(for: .video) { _ in }
                }
            }
            return false
        }

        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            return false
        } 

        return true
    }

    private func openStreamScreen(at index: Int) {
        let vc = StreamCaptureController()
        vc.stream = data[index]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension StreamingController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: streamingView.cellId)

        let data = filteredData[indexPath.row]
        
        if #available(iOS 14, *) {
            var config = UIListContentConfiguration.cell()
            config.text = data.name
            config.secondaryText = "ID: \(data.id)"
            config.textProperties.color = .grey800 ?? .black
            config.secondaryTextProperties.color = .grey600 ?? .black
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = data.name
            cell.textLabel?.textColor = .grey800
            cell.detailTextLabel?.textColor = .grey600
            cell.detailTextLabel?.text = "ID: \(data.id)"
        }

        cell.backgroundColor = .white
        cell.accessoryView = UIImageView(image: .arrowRightIcon)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        71
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkPermissions() {
            openStreamScreen(at: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StreamingController: StreamingViewDelegate {
    func reload() {
        loadStreams(page: 1)
    }

    func applyFilter(_ filter: String) {
        self.filter = filter
    }

    func createStream() {
        let vc = StreamCreateController()
        vc.streamDidCreate = { stream in
            DispatchQueue.main.async { [self] in
                data.append(stream)
                streamingView.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class StreamingNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .orange
    }
}
