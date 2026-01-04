# AI Custom Word Pack Feature - Implementation Plan

## Overview

Add a new "Custom AI Pack" option to the Game Settings screen that allows users to generate themed word packs using ChatGPT 5.2 API.

---

## Architecture Decisions

### API Integration Pattern
- Create a new `OpenAIService` singleton for API communication
- Use native `URLSession` (no external dependencies needed)
- Store API key in a secure configuration file (not in source control)

### Word Loading Integration
- Create `AIWordsLoader` implementing `WordsLoaderProtocol`
- This keeps the existing game flow intact - words from AI are treated just like local words
- The Game model doesn't need to know where words came from

### UI Flow
```
GameSettingsVC → [Select "Custom AI Pack"] → AIWordPackViewController (modal)
    → User enters theme + word count → Submit → Loading state
    → API Response → Preview words → Confirm → Back to GameSettingsVC (AI pack selected)
    → Normal game flow continues
```

---

## Implementation Steps

### Phase 1: Core Infrastructure

#### 1.1 Create OpenAI API Service
**File**: `thehat/Services/OpenAIService.swift`

```swift
protocol OpenAIServiceProtocol {
    func generateWords(
        theme: String,
        difficulty: Int,
        count: Int,
        completion: @escaping (Result<[Word], OpenAIError>) -> Void
    )
}

final class OpenAIService: OpenAIServiceProtocol {
    static let shared = OpenAIService()

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-5.2"

    // API key loaded from Config.plist (not in git)
    private var apiKey: String? { ... }

    func generateWords(...) {
        // 1. Build prompt with theme, difficulty mapping, count
        // 2. POST to ChatGPT API
        // 3. Parse JSON response
        // 4. Convert to [Word] array
    }
}
```

**Prompt Engineering** (key to good results):
```
You are a word generator for a "Hat" guessing game (like Taboo/Alias).
Generate {count} words for the theme "{theme}".

Rules:
- Difficulty level: {difficulty_description} (1-5 scale)
- Words should be single concepts (1-3 words max)
- Must be describable without saying the word itself
- Fun and engaging for group play
- No offensive or inappropriate content

Return JSON array: [{"word": "...", "complexity": 0-100}, ...]
```

#### 1.2 Create AIWordsLoader
**File**: `thehat/Models/AIWordsLoader.swift`

```swift
class AIWordsLoader: WordsLoaderProtocol {
    private var words: [Word] = []

    init(words: [Word]) {
        self.words = words
    }

    func getWords(count: Int, averageDifficulty: Int) -> [String] {
        // Return stored AI-generated words
        // Filter by difficulty if needed
        return words.prefix(count).map { $0.word }
    }
}
```

#### 1.3 API Configuration
**File**: `thehat/Config.plist` (add to .gitignore)

```xml
<dict>
    <key>OpenAI_API_Key</key>
    <string>sk-...</string>
</dict>
```

**File**: `thehat/Config.example.plist` (template for developers)

---

### Phase 2: UI Components

#### 2.1 Update GameSettingsViewController
**File**: `thehat/View Controllers/GameSettingsViewController.swift`

Changes needed:
1. Add 6th difficulty option: "Custom AI Pack" (index 5)
2. Detect when user selects index 5 in picker
3. Present `AIWordPackViewController` modally
4. Store AI pack state when returned

```swift
// Add property
var aiWordPack: [Word]? = nil
var aiPackTheme: String? = nil

// Modify difficulty picker to have 6 options
let difficulties = [
    LS.localizedString(forKey: "VERY_EASY"),
    LS.localizedString(forKey: "EASY"),
    LS.localizedString(forKey: "NORMAL"),
    LS.localizedString(forKey: "HARD"),
    LS.localizedString(forKey: "VERY_HARD"),
    LS.localizedString(forKey: "CUSTOM_AI_PACK")  // NEW
]

// In pickerView(_:didSelectRow:)
if row == 5 {
    presentAIWordPackScreen()
}

// Modify startRound() to use AI loader if AI pack selected
if let aiWords = aiWordPack {
    gameInstance.wordsLoader = AIWordsLoader(words: aiWords)
}
```

