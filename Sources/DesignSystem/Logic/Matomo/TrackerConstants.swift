import Foundation

/// `TrackableScreen` is a protocol that represents a screen or view that can be tracked.
/// Each conforming type must provide a unique `identifier` string used for analytics or logging.
///
/// Example:
/// ```swift
/// enum MyApp: TrackableScreen {
///     case home
///     case settings
///     case profile(action: TrackerAction)   // Using built-in TrackerAction
///     case custom(action: CustomAction)     // Using a custom action enum
///
///     var identifier: String {
///         switch self {
///         case .home: return "home"
///         case .settings: return "settings"
///         case .profile(let action): return "profile_\(action.rawValue)"
///         case .custom(let action): return "custom_\(action.rawValue)"
///         }
///     }
/// }
///
/// enum CustomAction: String {
///     case like, share, comment
/// }
///
/// // Usage:
/// tracker.trackScreen(MyApp.profile(action: .select))
/// tracker.trackScreen(MyApp.custom(action: .like))
/// ```
public protocol TrackableScreen {
    var identifier: String { get }
}

/// TrackerScreen enum is a convenience enum used for type-safe annotation of views that should be tracked
@available(*, deprecated, message: "Define TrackerScreen constants in your app instead, utilize the TrackableScreen protocol.")
public enum TrackerScreen {
    case accessibilityStatement
    case accordion(articleID: String, title: String)
    case activity(action: TrackerAction)
    case addAssessmentCallout
    case addAssessmentPlus
    case analysis
    case analysisBodyArea
    case analysisChartDetails
    case analysisDetail
    case analysisDiscover
    case analysisStart
    case analytics
    case appStart
    case article(articleID: String)
    case articles
    case assessment(action: TrackerAction)
    case attackEvent(action: TrackerAction)
    case attackType(action: TrackerAction)
    case calendar
    case calendarFilter
    case calendarWeek
    case chatAi(action: TrackerAction)
    case chatInformation(action: TrackerAction)
    case databaseSeeder
    case developerMenu
    case directions
    case faq
    case feedback
    case headache(action: TrackerAction)
    case home
    case hormone(action: TrackerAction)
    case latestNotesLink
    case learnMore
    case learnMoreArticle(articleID: String)
    case link(articleID: String, url: String)
    case medication(action: TrackerAction)
    case medicationExtra(action: TrackerAction)
    case medicationMissed(action: TrackerAction)
    case medicationSchema(action: TrackerAction)
    case medicationSchemaSlot(action: TrackerAction)
    case medicationType(action: TrackerAction)
    case migration(state: TrackerMigrationState)
    case notification
    case onboarding
    case overview
    case privacyPolicy
    case quickCheckup(action: TrackerAction)
    case report(action: TrackerAction)
    case selfassessment(action: TrackerAction)
    case selfassessmentQuick(action: TrackerAction)
    case settings
    case survey
    case surveyCancelled
    case surveyCompleted
    case surveyDismissed
    case tips
    case tipsArticle(articleID: String)
    case treatmentEffect(action: TrackerAction)
    case userAgreement
    case videoFinish(videoID: String)
    case videoStart(videoID: String)
    case whatsNew(version: String)


