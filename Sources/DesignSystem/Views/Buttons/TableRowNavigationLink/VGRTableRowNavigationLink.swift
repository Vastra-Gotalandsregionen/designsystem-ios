import SwiftUI

/// En anpassad radkomponent som fungerar som en `NavigationLink`, utformad för att efterlikna en enkel "settings cell".
///
/// **OBS:** Bäddas inte in i en `List` eller `Form` eftersom dessa kan lägga till oönskade bakgrunder och symboler (t.ex. grå chevron).
///
/// Denna komponent är flexibel och stödjer:
/// - Titel (obligatorisk)
/// - Undertitel (valfri, visas i mindre stil)
/// - Ikon (valfri, vänsterjusterad)
/// - Detaljtext (valfri, högerjusterad)
/// - Anpassad accessibility-label
///
/// Används ofta i inställningsvyer eller menyer.
///
/// ```swift
/// TableRowNavigationLink(destination: SettingsView(), title: "Inställningar", subtitle: "Hantera dina preferenser", iconName: "gear")
/// ```
public struct VGRTableRowNavigationLink<Destination: View>: View {
    
    // MARK: - Properties

    /// Destinationen som visas när länken trycks.
    var destination: Destination

    /// Primär titeltext (krävs).
    let title: String

    /// Undertitel (valfri).
    let subtitle: String?

    /// Separat sträng för accessibility, om `subtitle` innehåller symboler eller behöver förenklas.
    var subtitleA11y: String?

    /// Namn på ikon (bild) som visas till vänster (valfri).
    let iconName: String?

    /// Text som visas till höger om raden (valfri).
    let details: String?

    /// Horisontell padding (konstant).
    let padding: CGFloat = 16

    /// Skalbar storlek för chevron-symbolen.
    @ScaledMetric var chevronSize: CGFloat = 16

    /// Skalbar storlek för ikonen.
    @ScaledMetric var iconSize: CGFloat = 25

    // MARK: - Init

    public init(destination: Destination, title: String, subtitle: String? = nil, subtitleA11y: String? = nil, iconName: String? = nil, details: String? = nil) {
        self.destination = destination
        self.title = title
        self.subtitle = subtitle
        self.subtitleA11y = subtitleA11y
        self.iconName = iconName
        self.details = details
    }

    // MARK: - Accessibility

    /// En sammanställd label för VoiceOver.
    var a11yLabel: String {
        return "\(title), \(subtitleA11y ?? subtitle ?? ""), \(details ?? "")"
            .replacingOccurrences(of: "•", with: "")
    }

    // MARK: - Body

    public var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                HStack(spacing: 12) {
                    if let imageName = iconName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(Color.Neutral.text)
                            .accessibilityHidden(true)
                    }

                    if let subtitle, !subtitle.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)

                            Text(subtitle)
                                .font(.footnote)
                                .padding(.leading, 2)
                        }
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.Neutral.text)
                        .fontWeight(.medium)
                        .padding(.vertical, 12)
                    } else {
                        Text(title)
                            .textCase(.none)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color.Neutral.text)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.vertical, padding)
                    }
                }

                Spacer()

                if let details {
                    Text(details)
                        .foregroundStyle(Color.Neutral.text)
                }

                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: chevronSize, height: chevronSize)
                    .foregroundStyle(Color.Primary.action)
                    .fontWeight(.semibold)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, padding)
            .background(Color.Elevation.elevation1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(a11yLabel)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("SettingsListRow") {
    
    NavigationStack {
        ScrollView {
            VStack (alignment: .leading) {

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Anfallshantering", iconName: "settings_attack")

                VGRDivider()
                
                VGRTableRowNavigationLink(destination: EmptyView(), title: "Användarvillkor")

                VGRDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Ge oss Feedback")

                VGRDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Personuppgiftspolicy")

                VGRDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Tillgänglighetsredogörelse")

                VGRDivider()

                VGRTableRowNavigationLink(destination: EmptyView(), title: "Tillgänglighetsredogörelse", subtitle: "Hej", details: "Test")
            }
        }
    }
}
