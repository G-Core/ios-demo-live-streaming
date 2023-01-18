import UIKit

struct ScreenSize {
    static let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    static let height = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
}
