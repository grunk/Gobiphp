# GobiPHP

<p align="center">
  <img src="GobiPHP/Assets.xcassets/AppIcon.appiconset/icon_256.png" alt="GobiPHP Icon" width="128">
</p>

Native macOS application to execute PHP code with syntax highlighting.


## What it is and what it will never be

- GobiPHP is a stupid simple UI over `php -r` command nothing more.
- It is not and never will be a php interpreter on it's own
- It does not handle PHP installation or PHP version for you
- It is not a good Swift project, in fact i don't know nothing about swift, but claude does 😆

## Requirements

- **macOS 13.0** or higher
- **Xcode 15** or higher (to compile)
- **PHP** installed on the system

### Installing PHP (if needed)

Via Homebrew:
```bash
brew install php
```

## Build and Run

1. Open the project in Xcode:
   ```bash
   open GobiPHP.xcodeproj
   ```

2. Build and run with **Cmd+R**

## Project Structure

```
GobiPHP/
├── GobiPHPApp.swift       # Application entry point
├── ContentView.swift      # User interface (editor + result)
├── PHPExecutor.swift      # PHP execution logic
├── GobiPHP.entitlements   # Application permissions
└── Assets.xcassets/       # Resources (icons, colors)
```

## Usage

1. Enter PHP code in the editor (without `<?php ?>` tags)
2. Click "Execute" or press **Cmd+Enter**
3. The result appears in the lower panel

### Example

```php
echo "Hello, World!";
```

## License

MIT

---

⚠️ 100% vibe coded by Claude code. This project let me experiments with vibe coding and agentic stuff.

---