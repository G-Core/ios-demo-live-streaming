//
//  GCStreamsListViewController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 17.10.2021.
//

import UIKit
import AVFoundation

final class GCBroadcastListViewController: UIViewController {
    lazy var networkManager = NetworkManager(delegate: self)
    
    private let model = GCModel.shared
    private let gcoreTitle = GCHeaderLabel()
    private let missingVideoLabel = UILabel()
    private let cellID = "broadcast"
    private let refreshControl = UIRefreshControl()
    private let collectionVideo = UICollectionView(frame: .zero,
                                                   collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(gcoreTitle)
        setupCollectionView()
        setupRefreshControl()
        setupMissingVideoLabel()
        createConstraints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        networkManager.token = model.accessToken
        collectionVideo.reloadData()
        (model.broadcasts.count == 0) ? (missingVideoLabel.isHidden = false) : (missingVideoLabel.isHidden = true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didUpdateData() {
        collectionVideo.reloadData()
        collectionVideo.refreshControl?.endRefreshing()
        (model.broadcasts.count == 0) ? (missingVideoLabel.isHidden = false) : (missingVideoLabel.isHidden = true)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionVideo)
        collectionVideo.backgroundColor  = .white
        collectionVideo.delegate = self
        collectionVideo.dataSource = self
        collectionVideo.register(GCBroadcastViewingCell.self, forCellWithReuseIdentifier: cellID)
        collectionVideo.showsVerticalScrollIndicator = false
        collectionVideo.showsHorizontalScrollIndicator = false
        collectionVideo.backgroundColor = .clear
        setupCollectionFlowLayout(flow: collectionVideo.collectionViewLayout)
    }
    
    private func setupCollectionFlowLayout(flow: UICollectionViewLayout) {
        guard let layout = flow as? UICollectionViewFlowLayout
        else { return }
        
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .vertical
        
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: width - 100, height: width - 100)
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("getting data from the server", comment: ""),
                                                            attributes: [ .foregroundColor : UIColor.darkGray ])
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(updateDataServer), for: .valueChanged)
        collectionVideo.refreshControl = refreshControl
    }
    
    private func setupMissingVideoLabel() {
        collectionVideo.addSubview(missingVideoLabel)
        missingVideoLabel.text = NSLocalizedString("The broadcasts is missing or authorization failed", comment: "")
        missingVideoLabel.numberOfLines = 0
        missingVideoLabel.textColor = .darkGray.withAlphaComponent(0.8)
        missingVideoLabel.font = UIFont.systemFont(ofSize: 14)
        missingVideoLabel.textAlignment = .center
    }
    
    @objc private func updateDataServer() {
        missingVideoLabel.isHidden = true
        
        guard model.accessToken != ""
        else {
            pushErrorAllert(with: .absentAutorization)
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            networkManager.downloadAllBroadcasts()
        }
    }
    
    private func createConstraints() {
        gcoreTitle.translatesAutoresizingMaskIntoConstraints = false
        missingVideoLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionVideo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gcoreTitle.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20),
            gcoreTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            gcoreTitle.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -20),
            gcoreTitle.heightAnchor.constraint(equalToConstant: 40),
            
            collectionVideo.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            collectionVideo.topAnchor.constraint(equalTo: gcoreTitle.bottomAnchor, constant: 5),
            collectionVideo.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            collectionVideo.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            missingVideoLabel.topAnchor.constraint(equalTo: collectionVideo.topAnchor, constant: 20),
            missingVideoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            missingVideoLabel.widthAnchor.constraint(equalToConstant: missingVideoLabel.intrinsicContentSize.width),
            missingVideoLabel.heightAnchor.constraint(equalToConstant: missingVideoLabel.intrinsicContentSize.height),
        ])
    }
}


