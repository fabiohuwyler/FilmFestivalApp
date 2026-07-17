import SwiftUI

extension Font {
    static func inter(size: CGFloat, weight: InterWeight = .regular) -> Font {
        switch weight {
        case .regular:
            return .custom("Inter_28pt-Regular", size: size)
        case .medium:
            return .custom("Inter_28pt-Medium", size: size)
        }
    }
}

enum InterWeight {
    case regular
    case medium
}
