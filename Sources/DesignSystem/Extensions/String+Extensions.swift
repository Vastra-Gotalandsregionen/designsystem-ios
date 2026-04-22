import Foundation

public extension String {

    /// Looks up the receiver as a localization key and returns the translated
    /// string from the given bundle, falling back to the key itself when no
    /// entry is found.
    ///
    /// Use this as a short-form replacement for `NSLocalizedString` at call
    /// sites where the key lives in a callers own bundle — pass that bundle
    /// explicitly, otherwise the lookup happens in `.main`.
    ///
    /// ### Usage
    /// ```swift
    /// Text("welcome.title".loc())
    /// Text("welcome.title".loc(in: .module))
    /// ```
    ///
    /// - Parameter bundle: The bundle to search for the localized string.
    ///   Defaults to `.main`.
    /// - Returns: The localized string, or the key itself if no translation exists.
    func loc(in bundle: Bundle = .main) -> String {
        NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }

    /// Looks up the receiver as a localization key and formats the result
    /// with the supplied arguments. Equivalent to ``loc(in:)`` followed by
    /// `String(format:)`, so the translated string is expected to contain
    /// `printf`-style placeholders (`%@`, `%d`, …).
    ///
    /// ### Usage
    /// ```swift
    /// // Localizable.strings: "cart.items" = "%d items in cart";
    /// let label = "cart.items".locFmt(arguments: count)
    /// ```
    ///
    /// - Parameters:
    ///   - bundle: The bundle to search for the localized string. Defaults to `.main`.
    ///   - arguments: Values substituted into the format placeholders, in order.
    /// - Returns: The formatted, localized string.
    func locFmt(in bundle: Bundle = .main, arguments: CVarArg...) -> String {
        let locStr = NSLocalizedString(self, bundle: bundle, comment: "")
        return String(format: locStr, arguments: arguments)
    }
}

public extension String {
    var localized: String {
        return NSLocalizedString(self,
                                 value: "'\(self)' has no localization",
                                 comment: "")
    }

    func localizedFormat(arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }

    func localizedBundleFormat(arguments: CVarArg...) -> String {
        let bundle = Bundle.module
        let locStr = NSLocalizedString(self, tableName: "Localizable", bundle: bundle, value: "", comment: "")
        return String(format: locStr, arguments: arguments)
    }

    var capitalizeFirstLetterRestLowercase: String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }

    var localizedBundle: String {
        /// Get the bundle for the current class (eg. Shared package)
        let bundle = Bundle.module
        return NSLocalizedString(self, tableName: "Localizable", bundle: bundle, comment: "")
    }
}

public class LocalizedHelper {
    public static func localized(forKey key: String, value: String? = nil) -> String {
        /// Get the bundle for the current class (eg. Shared package)
        let bundle = Bundle.module
        return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: value ?? "NOPE", comment: "")
    }

    public static func localizedFormat(forKey key: String, arguments: CVarArg...) -> String {
        /// Get the bundle for the current class (eg. Shared package)
        let bundle = Bundle.module
        let locStr = NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "NOPE", comment: "")
        return String(format: locStr, arguments: arguments)
    }
    
    public static func localizedAttributed(forKey key: String, bundle: Bundle) -> AttributedString {
        let localizedString = NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "NOPE", comment: "")
        
        do {
            return try AttributedString(markdown: localizedString)
        } catch {
            return AttributedString(localizedString) // fallback om markdown failar
        }
    }
    
    public static func localizedBulletList(forKey key: String, bundle: Bundle) -> [AttributedString] {
           let localizedString = NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "NOPE", comment: "")
           let lines = localizedString.components(separatedBy: "\n")
           
           return lines.compactMap { line in
               do {
                   return try AttributedString(markdown: line)
               } catch {
                   return AttributedString(line)
               }
           }
       }
}
