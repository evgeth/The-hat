# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS multiplayer word-guessing game "The Hat" (Шляпа). Players take turns describing words without saying them directly, similar to Tabu or Alias.

## Build & Run

**IMPORTANT**: Open `thehat.xcworkspace` (not .xcodeproj) - this is a CocoaPods project.

```bash
# Install dependencies
pod install

# Build from command line
xcodebuild -workspace thehat.xcworkspace -scheme thehat -sdk iphonesimulator build

# Run tests
xcodebuild -workspace thehat.xcworkspace -scheme thehat -sdk iphonesimulator test
```

In Xcode: Cmd+R to run, Cmd+U to test.

## Architecture

### Game Flow
```
MenuController → GameSettingsViewController → PreparationViewController
    → RoundViewController (gameplay loop) → ResultsViewController
    → EditWordsGuessedViewController → back to RoundViewController or final results
```

### Core Components

**Singleton Game State**: `GameSingleton.gameInstance` - central game state accessed globally.

**Models** (`thehat/Models/`):
- `Game` - main game logic, player management, word pool, round progression
- `Player` - player data with explained/guessed counts and score
- `Round` - round metadata (speaker, listener, guessed words)
- `Word` - word with state (new/guessed/fail) and complexity score (0-100)

**Services** (`thehat/Services/`):
- `DefaultsService` - UserDefaults persistence for game history

**Key ViewControllers**:
- `RoundViewController` - core gameplay with timer, word display, swipe gestures for word states
- `GameSettingsViewController` - game type, difficulty, duration configuration
- `PreparationViewController` - player management

### Game Types
- **EachToEach** - every player plays with every other player (round-robin)
- **Pairs** - players in fixed pairs competing against other pairs

### Localization
Dual language support (English/Russian) with runtime switching via `LanguageChanger`. Both storyboards (`en.lproj/Main.storyboard`, `ru.lproj/Main.storyboard`) must be updated for UI changes.

### Word Data Format
JSON files in `thehat/Data/` (english.words, russian.words):
```json
{"words": [{"word": "example", "complexity": 50}]}
```

### Custom Views
- `TimerView` - circular progress timer
- `ColorChangingView` - swipe-gesture view with color feedback for word states (green=guessed, red=failed, blue=new)
- `PlayerView` - player score display

### Extensions
`Extensions.swift` contains:
- `UIColor(r:g:b:a:)` - init with 0-255 RGB and 0-100 alpha scale
- `Array.shuffle()` - Fisher-Yates shuffle
- `RandomNames` - generates random player names

## Key Patterns

- MVC with storyboard-based navigation
- Protocol-based services (`WordsLoaderProtocol`, `DefaultsServiceProtocol`)
- Audio feedback via AVFoundation (sounds in `thehat/Data/`: score.wav, mistake.wav, countdown.wav)

## App Icons

Icon source files are in `.icon` format (Icon Composer). These are stored in `thehat/` directory:
- `thehat/AppIcon.icon/` - current app icon source
- `thehat/SimpleNew.icon/` - alternative icon

**Important**: `.icon` files are Icon Composer's native format with layers, effects, and dark/light mode variants. Xcode automatically generates the required `AppIcon.appiconset` from these during build. Do NOT manually create `.appiconset` folders - let Xcode/Icon Composer handle it.

## Dependencies (CocoaPods)
- SwiftyJSON ~> 4.0
- Firebase/Analytics
- Crashlytics (Fabric framework)