#### 2.2 Create AIWordPackViewController
**File**: `thehat/View Controllers/AIWordPackViewController.swift`

New view controller for:
- Theme input (UITextField)
- Word count selection (UIStepper, 10-100 range)
- Difficulty selection (reuse existing picker or segmented control)
- Generate button
- Loading indicator
- Preview of generated words
- Confirm/Cancel buttons

**States**:
1. **Input** - User enters theme and settings
2. **Loading** - API call in progress (show spinner, disable UI)
3. **Preview** - Show generated words with option to regenerate
4. **Error** - Show error message with retry option

```swift
class AIWordPackViewController: UIViewController {
    @IBOutlet weak var themeTextField: UITextField!
    @IBOutlet weak var wordCountStepper: UIStepper!
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var difficultySegment: UISegmentedControl!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previewTableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!

    var onComplete: (([Word], String) -> Void)?  // Callback with words and theme

    private var generatedWords: [Word] = []

    @IBAction func generateTapped(_ sender: Any) {
        guard let theme = themeTextField.text, !theme.isEmpty else {
            showError("Please enter a theme")
            return
        }

        setLoadingState(true)

        OpenAIService.shared.generateWords(
            theme: theme,
            difficulty: selectedDifficulty,
            count: Int(wordCountStepper.value)
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoadingState(false)
                switch result {
                case .success(let words):
                    self?.showPreview(words)
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }

    @IBAction func confirmTapped(_ sender: Any) {
        onComplete?(generatedWords, themeTextField.text ?? "Custom")
        dismiss(animated: true)
    }
}
```

#### 2.3 Update Storyboards
**Files**:
- `thehat/en.lproj/Main.storyboard`
- `thehat/ru.lproj/Main.storyboard`

Add new scene for `AIWordPackViewController`:
- Navigation bar with Cancel/Done buttons
- Theme text field with placeholder
- Word count stepper (10-100, default 40)
- Difficulty selector (Very Easy to Very Hard)
- Generate button (prominent styling)
- Loading indicator (hidden by default)
- Table view for word preview (scrollable)
- Confirm button (hidden until preview ready)

---

### Phase 3: Localization

#### 3.1 Add Localized Strings
**Files**:
- `thehat/en.lproj/Localizable.strings`
- `thehat/ru.lproj/Localizable.strings`

```
// English
"CUSTOM_AI_PACK" = "Custom AI Pack";
"AI_PACK_TITLE" = "AI Word Pack";
"THEME_PLACEHOLDER" = "Enter a theme (e.g., Movies, Sports)";
"WORD_COUNT" = "Number of words";
"GENERATE" = "Generate Words";
"GENERATING" = "Generating...";
"PREVIEW_TITLE" = "Generated Words";
"USE_THIS_PACK" = "Use This Pack";
"REGENERATE" = "Regenerate";
"AI_ERROR_NO_KEY" = "API key not configured";
"AI_ERROR_NETWORK" = "Network error. Please try again.";
"AI_ERROR_PARSE" = "Failed to parse response";

// Russian
"CUSTOM_AI_PACK" = "AI-пак слов";
"AI_PACK_TITLE" = "AI-генератор слов";
"THEME_PLACEHOLDER" = "Введите тему (напр. Фильмы, Спорт)";
"WORD_COUNT" = "Количество слов";
"GENERATE" = "Сгенерировать";
"GENERATING" = "Генерация...";
"PREVIEW_TITLE" = "Сгенерированные слова";
"USE_THIS_PACK" = "Использовать этот пак";
"REGENERATE" = "Сгенерировать заново";
"AI_ERROR_NO_KEY" = "API-ключ не настроен";
"AI_ERROR_NETWORK" = "Ошибка сети. Попробуйте снова.";
"AI_ERROR_PARSE" = "Не удалось обработать ответ";
```

---

### Phase 4: Game Flow Integration

#### 4.1 Modify Game Model
**File**: `thehat/Models/Game.swift`

Add support for custom word loader:

