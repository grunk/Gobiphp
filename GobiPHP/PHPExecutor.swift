import Foundation

struct PHPExecutionResult {
    let output: String
    let isError: Bool
    let exitCode: Int32
}

@MainActor
class PHPExecutor: ObservableObject {
    @Published var isPHPAvailable: Bool = false
    @Published var phpVersion: String = ""
    @Published var phpPath: String = ""

    // Common PHP installation paths on macOS
    private let commonPHPPaths = [
        "/opt/homebrew/bin/php",                    // Homebrew Apple Silicon
        "/opt/homebrew/opt/php/bin/php",            // Homebrew PHP (latest)
        "/opt/homebrew/opt/php@8.4/bin/php",        // Homebrew PHP 8.4
        "/opt/homebrew/opt/php@8.3/bin/php",        // Homebrew PHP 8.3
        "/opt/homebrew/opt/php@8.2/bin/php",        // Homebrew PHP 8.2
        "/opt/homebrew/opt/php@8.1/bin/php",        // Homebrew PHP 8.1
        "/usr/local/bin/php",                       // Homebrew Intel
        "/usr/local/opt/php/bin/php",               // Homebrew Intel PHP
        "/usr/bin/php",                             // System PHP (older macOS)
        "/Applications/MAMP/bin/php/php8.2.0/bin/php",  // MAMP
        "/Applications/XAMPP/bin/php",              // XAMPP
    ]

    init() {
        checkPHPAvailability()
    }

    func checkPHPAvailability() {
        Task {
            // Try to find PHP in common locations
            for path in commonPHPPaths {
                if FileManager.default.fileExists(atPath: path) {
                    let versionResult = await runCommand(executable: path, arguments: ["--version"])
                    if versionResult.exitCode == 0 {
                        if let firstLine = versionResult.output.components(separatedBy: "\n").first {
                            self.phpVersion = firstLine
                        }
                        self.phpPath = path
                        self.isPHPAvailable = true
                        return
                    }
                }
            }
            self.isPHPAvailable = false
        }
    }

    func execute(code: String) async -> PHPExecutionResult {
        guard isPHPAvailable else {
            return PHPExecutionResult(
                output: "Erreur: PHP n'est pas installé sur ce système.",
                isError: true,
                exitCode: -1
            )
        }

        let result = await runCommand(executable: phpPath, arguments: ["-r", code])
        return PHPExecutionResult(
            output: result.output,
            isError: result.exitCode != 0,
            exitCode: result.exitCode
        )
    }

    private func runCommand(executable: String, arguments: [String]) async -> PHPExecutionResult {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()
                    process.waitUntilExit()

                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                    let output = String(data: outputData, encoding: .utf8) ?? ""
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                    let combinedOutput = errorOutput.isEmpty ? output : (output + errorOutput)

                    continuation.resume(returning: PHPExecutionResult(
                        output: combinedOutput,
                        isError: process.terminationStatus != 0,
                        exitCode: process.terminationStatus
                    ))
                } catch {
                    continuation.resume(returning: PHPExecutionResult(
                        output: "Erreur d'exécution: \(error.localizedDescription)",
                        isError: true,
                        exitCode: -1
                    ))
                }
            }
        }
    }
}