//MARK: - UICollectionView Delegate and DataSource
extension GCBroadcastListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.broadcasts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GCBroadcastViewingCell
        cell.delegate = self
        
        let broadcast = model.broadcasts[indexPath.row]
        
        if broadcast.posterURL == nil {
            cell.posterMissingLabel.isHidden = false
            cell.indicatorView.stopAnimating()
            cell.previewImageView.image = nil
        } else if broadcast.posterImageData == nil {
            model.broadcasts[indexPath.row].delegate = self
            getPosterFrom(posterURL: broadcast.posterURL, indexBroadcast: indexPath.row)
            cell.posterMissingLabel.isHidden = true
            cell.indicatorView.startAnimating()
        } else {
            cell.previewImageView.image = UIImage(data: broadcast.posterImageData ?? Data() )
            cell.posterMissingLabel.isHidden = true
            cell.indicatorView.stopAnimating()
        }
        
        if  broadcast.isUnwrappedDescription {
            cell.toggleDescriptionVisability(hiddenNow: false, withAnimation: false)
        } else {
            cell.toggleDescriptionVisability(hiddenNow: true, withAnimation: false) 
        }
        
        cell.updateDescription(broadcastName: broadcast.name, id: broadcast.id)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let broadcast = model.broadcasts[indexPath.row]
        
        guard let streamID = broadcast.streamIDs.first,
              let hls = model.getStreamHLS(streamID: streamID)
        else { return }
        
        let playerItem = AVPlayerItem(asset: AVURLAsset(url: hls))
        playerItem.preferredPeakBitRate = 800
        playerItem.preferredForwardBufferDuration = 1
        let player = AVPlayer(playerItem: playerItem)
        
        let playerVC = GCPlayerViewController(player: player)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = .init(scaleX: 0.9, y: 0.9)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = .init(scaleX: 1, y: 1)
        }
    }
}


//MARK: - GCBroadcastDelegate, GCBroadcastViewingCellDelegate
extension GCBroadcastListViewController: GCBroadcastViewingCellDelegate, GCBroadcastDelegate {
    func tappedUnwrappedDescription(_ cell: GCBroadcastViewingCell) {
        guard let index = collectionVideo.indexPath(for: cell)?.row
        else { return }
        
        if model.broadcasts[index].isUnwrappedDescription {
            model.broadcasts[index].isUnwrappedDescription = false
            cell.toggleDescriptionVisability(hiddenNow: false, withAnimation: true)
        } else {
            model.broadcasts[index].isUnwrappedDescription = true
            cell.toggleDescriptionVisability(hiddenNow: true, withAnimation: true)
        }
        
    }
    
    func posterLoaded(_ gcBroadcats: GCBroadcast) {
        let id = gcBroadcats.id
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            guard let index = model.findIndexBroadcast(id: id)
            else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            
            DispatchQueue.main.async {
                collectionVideo.reloadItems(at: [indexPath])
            }
        }
    }
}

//MARK: - Work with http
extension GCBroadcastListViewController {
    private func getPosterFrom(posterURL: URL?,  indexBroadcast: Int) {
        guard let posterURL = posterURL
        else { return }
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            let http = HTTPCommunication()
            
            http.imageFromURLRequest(posterURL) { data, error in
                if let data = data {
                    model.broadcasts[indexBroadcast].posterImageData = data
                    let indexPath = IndexPath(row: indexBroadcast, section: 0)
                    
                    guard let cell = collectionVideo.cellForItem(at: indexPath) as? GCBroadcastViewingCell
                    else { return }
                    
                    DispatchQueue.main.async {
                        cell.previewImageView.image = UIImage(data: model.broadcasts[indexBroadcast].posterImageData ?? Data())
                        cell.indicatorView.stopAnimating()
                        collectionVideo.reloadData()
                    }
                }
            }
        }
    }
    
    private func pushErrorAllert(with error: HTTPError) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController.init(title: NSLocalizedString("Error!", comment: ""),
                                               message: "",
                                               preferredStyle: .actionSheet)
            
            switch error {
            case .absentInternet: alert.message = NSLocalizedString("connection failed.", comment: "")
            case .absentAutorization: alert.message = NSLocalizedString("authorization not recognized.", comment: "")
            default: alert.message = NSLocalizedString("unexpected error.", comment: "")
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            present(alert, animated: true) { [unowned self] in
                didUpdateData()
            }
        }
    }
}

extension GCBroadcastListViewController: NetworkManagerDelegate {
    func broadcastsDidDownload(_ broadcasts: [GCBroadcast]) {
        model.broadcasts = broadcasts
        collectionVideo.reloadData()
        didUpdateData()
    }
    
    func streamsDidDownload(_ streams: [GCStream]) {
        model.streams = streams
        collectionVideo.reloadData()
    }
    
    func failedRequest(error: HTTPError) {
        pushErrorAllert(with: error)
    }
}