```swift
// Add property for AI pack metadata
var customPackTheme: String? = nil
var isUsingAIPack: Bool = false

// Modify updatePool() to handle pre-loaded AI words
func updatePool() {
    if isUsingAIPack && !words.isEmpty {
        // Words already loaded from AI, just update newWords set
        newWords.removeAll(keepingCapacity: true)
        for word in words {
            if word.state == .new {
                newWords.insert(word.word)
            }
        }
        return
    }

    // Existing logic for local words...
}
```

#### 4.2 Update GameSettingsViewController Flow
**File**: `thehat/View Controllers/GameSettingsViewController.swift`

```swift
// When AI pack is selected and confirmed
func aiPackCompleted(words: [Word], theme: String) {
    self.aiWordPack = words
    self.aiPackTheme = theme

    // Update UI to show AI pack is selected
    updateDifficultyLabel(with: "AI: \(theme)")

    // Update words count to match AI pack
    wordsInTheHatStepper.value = Double(words.count)
    updateWordsLabel()
}

// In startRound()
if let aiWords = aiWordPack {
    gameInstance.words = aiWords
    gameInstance.newWords = Set(aiWords.map { $0.word })
    gameInstance.isUsingAIPack = true
    gameInstance.customPackTheme = aiPackTheme
    gameInstance.wordsInTheHat = aiWords.count
}
```

---

### Phase 5: Error Handling & Edge Cases

#### 5.1 Network Error Handling
- Timeout: 30 seconds
- Retry button on failure
- Offline detection with user-friendly message

#### 5.2 API Rate Limiting
- Cache recent generations in memory
- Show "Regenerate" cooldown if needed

#### 5.3 Empty/Invalid Responses
- Validate word count matches request
- Filter out empty/duplicate words
- Fallback message if API returns garbage

#### 5.4 API Key Security
- Key stored in Config.plist (gitignored)
- Graceful handling when key missing
- Consider: Could add server proxy in future to hide key

---

### Phase 6: Analytics

#### 6.1 Track AI Pack Usage
**File**: `thehat/AppDelegate.swift` and relevant VCs

```swift
// New analytics events
Analytics.logEvent("ai_pack_generate", parameters: [
    "theme": theme,
    "word_count": count,
    "difficulty": difficulty
])

Analytics.logEvent("ai_pack_use", parameters: [
    "theme": theme,
    "word_count": words.count
])

Analytics.logEvent("ai_pack_error", parameters: [
    "error_type": error.code
])
```

---

## File Changes Summary

### New Files
1. `thehat/Services/OpenAIService.swift` - API client
2. `thehat/Models/AIWordsLoader.swift` - WordsLoaderProtocol implementation
3. `thehat/View Controllers/AIWordPackViewController.swift` - New VC
4. `thehat/Config.plist` - API key (gitignored)
5. `thehat/Config.example.plist` - Template for developers

### Modified Files
1. `thehat/View Controllers/GameSettingsViewController.swift` - Add AI option
2. `thehat/Models/Game.swift` - Support AI pack metadata
3. `thehat/en.lproj/Main.storyboard` - Add AI VC scene
4. `thehat/ru.lproj/Main.storyboard` - Add AI VC scene (Russian)
5. `thehat/en.lproj/Localizable.strings` - New strings
6. `thehat/ru.lproj/Localizable.strings` - New strings
7. `.gitignore` - Add Config.plist

---

## Testing Checklist

- [ ] Generate words with various themes
- [ ] Test all difficulty levels map correctly
- [ ] Verify word count matches request
- [ ] Test network error handling (airplane mode)
- [ ] Test API timeout
- [ ] Test invalid API key
- [ ] Test missing API key
- [ ] Verify generated words work in gameplay
- [ ] Test cancel during generation
- [ ] Test regenerate functionality
- [ ] Verify localization (EN/RU)
- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPad (if supported)
- [ ] Memory usage with large word counts

---

## Future Enhancements (Out of Scope)

1. **Save favorite packs** - Store generated packs locally for reuse
2. **Share packs** - Generate shareable codes/links
3. **Server-side proxy** - Hide API key, add rate limiting
4. **Offline fallback** - Cache previously generated packs
5. **Theme suggestions** - Show popular/trending themes
6. **Word editing** - Let users edit/remove specific words before playing
