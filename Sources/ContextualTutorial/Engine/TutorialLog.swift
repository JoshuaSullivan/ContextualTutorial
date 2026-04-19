import OSLog

/// Loggers used by the contextual-tutorial engine. Kept in a single namespace
/// so signposts and diagnostics appear under a consistent subsystem in
/// Console.app and Instruments.
enum TutorialLog {
    static let engine = Logger(subsystem: "com.contextualtutorial", category: "engine")
}
