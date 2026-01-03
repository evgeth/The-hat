//
//  UsedWordsService.swift
//  thehat
//
//  Tracks recently used words to avoid repetition across games
//

import Foundation

protocol UsedWordsServiceProtocol {
    func markWordsAsUsed(_ words: [String])
    func getUsedWords() -> Set<String>
    func filterOutUsedWords(from words: [String]) -> [String]
    func clearHistory()
}

final class UsedWordsService: UsedWordsServiceProtocol {

    static let shared = UsedWordsService()

    private let defaults = UserDefaults.standard
    private let maxStoredWords = 500  // Keep last 500 words per language

    private enum Keys {
        static let russianUsedWords = "usedWords_ru"
        static let englishUsedWords = "usedWords_en"
    }

    private var currentKey: String {
        let isRussian = Locale.preferredLanguages[0].contains("ru")
        return isRussian ? Keys.russianUsedWords : Keys.englishUsedWords
    }

    // MARK: - Public API

    func markWordsAsUsed(_ words: [String]) {
        var usedWords = getUsedWordsArray()
        usedWords.append(contentsOf: words)

        // Keep only the last maxStoredWords
        if usedWords.count > maxStoredWords {
            usedWords = Array(usedWords.suffix(maxStoredWords))
        }

        defaults.set(usedWords, forKey: currentKey)
    }

    func getUsedWords() -> Set<String> {
        return Set(getUsedWordsArray())
    }

    func filterOutUsedWords(from words: [String]) -> [String] {
        let usedWords = getUsedWords()
        return words.filter { !usedWords.contains($0) }
    }

    func clearHistory() {
        defaults.removeObject(forKey: Keys.russianUsedWords)
        defaults.removeObject(forKey: Keys.englishUsedWords)
    }

    // MARK: - Private

    private func getUsedWordsArray() -> [String] {
        return defaults.stringArray(forKey: currentKey) ?? []
    }
}
