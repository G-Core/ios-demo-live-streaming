import UIKit

final class StreamSettingsSelectorCell: UITableViewCell {
    static var reuseId: String { String(describing: Self.self) }
    static var nibName: String { String(describing: Self.self) }

    private let strokeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 200/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()

    func firstCellSetup() {
        roundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8)
        addStrokeView()
    }

    func commonSetup() {
        addStrokeView()

        let corners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        roundCorners(corners: corners, radius: 0)
    }

    func lastCellSetup() {
        strokeView.removeFromSuperview()
        roundCorners(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 8)
    }

    @inline(__always)
    private func addStrokeView() {
        addSubview(strokeView)
        NSLayoutConstraint.activate([
            strokeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            strokeView.rightAnchor.constraint(equalTo: rightAnchor),
            strokeView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        ])
    }
}
