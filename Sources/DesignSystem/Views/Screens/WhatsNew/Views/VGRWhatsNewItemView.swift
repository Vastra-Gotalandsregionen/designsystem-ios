import SwiftUI

/// Renders a single change page within the WhatsNew carousel.
/// Supports multiple element types: headlines, body text, images, and panel containers.
/// Migrated from migraine-ios `WhatsNewItemView`.
public struct VGRWhatsNewItemView: View {

    /// The change to render
    let change: VGRWhatsNewChange

    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(change.elements.indices, id: \.self) { index in
                    let element = change.elements[index]
                    switch element.type {
                        case .h1:
                            Text(element.text)
                                .font(.title).bold()
                                .foregroundStyle(Color.Neutral.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityAddTraits(.isHeader)
                                .padding(.bottom, 12)
                                .accessibilityRespondsToUserInteraction()

                        case .subhead:
                            Text(element.text)
                                .font(.headline).bold()
                                .lineSpacing(6)
                                .foregroundStyle(Color.Neutral.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 32)
                                .accessibilityAddTraits(.isStaticText)

                        case .image:
                            if element.hasDimensions {
                                Image(element.url)
                                    .resizable()
                                    .frame(width: element.widthValue, height: element.heightValue, alignment: .center)
                                    .accessibilityHidden(true)
                            } else {
                                Image(element.url)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .accessibilityHidden(true)
                            }

                        case .panel:
                            VStack(spacing: 32) {
                                ForEach(element.elements.indices, id: \.self) { subElementIndex in
                                    let subElement = element.elements[subElementIndex]
                                    switch subElement.type {
                                        case .image:
                                            if subElement.hasDimensions {
                                                Image(subElement.url)
                                                    .resizable()
                                                    .foregroundColor(.black)
                                                    .frame(width: subElement.widthValue, height: subElement.heightValue, alignment: .center)
                                                    .accessibilityHidden(true)
                                            } else {
                                                Image(subElement.url)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .accessibilityHidden(true)
                                            }
                                        default:
                                            Text(subElement.text)
                                                .font(.body)
                                                .lineSpacing(6)
                                                .foregroundStyle(Color.Neutral.text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .accessibilityAddTraits(.isStaticText)
                                    }
                                }
                            }
                            .padding(element.paddingValue)
                            .background(Color.Elevation.elevation1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, 16)

                        default:
                            Text(element.text)
                                .font(.body)
                                .lineSpacing(6)
                                .foregroundStyle(Color.Neutral.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 32)
                                .accessibilityAddTraits(.isStaticText)
                    }
                }

            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityTextContentType(.narrative)
            .accessibilityIdentifier("WhatsNewItem")
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }
}

#Preview("VGRWhatsNewItemView") {
    let elementsJSON = """
    [
        {
            "order": 1,
            "type": "h1",
            "text": "Saknas läkemedlet?"
        },
        {
            "order": 2,
            "type": "subhead",
            "text": "Saknas ditt läkemedel i listan över vanliga läkemedel?"
        },
        {
            "order": 3,
            "type": "body",
            "text": "Nu kan du ange namn på läkemedel som du själv lägger till. Du kan också ändra namn på läkemedel som du lagt till tidigare."
        }
    ]
    """

    let elementsData = Data(elementsJSON.utf8)
    let jsonDecoder = JSONDecoder()

    var elements: [VGRWhatsNewChangeElement] = []
    do {
        elements = try jsonDecoder.decode([VGRWhatsNewChangeElement].self, from: elementsData)
    } catch {
        print("Error: \(error.localizedDescription)")
    }

    let change = VGRWhatsNewChange(order: 1, template: "full", elements: elements)

    return ZStack(alignment: .top) {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 450)
            .foregroundStyle(Color.Primary.blueSurfaceMinimal)
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 80,
                    topTrailingRadius: 0
                )
            )
            .ignoresSafeArea()

        VGRWhatsNewItemView(change: change)
    }
}
