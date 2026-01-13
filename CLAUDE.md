# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build (Debug)
xcodebuild -scheme GobiPHP -configuration Debug build

# Build (Release)
xcodebuild -scheme GobiPHP -configuration Release build

# Open in Xcode
open GobiPHP.xcodeproj
```

## Architecture

GobiPHP is a native macOS SwiftUI application for executing PHP code with syntax highlighting.

### Core Components

- **GobiPHPApp.swift**: App entry point (`@main`), configures the main window
- **ContentView.swift**: Main UI with split view (code editor + result panel), contains `PHPCodeEditor` (NSViewRepresentable wrapping NSTextView) and `PHPTextView` (custom NSTextView subclass with regex-based PHP syntax highlighting)
- **PHPExecutor.swift**: ObservableObject that detects PHP installation by checking common paths (`/opt/homebrew/bin/php`, `/usr/local/bin/php`, etc.) and executes code via `Process`

### Key Patterns

- PHP detection scans hardcoded paths in `commonPHPPaths` array (macOS apps don't inherit shell PATH)
- Code execution uses `php -r <code>` via Swift's `Process` class
- Syntax highlighting applies regex patterns for keywords, variables (`$var`), strings, comments, numbers
- App sandbox is disabled (`GobiPHP.entitlements`) to allow process execution

## Requirements

- macOS 13.0+
- Xcode 15+
- PHP installed on system (Homebrew, MAMP, or XAMPP)
