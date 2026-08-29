import Foundation

/// Static Morse code lookup table and helpers.
enum MorseCode {

    static let map: [String: String] = [
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y",
        "--..": "Z",
        "-----": "0", ".----": "1", "..---": "2", "...--": "3", "....-": "4",
        ".....": "5", "-....": "6", "--...": "7", "---..": "8", "----.": "9",
        ".-.-.-": ".", "--..--": ",", "..--..": "?", ".----.": "'",
        "-.-.--": "!", "-..-.": "/", "-.--.": "(", "-.--.-": ")",
        ".-...": "&", "---...": ":", "-.-.-.": ";", "-...-": "=",
        ".-.-.": "+", "-....-": "-", "..--.-": "_", ".-..-.": "\"",
        "...-..-": "$", ".--.-.": "@"
    ]

    /// Decode a dot/dash pattern (e.g. "-..") into its character, if valid.
    static func decode(_ pattern: String) -> String? {
        map[pattern]
    }

    /// Encode a single character into its dot/dash pattern, if known.
    static func encode(_ character: Character) -> String? {
        let key = String(character).uppercased()
        return map.first(where: { $0.value == key })?.key
    }

    /// Reference chart rows (letters, then digits), used by the chart view.
    static let alphabet: [(String, String)] = {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return letters.compactMap { ch in
            guard let code = encode(ch) else { return nil }
            return (String(ch), code)
        }
    }()

    // MARK: - Tree navigation (used by Training mode)

    /// True if any known code continues past `pattern` (i.e. this branch has
    /// further letters beyond it, so navigation shouldn't stop here).
    static func hasContinuation(beyond pattern: String) -> Bool {
        map.keys.contains { $0.count > pattern.count && $0.hasPrefix(pattern) }
    }

    /// True if `pattern` is itself a real, reachable code — either a finished
    /// letter/digit, or a valid prefix of one. Used to decide whether a
    /// branch is worth showing at all.
    static func isReachable(_ pattern: String) -> Bool {
        pattern.isEmpty || map.keys.contains { $0.hasPrefix(pattern) }
    }
}
