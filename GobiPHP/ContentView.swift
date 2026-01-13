import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var phpExecutor = PHPExecutor()
    @State private var sourceCode: String = "echo \"Hello, World!\";"
    @State private var result: String = ""
    @State private var isExecuting: Bool = false
    @State private var resultIsError: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if !phpExecutor.isPHPAvailable {
                PHPNotFoundView()
            } else {
                VStack(spacing: 0) {
                    // Header with PHP version
                    HStack {
                        Image(systemName: "terminal")
                            .foregroundColor(.secondary)
                        Text(phpExecutor.phpVersion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.windowBackgroundColor))

                    Divider()

                    // Code editor
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PHP Code")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        PHPCodeEditor(text: $sourceCode)
                            .frame(minHeight: 150)
                    }
                    .background(Color(NSColor.textBackgroundColor))

                    // Toolbar with execute button
                    HStack {
                        Spacer()
                        Button(action: executeCode) {
                            HStack(spacing: 6) {
                                if isExecuting {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 16, height: 16)
                                } else {
                                    Image(systemName: "play.fill")
                                }
                                Text("Execute")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExecuting || sourceCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))

                    Divider()

                    // Result panel
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Result")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        ScrollView {
                            Text(result.isEmpty ? "Result will display here..." : result)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(result.isEmpty ? .secondary : (resultIsError ? .red : .primary))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .textSelection(.enabled)
                        }
                        .frame(minHeight: 100)
                        .background(Color(NSColor.textBackgroundColor))
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private func executeCode() {
        isExecuting = true
        result = ""
        resultIsError = false

        Task {
            let executionResult = await phpExecutor.execute(code: sourceCode)
            result = executionResult.output
            resultIsError = executionResult.isError
            isExecuting = false
        }
    }
}

struct PHPNotFoundView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("PHP is not installed")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                Text("To use GobiPHP, you need PHP installed on your system.")
                    .foregroundColor(.secondary)

                Divider()

                Text("Install with Homebrew:")
                    .fontWeight(.medium)

                HStack {
                    Text("brew install php")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)

                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("brew install php", forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.borderless)
                    .help("Copy command")
                }

                Text("Or download from:")
                    .fontWeight(.medium)
                    .padding(.top, 8)

                Link("https://www.php.net/downloads", destination: URL(string: "https://www.php.net/downloads")!)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Custom PHP Code Editor with Syntax Highlighting
struct PHPCodeEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let textView = PHPTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textColor = NSColor.textColor
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false

        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = context.coordinator

        scrollView.documentView = textView
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? PHPTextView else { return }

        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.applySyntaxHighlighting()
            textView.selectedRanges = selectedRanges
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PHPCodeEditor

        init(_ parent: PHPCodeEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? PHPTextView else { return }
            parent.text = textView.string
            textView.applySyntaxHighlighting()
        }
    }
}

class PHPTextView: NSTextView {
    private let keywords = [
        "abstract", "and", "array", "as", "break", "callable", "case", "catch",
        "class", "clone", "const", "continue", "declare", "default", "do", "echo",
        "else", "elseif", "empty", "enddeclare", "endfor", "endforeach", "endif",
        "endswitch", "endwhile", "eval", "exit", "extends", "final", "finally",
        "fn", "for", "foreach", "function", "global", "goto", "if", "implements",
        "include", "include_once", "instanceof", "insteadof", "interface", "isset",
        "list", "match", "namespace", "new", "or", "print", "private", "protected",
        "public", "readonly", "require", "require_once", "return", "static", "switch",
        "throw", "trait", "try", "unset", "use", "var", "while", "xor", "yield"
    ]

    private let constants = ["true", "false", "null", "TRUE", "FALSE", "NULL"]

    private var keywordColor: NSColor { NSColor.systemPink }
    private var stringColor: NSColor { NSColor.systemGreen }
    private var commentColor: NSColor { NSColor.systemGray }
    private var numberColor: NSColor { NSColor.systemOrange }
    private var variableColor: NSColor { NSColor.systemCyan }
    private var constantColor: NSColor { NSColor.systemPurple }

    func applySyntaxHighlighting() {
        guard let textStorage = self.textStorage else { return }

        let fullRange = NSRange(location: 0, length: textStorage.length)

        // Reset to default color
        textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)

        // Highlight comments (single line)
        highlightPattern("//[^\n]*", color: commentColor, in: textStorage)
        highlightPattern("#[^\n]*", color: commentColor, in: textStorage)

        // Highlight comments (multi-line)
        highlightPattern("/\\*[\\s\\S]*?\\*/", color: commentColor, in: textStorage)

        // Highlight strings (double quotes)
        highlightPattern("\"(?:[^\"\\\\]|\\\\.)*\"", color: stringColor, in: textStorage)

        // Highlight strings (single quotes)
        highlightPattern("'(?:[^'\\\\]|\\\\.)*'", color: stringColor, in: textStorage)

        // Highlight numbers
        highlightPattern("\\b[0-9]+(\\.[0-9]+)?\\b", color: numberColor, in: textStorage)

        // Highlight variables
        highlightPattern("\\$[a-zA-Z_][a-zA-Z0-9_]*", color: variableColor, in: textStorage)

        // Highlight keywords
        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", color: keywordColor, in: textStorage)
        }

        // Highlight constants
        for constant in constants {
            highlightPattern("\\b\(constant)\\b", color: constantColor, in: textStorage)
        }
    }

    private func highlightPattern(_ pattern: String, color: NSColor, in textStorage: NSTextStorage) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }

        let text = textStorage.string
        let range = NSRange(location: 0, length: text.utf16.count)

        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            if let matchRange = match?.range {
                textStorage.addAttribute(.foregroundColor, value: color, range: matchRange)
            }
        }
    }
}

#Preview {
    ContentView()
}
