import Foundation

/// TrackerScreen enum is a convenience enum used for type-safe annotation of views that should be tracked
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
    case medicationSchema(action: TrackerAction)
    case medicationSchemaSlot(action: TrackerAction)
    case medicationType(action: TrackerAction)
    case migration(state: TrackerMigrationState)
    case onboarding
    case overview
    case privacyPolicy
    case report(action: TrackerAction)
    case selfassessment(action: TrackerAction)
    case settings
    case survey
    case surveyCancelled
    case surveyCompleted
    case surveyDismissed
    case tips
    case tipsArticle(articleID: String)
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
        case .medicationSchema(action: let action):
            return "\(action.rawValue)_medication_schema"
        case .medicationSchemaSlot(action: let action):
            return "\(action.rawValue)_medication_schema_slot"
        case .medicationType(action: let action):
            return "\(action.rawValue)_medication_type"
        case .migration(state: let state):
            return "migration_\(state.rawValue)"
        case .onboarding:
            return "onboarding"
        case .overview:
            return "overview"
        case .privacyPolicy:
            return "privacy_policy"
        case .report(action: let action):
            return "\(action.rawValue)_report"
        case .selfassessment(action: let action):
            return "\(action.rawValue)_selfassessment"
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
public enum TrackerMigrationState: String {
    case completed
    case failed
    case started
}

/// TrackerAction is used to keep track of actions
public enum TrackerAction: String {
    case cancel
    case create
    case delete
    case edit
    case end
    case list
    case receipt
    case select
    case skipoverinfluencingfactors
    case skipovermorning
    case skipoversymptoms
    case start
    case view
}
