import UIKit

final class StreamSettingsCell: UICollectionViewCell {
    static var reuseId: String { String(describing: Self.self) }
    static var nibName: String { String(describing: Self.self) }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var secondaryTitleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        secondaryTitleLabel.text = ""
    }

    func configure(title: String, secondaryTitle: String) {
        titleLabel.text = title
        secondaryTitleLabel.text = secondaryTitle
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.8
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1
    }
}
