import UIKit
import Kingfisher

final class StreamViewingCell: UICollectionViewCell {
    static let nibName = String(describing: StreamViewingCell.self)
    static let reuseId = String(describing: StreamViewingCell.self)

    @IBOutlet private weak var liveStatusColorView: UIView!
    @IBOutlet private weak var liveLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var chevronRightImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
        liveStatusColorView.layer.cornerRadius = liveStatusColorView.bounds.height / 2
    }
    
    func setup(with model: StreamViewingCellModel) {
        nameLabel.text = "Name: " + model.name
        idLabel.text = "ID: " + model.id        
        imageView.kf.setImage(with: model.image, placeholder: UIImage.streamPreviewImage)
        
        if !model.isActive {
            liveLabel.text = "Disabled"
            liveLabel.textColor = .grey500
            liveStatusColorView.backgroundColor = .grey500
            chevronRightImage.isHidden = true
        } else if !model.isLive {
            liveLabel.text = "Offline"
            liveLabel.textColor = .grey800
            liveStatusColorView.backgroundColor = .grey800
            chevronRightImage.isHidden = true
        } else {
            liveLabel.text = "Live"
            liveLabel.textColor = .green
            liveStatusColorView.backgroundColor = .green
            chevronRightImage.isHidden = false
        }
    }
}
