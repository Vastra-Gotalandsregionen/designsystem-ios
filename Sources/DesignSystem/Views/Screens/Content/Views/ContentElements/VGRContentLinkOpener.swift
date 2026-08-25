import UIKit

public extension Notification.Name {
    /// Posted when the OS fails to open a content link. The failing `URL` is passed as `object`.
    static let contentLinkOpenFailed = Notification.Name("contentLinkOpenFailed")

    /// Posted when the OS has no way of opening a content link. The failing `URL` is passed as `object`.
    static let contentLinkNotSupported = Notification.Name("contentLinkNotSupported")
}

/// Opens content links via `UIApplication`, posting `contentLinkNotSupported` and
/// `contentLinkOpenFailed` notifications so consuming apps can track failed opens.
enum VGRContentLinkOpener {

    @MainActor
    static func open(_ url: URL) {
        if !UIApplication.shared.canOpenURL(url) {
#if targetEnvironment(simulator)
            print("🌐 canOpenURL failed with url \"\(url.absoluteString)\"")
#endif
            NotificationCenter.default.post(name: .contentLinkNotSupported, object: url)
            return
        }

        UIApplication.shared.open(url) { success in
            if !success {
#if targetEnvironment(simulator)
                print("🌐 open failed with url \"\(url.absoluteString)\"")
#endif
                NotificationCenter.default.post(name: .contentLinkOpenFailed, object: url)
            }
        }
    }
}
