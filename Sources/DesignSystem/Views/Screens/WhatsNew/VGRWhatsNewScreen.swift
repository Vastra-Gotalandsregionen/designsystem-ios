import SwiftUI

/// A full-screen view that presents a paginated carousel of WhatsNew changes.
/// Displays navigation controls (back, skip, next/confirm) and a page indicator.
/// Migrated from migraine-ios `WhatsNewView`.
///
/// Usage:
/// ```swift
/// VGRWhatsNewScreen(version.changes) {
///     // Handle completion (dismiss, mark as seen, etc.)
/// }
/// ```
public struct VGRWhatsNewScreen: View {

    /// Called when the user finishes or skips the WhatsNew flow
    let onComplete: () -> Void?

    /// The change pages to display
    private var changes: [VGRWhatsNewChange]

    @State private var selectedTab: Int = 0
    @State private var backgroundHeight: CGFloat = 0
    @State private var size: CGSize = .zero
    @State private var originalSize: CGSize = .zero

    private var totalTabs: Int

    @State private var currentChange: VGRWhatsNewChange?

    /// - Parameters:
    ///   - changes: The array of change pages to present in the carousel
    ///   - onComplete: Closure called when the user finishes or skips
    public init(_ changes: [VGRWhatsNewChange], onComplete: @escaping () -> Void?) {

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.Primary.action)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.Neutral.textVariant)

        self.onComplete = onComplete
        self.changes = changes
        self.totalTabs = self.changes.count
        if let first = self.changes.first {
            self.currentChange = first
        }
    }

    /// Updates the background height based on view size and template type
    func setBackground(_ inSize: CGSize, _ full: Bool) {
        backgroundHeight = inSize.height * (full ? 0.69 : 0.46)
    }

    func previousTab() {
        if !isFirstTab {
            selectedTab = selectedTab - 1
        }
    }

    func nextTab() {
        if !isLastTab {
            selectedTab = selectedTab + 1
        } else {
            dismissalAction()
        }
    }

    func dismissalAction() {
        self.onComplete()
    }

    var isLastTab: Bool {
        selectedTab == totalTabs - 1
    }

    var isFirstTab: Bool {
        selectedTab == 0
    }

    var hasMultipleTabs: Bool {
        totalTabs > 1
    }

    /// The title shown in the navigation bar (page indicator or generic title)
    var currentTabTitle: String {
        if totalTabs > 1 {
            return "whatsnew.steps".localizedBundleFormat(arguments: selectedTab + 1, totalTabs)
        }

        return "whatsnew.title".localizedBundle
    }

    /// The label for the next/confirm button
    var nextButtonTitle: String {
        let key = (isLastTab ? "whatsnew.done" : "whatsnew.next")
        return key.localizedBundle
    }

    public var body: some View {
        // Background container
        ZStack(alignment: .top) {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: backgroundHeight)
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

            // View container
            VStack(spacing: 0) {

                // Navigation bar
                HStack(alignment: .center) {
                    Button {
                        previousTab()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .padding(.leading, 8)
                            Text("whatsnew.back".localizedBundle)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(isFirstTab ? 0 : 1)
                    .accessibilityIdentifier("PreviousButton")

                    Text(currentTabTitle)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .font(.headline)

                    Button {
                        dismissalAction()
                    } label: {
                        Spacer()
                        Text("whatsnew.skip".localizedBundle)
                            .padding(.trailing, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("SkipButton")
                    .opacity(self.totalTabs > 1 ? 1 : 0)
                }
                .tint(Color.Primary.action)
                .background(.clear)

                // Pages
                TabView(selection: $selectedTab) {
                    ForEach(self.changes.indices, id: \.self) { index in
                        VGRWhatsNewItemView(change: self.changes[index])
                            .toolbarBackground(.hidden)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: hasMultipleTabs ? .always : .never))
                .indexViewStyle(.page(backgroundDisplayMode: hasMultipleTabs ? .always : .never))
                .onChange(of: selectedTab) { _, _ in
                    currentChange = self.changes[selectedTab]

                    withAnimation(.easeInOut(duration: 0.3)) {
                        setBackground(size, currentChange?.template == "full")
                    }
                }
                .accessibilityIdentifier("ItemContainer")

                // Lower button area
                VStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            nextTab()
                        }
                    } label: {
                        Text(nextButtonTitle)
                            .foregroundColor(Color.Neutral.textInverted)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 16))
                    .tint(Color.Primary.action)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("NextButton")

                }
                .padding(16)
                .background(Color.Elevation.background)
            }

            // Geometry tracking for responsive background height
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        originalSize = proxy.size
                        size = originalSize
                        setBackground(size, true)
                    }
                    .onChange(of: proxy.size) { _, newSize in
                        size = newSize
                        setBackground(size, currentChange?.template == "full")
                    }
            }
        }
        .onAppear() {
            currentChange = self.changes[selectedTab]
        }
        .background(Color.Elevation.background)
    }
}

#Preview("VGRWhatsNewScreen") {
    struct PreviewWrapper: View {
        @State private var showWhatsNew = false

        var body: some View {
            Button("Visa nyheter") {
                showWhatsNew = true
            }
            .fullScreenCover(isPresented: $showWhatsNew) {
                VGRWhatsNewScreen(Self.previewChanges) {
                    showWhatsNew = false
                }
            }
        }

        static var previewChanges: [VGRWhatsNewChange] {
            let json = """
            [
            {
                "order": 1,
                "template": "full",
                "elements": [
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
            },
            {
                "order": 2,
                "template": "half",
                "elements": [
                    {
                        "order": 1,
                        "type": "h1",
                        "text": "Ange eget namn"
                    },
                    {
                        "order": 2,
                        "type": "subhead",
                        "text": "Ändra och ange namn på \\"Annat läkemedel\\"."
                    },
                    {
                        "order": 3,
                        "type": "panel",
                        "padding": [24, 24, 24, 24],
                        "elements": [
                            {
                                "order": 1,
                                "type": "body",
                                "text": "Du som tar förebyggande läkemedel kan nu schemalägga påminnelser."
                            }
                        ]
                    }
                ]
            },
            {
                "order": 3,
                "template": "half",
                "elements": [
                    {
                        "order": 1,
                        "type": "h1",
                        "text": "Nya videoklipp"
                    },
                    {
                        "order": 2,
                        "type": "subhead",
                        "text": "Nu finns nya videoklipp i avsnittet Lär mer."
                    },
                    {
                        "order": 3,
                        "type": "body",
                        "text": "Genom att titta på de nya filmerna kan du lära dig ännu mer om migrän."
                    }
                ]
            }
            ]
            """

            let data = Data(json.utf8)
            return (try? JSONDecoder().decode([VGRWhatsNewChange].self, from: data)) ?? []
        }
    }

    return PreviewWrapper()
}