    public var toString: String {
        switch self {
            case .accessibilityStatement:
                return "accessibility_statement"
            case .accordion(articleID: let articleID, title: let title):
                return "article_accordion_\(articleID)_\(title)"
            case .activity(action: let action):
                return "\(action.rawValue)_activity"
            case .addAssessmentCallout:
                return "add_assessment_callout"
            case .addAssessmentPlus:
                return "add_assessment_plus"
            case .analysis:
                return "analysis"
            case .analysisBodyArea:
                return "analysis_body_area"
            case .analysisChartDetails:
                return "analysis_chart_details"
            case .analysisDetail:
                return "analysis_detail"
            case .analysisDiscover:
                return "analysis_discover"
            case .analysisStart:
                return "analysis_start"
            case .analytics:
                return "analytics"
            case .appStart:
                return "app_start"
            case .article(articleID: let articleID):
                return "article_\(articleID)"
            case .articles:
                return "articles"
            case .assessment(action: let action):
                return "\(action.rawValue)_assessment"
            case .attackEvent(action: let action):
                return "\(action.rawValue)_attack_event"
            case .attackType(action: let action):
                return "\(action.rawValue)_attack_type"
            case .calendar:
                return "calendar"
            case .calendarFilter:
                return "calendar_filter"
            case .calendarWeek:
                return "calendar_week"
            case .chatAi(action: let action):
                return "\(action.rawValue)_chat_ai"
            case .chatInformation(action: let action):
                return "\(action.rawValue)_chat_information"
            case .databaseSeeder:
                return "database_seeder"
            case .developerMenu:
                return "developer_menu"
            case .directions:
                return "directions"
            case .faq:
                return "faq"
            case .feedback:
                return "feedback"
            case .headache(action: let action):
                return "\(action.rawValue)_headache"
            case .home:
                return "home"
            case .hormone(action: let action):
                return "\(action.rawValue)_hormone"
            case .latestNotesLink:
                return "latest_notes_link"
            case .learnMore:
                return "learn_more"
            case .learnMoreArticle(articleID: let articleID):
                return "learn_more_article_\(articleID)"
            case .link(articleID: let articleID, url: let url):
                return "article_link_\(articleID)_\(url)"
            case .medication(action: let action):
                return "\(action.rawValue)_medication"
            case .medicationExtra(action: let action):
                return "\(action.rawValue)_medication_extra"
            case .medicationMissed(action: let action):
                return "\(action.rawValue)_medication_missed"
            case .medicationSchema(action: let action):
                return "\(action.rawValue)_medication_schema"
            case .medicationSchemaSlot(action: let action):
                return "\(action.rawValue)_medication_schema_slot"
            case .medicationType(action: let action):
                return "\(action.rawValue)_medication_type"
            case .migration(state: let state):
                return "migration_\(state.rawValue)"
            case .notification:
                return "notification"
            case .onboarding:
                return "onboarding"
            case .overview:
                return "overview"
            case .privacyPolicy:
                return "privacy_policy"
            case .quickCheckup(action: let action):
                return "\(action.rawValue)_quick_checkup"
            case .report(action: let action):
                return "\(action.rawValue)_report"
            case .selfassessment(action: let action):
                return "\(action.rawValue)_selfassessment"
            case .selfassessmentQuick(action: let action):
                return "\(action.rawValue)_selfassessment_quick"
            case .settings:
                return "settings"
            case .survey:
                return "survey"
            case .surveyCancelled:
                return "survey_cancelled"
            case .surveyCompleted:
                return "survey_completed"
            case .surveyDismissed:
                return "survey_dismissed"
            case .tips:
                return "tips"
            case .tipsArticle(articleID: let articleID):
                return "tips_article_\(articleID)"
            case .treatmentEffect(action: let action):
                return "\(action.rawValue)_treatment_effect"
            case .userAgreement:
                return "user_agreement"
            case .videoFinish(videoID: let videoID):
                return "video_\(videoID)_finished"
            case .videoStart(videoID: let videoID):
                return "video_\(videoID)_started"
            case .whatsNew(version: let version):
                return "whats_new_\(version.replacingOccurrences(of: ".", with: "_"))"
        }
    }
}

/// TrackerMigrationState is used to keep track of migration state
@available(*, deprecated, message: "Do not use this anymore. It is just here to not break existing code")
public enum TrackerMigrationState: String {
    case completed
    case failed
    case started
}

/// `TrackerAction` represents common user actions that can be tracked.
///
/// This enum is intentionally **generic** so it can be reused across different apps and contexts.
/// If your app requires more specific actions, you should define a separate enum in your app
/// (and optionally combine it with `TrackableScreen`).
///
/// Examples of usage:
/// ```swift
/// tracker.trackScreen(MyApp.profile(action: .select))
/// tracker.trackScreen(MyApp.settings(action: .update))
/// ```
///
/// - Important: Keep this list generic. Define app-specific actions in your app, not here.
public enum TrackerAction: String {
    case select
    case cancel
    case create
    case delete
    case update
    case edit
    case start
    case end
    case list
    case receipt
    case view

    @available(*, deprecated, message: "Do not use this anymore. It is just here to not break existing code")
    case skipoverinfluencingfactors

    @available(*, deprecated, message: "Do not use this anymore. It is just here to not break existing code")
    case skipovermorning

    @available(*, deprecated, message: "Do not use this anymore. It is just here to not break existing code")
    case skipoversymptoms
}
