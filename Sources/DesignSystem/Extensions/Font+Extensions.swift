import SwiftUI

public extension Font {

    // MARK: - Body
    static var bodyRegular: Font { .body.weight(.regular) }
    static var bodyMedium: Font { .body.weight(.medium) }
    static var bodyBold: Font { .body.weight(.bold) }
    static var bodySemibold: Font { .body.weight(.semibold) }
    static var bodyLight: Font { .body.weight(.light) }

    // MARK: - Footnote
    static var footnoteRegular: Font { .footnote.weight(.regular) }
    static var footnoteSemibold: Font { .footnote.weight(.semibold) }
    static var footnoteBold: Font { .footnote.weight(.bold) }
    static var footnoteMedium: Font { .footnote.weight(.medium) }

    // MARK: - Headline
    static var headlineSemibold: Font { .headline.weight(.semibold) }
    static var headlineBold: Font { .headline.weight(.bold) }
    
    // MARK: - Title
    static var titleSemibold: Font { .title.weight(.semibold) }
    static var titleBold: Font { .title.weight(.bold) }
    
    // MARK: - Title 2
    static var title2Semibold: Font { .title2.weight(.semibold) }
    static var title2Bold: Font { .title2.weight(.bold) }
    
    // MARK: - Title 3
    static var title3Semibold: Font { .title3.weight(.semibold) }
    static var title3Bold: Font { .title3.weight(.bold) }
    
    // MARK: - Subheadline
    static var subheadlineSemibold: Font { .subheadline.weight(.semibold) }
    static var subheadlineBold: Font { .subheadline.weight(.bold) }
    
    // MARK: - Caption
    static var captionSemibold: Font { .caption.weight(.semibold) }
    static var captionBold: Font { .caption.weight(.bold) }

}
