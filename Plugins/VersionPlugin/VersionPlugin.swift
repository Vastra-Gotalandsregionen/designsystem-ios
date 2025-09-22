/*
 This is a Swift Package Manager (SPM) build tool plugin.

 What it does:
 - When you build the package, it reads the version number from the file named "VERSION"
 in the root of the package.
 - It then generates a Swift file called "Version.swift" in the plugin's working directory.
 - The generated file contains a simple `LibraryInfo` enum with a static property `version`,
 so you can easily access the library's version number in your code.

 Why:
 - This way, you don’t need to hardcode the version in multiple places.
 - The version is managed in one central file (VERSION), making it easy to update.

 Example:
 If VERSION file contains "1.2.3", then Version.swift will look like:

 public enum LibraryInfo {
 public static let version = "1.2.3"
 }
 */
import PackagePlugin
import Foundation

/// Marks this plugin as the entry point so SPM knows where to start.
@main
/// The main plugin implementation. It conforms to BuildToolPlugin.
struct VersionPlugin: BuildToolPlugin {

    /// This function tells SPM what commands to run during the build.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let versionFile = context.package.directoryURL.appending(path: "VERSION")
        let outputFile = context.pluginWorkDirectoryURL.appending(
            path: "Version.swift"
        )

        return [
            // This command uses bash to read the VERSION file and generate Version.swift.
            .buildCommand(
                displayName: "Generate Version.swift",
                executable: try context.tool(named: "bash").url,
                arguments: [
                    "-c",
                    "echo 'public enum LibraryInfo { public static let version = \"$(cat \(versionFile.path()))\" }' > \(outputFile.path())"
                ],
                outputFiles: [outputFile]
            )
        ]
    }
}
