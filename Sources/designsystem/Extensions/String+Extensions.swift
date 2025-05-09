import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self,
                                 value: "'\(self)' has no localization",
                                 comment: "")
    }

    func localizedFormat(arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
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
