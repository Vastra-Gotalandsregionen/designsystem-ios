import Foundation

public extension String {
    /// Retrieves the localized version of the string.
    /// - Returns: A localized string if available; otherwise, returns a fallback message including the key.
    var localized: String {
        return NSLocalizedString(self,
                                 value: "'\(self)' has no localization",
                                 comment: "")
    }

    /// Formats a localized string using the provided arguments.
    /// - Parameter arguments: The arguments to insert into the localized string.
    /// - Returns: A formatted localized string.
    func localizedFormat(arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }

    enum Module {
        /// Retrieves a localized string for a given key from the "Localizable" table.
        /// - Parameters:
        ///   - key: The key for the localized string.
        ///   - value: An optional default value if no localization is found.
        /// - Returns: The localized string or a fallback message.
        public static func localized(forKey key: String, value: String? = nil) -> String {
            return NSLocalizedString(
                key,
                tableName: "Localizable",
                bundle: .module,
                value: value ?? "No localization found",
                comment: ""
            )
        }

        /// Retrieves and formats a localized string using the given arguments.
        /// - Parameters:
        ///   - key: The key for the localized string.
        ///   - arguments: The arguments to format the localized string.
        /// - Returns: A formatted localized string or a fallback message.
        public static func localizedFormat(forKey key: String, arguments: CVarArg...) -> String {
            let locStr = NSLocalizedString(
                key,
                tableName: "Localizable",
                bundle: .module,
                value: "No localization found",
                comment: ""
            )
            return String(format: locStr, arguments: arguments)
        }
    }
}
