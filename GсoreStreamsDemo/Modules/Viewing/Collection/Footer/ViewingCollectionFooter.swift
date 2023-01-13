import UIKit

final class ViewingCollectionFooter: UICollectionReusableView {
    static let nibName = String(describing: ViewingCollectionFooter.self)
    static let reuseId = String(describing: ViewingCollectionFooter.self)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading = false
}
