import Foundation

/// TrackerScreen enum is a convenience enum used for type-safe annotation of views that should be tracked
public enum TrackerScreen {
    
    case appStart
    case onboarding
    case home
    case latestNotesLink
    case calendar
    case calendarWeek
    case calendarFilter
    case overview
    case learnMore
    case learnMoreArticle(articleID: String)
    case tips
    case tipsArticle(articleID: String)
    case articles
    case article(articleID: String)
    case accordion(articleID: String, title: String)
    case link(articleID: String, url: String)
    case videoStart(videoID: String)
    case videoFinish(videoID: String)
    case settings
    case analytics
    case feedback
    case migration(state: TrackerMigrationState)
    case privacyPolicy
    case userAgreement
    case accessibilityStatement
    case report(action: TrackerAction)
    case whatsNew(version: String)
    case developerMenu
    case databaseSeeder
    case headache(action: TrackerAction)
    case attackEvent(action: TrackerAction)
    case attackType(action: TrackerAction)
    case activity(action: TrackerAction)
    case hormone(action: TrackerAction)
    case medication(action: TrackerAction)
    case medicationType(action: TrackerAction)
    case medicationSchema(action: TrackerAction)
    case medicationSchemaSlot(action: TrackerAction)
    case assessment(action: TrackerAction)
    case survey
    case surveyCompleted
    case surveyCancelled
    case surveyDismissed
    case directions
    case addAssessmentPlus
    case addAssessmentCallout
    case analysis
    case analysisDiscover
    case analysisBodyArea
    case analysisChartDetails
    
    public var toString: String {
        switch self {
        case .appStart:
            return "app_start"
        case .onboarding:
            return "onboarding"
        case .home:
            return "home"
        case .latestNotesLink:
            return "latest_notes_link"
        case .calendar:
            return "calendar"
        case .calendarWeek:
            return "calendar_week"
        case .calendarFilter:
            return "calendar_filter"
        case .overview:
            return "overview"
        case .settings:
            return "settings"
        case .analytics:
            return "analytics"
        case .migration(state: let state):
            return "migration_\(state.rawValue)"
        case .feedback:
            return "feedback"
        case .privacyPolicy:
            return "privacy_policy"
        case .userAgreement:
            return "user_agreement"
        case .accessibilityStatement:
            return "accessibility_statement"
        case .report(action: let action):
            return "\(action.rawValue)_report"
        case .whatsNew(version: let version):
            return "whats_new_\(version.replacingOccurrences(of: ".", with: "_"))"
            
        case .developerMenu:
            return "developer_menu"
        case .databaseSeeder:
            return "database_seeder"
            
        case .headache(action: let action):
            return "\(action.rawValue)_headache"
        case .attackEvent(action: let action):
            return "\(action.rawValue)_attack_event"
        case .attackType(action: let action):
            return "\(action.rawValue)_attack_type"
        case .activity(action: let action):
            return "\(action.rawValue)_activity"
        case .hormone(action: let action):
            return "\(action.rawValue)_hormone"
        case .medication(action: let action):
            return "\(action.rawValue)_medication"
        case .medicationType(action: let action):
            return "\(action.rawValue)_medication_type"
        case .medicationSchema(action: let action):
            return "\(action.rawValue)_medication_schema"
        case .medicationSchemaSlot(action: let action):
            return "\(action.rawValue)_medication_schema_slot"
        case .assessment(action: let action):
            return "\(action.rawValue)_assessment"
            
        case .learnMore:
            return "learn_more"
        case .learnMoreArticle(articleID: let articleID):
            return "learn_more_article_\(articleID)"
        case .tips:
            return "tips"
        case .tipsArticle(articleID: let articleID):
            return "tips_article_\(articleID)"
        case .articles:
            return "articles"
        case .article(articleID: let articleID):
            return "article_\(articleID)"
        case .accordion(articleID: let articleID, title: let title):
            return "article_accordion_\(articleID)_\(title)"
        case .link(articleID: let articleID, url: let url):
            return "article_link_\(articleID)_\(url)"
        case .videoStart(videoID: let videoID):
            return "video_\(videoID)_started"
        case .videoFinish(videoID: let videoID):
            return "video_\(videoID)_finished"
        case .survey:
            return "survey"
        case .surveyCompleted:
            return "survey_completed"
        case .surveyCancelled:
            return "survey_cancelled"
        case .surveyDismissed:
            return "survey_dismissed"
        case .directions:
            return "directions"
        case .addAssessmentPlus:
            return "add_assessment_plus"
        case .addAssessmentCallout:
            return "add_assessment_callout"
        case .analysis:
            return "analysis"
        case .analysisDiscover:
            return "analysis_discover"
        case .analysisBodyArea:
            return "analysis_body_area"
        case .analysisChartDetails:
            return "analysis_chart_details"
        }
    }
}

/// TrackerMigrationState is used to keep track of migration state
public enum TrackerMigrationState: String {
    case started
    case failed
    case completed
}

/// TrackerAction is used to keep track of actions
public enum TrackerAction: String {
    case edit
    case view
    case create
    case delete
    case list
    case receipt
    case select
}
