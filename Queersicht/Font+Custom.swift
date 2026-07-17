//
//  Font+Custom.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 12.07.2024.
//

import SwiftUI

extension Font {
    // MARK: - Legacy Font System
    static func cardoRegular(size: CGFloat) -> Font {
        .custom("Cardo-Regular", size: size)
    }
    
    static func cardoItalic(size: CGFloat) -> Font {
        .custom("Cardo-Italic", size: size)
    }
    
    static func frauncesSemiBold(size: CGFloat) -> Font {
        .custom("Fraunces72pt-SemiBold", size: size)
    }
    
    // MARK: - Common Text Styles (Legacy)
    static var customHeadline: Font {
        .frauncesSemiBold(size: 17)
    }
    
    static var customTitle: Font {
        .frauncesSemiBold(size: 28)
    }
    
    static var customBody: Font {
        .cardoRegular(size: 17)
    }
    
    static var customBodyItalic: Font {
        .cardoItalic(size: 17)
    }
    
    // MARK: - New Typography System (For gradual migration)
    
    // Base Font Functions
    private static func cardo(size: CGFloat) -> Font {
        .custom("Cardo-Regular", size: size)
    }
    
    private static func interRegular(size: CGFloat) -> Font {
        .custom("Inter_28pt-Regular", size: size)
    }
    
    private static func interMedium(size: CGFloat) -> Font {
        .custom("Inter_28pt-Medium", size: size)
    }
    
    // Headlines
    static var h1: Font {
        .cardo(size: 32)
    }
    
    static var h2: Font {
        .cardo(size: 28)
    }
    
    static var h3: Font {
        .cardo(size: 26)
    }
    
    static var h3_small: Font {
        .cardo(size: 19)
    }
    
    static var h4: Font {
        .interMedium(size: 25)
    }
    
    // Body Text
    static var p1: Font {
        .cardo(size: 17)
    }
    
    static var p2: Font {
        .interMedium(size: 15)
    }
    
    // Details
    static var d1: Font {
        .interRegular(size: 13)
    }
    
    // Custom sizes if needed
    static func h1(size: CGFloat) -> Font { .cardo(size: size) }
    static func h2(size: CGFloat) -> Font { .cardo(size: size) }
    static func h3(size: CGFloat) -> Font { .cardo(size: size) }
    static func h4(size: CGFloat) -> Font { .interMedium(size: size) }
    static func p1(size: CGFloat) -> Font { .cardo(size: size) }
    static func p2(size: CGFloat) -> Font { .interMedium(size: size) }
    static func d1(size: CGFloat) -> Font { .interRegular(size: size) }
    
    // MARK: - Legacy Font Extensions (for backward compatibility)
    @available(*, deprecated, message: "Use p1 instead")
    static func abcGramercyFineLight(size: CGFloat) -> Font {
        .cardo(size: size)
    }
    
    @available(*, deprecated, message: "Use p1 instead")
    static func abcGramercyFineLightItalic(size: CGFloat) -> Font {
        .custom("Cardo-Italic", size: size)
    }
    
    @available(*, deprecated, message: "Use h1 instead")
    static func abcGramercyDisplayBold(size: CGFloat) -> Font {
        .h1(size: size)
    }
}
