import SwiftUI

public extension Font {

    // MARK: - Body
    static var bodyRegular: Font { .body.weight(.regular) }
    static var bodyMedium: Font { .body.weight(.medium) }
    static var bodyBold: Font { .body.weight(.bold) }
    static var bodySemibold: Font { .body.weight(.semibold) }

    // MARK: - Footnote
    static var footnoteRegular: Font { .footnote.weight(.regular) }
    static var footnoteSemibold: Font { .footnote.weight(.semibold) }
    static var footnoteBold: Font { .footnote.weight(.bold) }

    // MARK: - Headline
    static var headlineSemibold: Font { .headline.weight(.semibold) }

}
