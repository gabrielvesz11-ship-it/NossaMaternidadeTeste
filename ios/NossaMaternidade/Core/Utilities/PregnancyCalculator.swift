import Foundation

enum PregnancyCalculator {
    static func currentWeek(dueDate: Date?, today: Date = Date()) -> Int? {
        guard let dueDate else { return nil }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDueDate = calendar.startOfDay(for: dueDate)
        guard let daysUntilDueDate = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate).day else {
            return nil
        }

        let gestationalDays = 280 - daysUntilDueDate
        guard gestationalDays >= 0 else { return nil }
        return min(max((gestationalDays / 7) + 1, 1), 40)
    }

    static func progress(dueDate: Date?) -> Double {
        guard let week = currentWeek(dueDate: dueDate) else { return 0 }
        return min(max(Double(week) / 40.0, 0), 1)
    }

    static func babySizeText(for week: Int?) -> String {
        guard let week else {
            return "Hoje seu bebê segue crescendo no tempo dele."
        }

        switch week {
        case 1...8: return "Hoje seu bebê está pequenininho, como uma semente de carinho."
        case 9...12: return "Hoje seu bebê está mais ou menos do tamanho de uma ameixa."
        case 13...16: return "Hoje seu bebê está mais ou menos do tamanho de um abacate."
        case 17...20: return "Hoje seu bebê está mais ou menos do tamanho de uma manga."
        case 21...24: return "Hoje seu bebê está mais ou menos do tamanho de um mamão pequeno."
        case 25...28: return "Hoje seu bebê está mais ou menos do tamanho de uma berinjela."
        case 29...32: return "Hoje seu bebê está mais ou menos do tamanho de um coco."
        case 33...36: return "Hoje seu bebê está mais ou menos do tamanho de um melão."
        default: return "Hoje seu bebê já ocupa um espaço lindo na sua rotina."
        }
    }
}

enum DailySuggestion {
    static func text(for date: Date = Date()) -> String {
        let suggestions = [
            "Hoje, tente beber água antes de sentir sede.",
            "Hoje, deixa uma pausa pequena caber no seu dia.",
            "Hoje, respira fundo antes de cobrar tanto de você.",
            "Hoje, escolhe uma refeição que te abrace por dentro.",
            "Hoje, coloca a mão na barriga e percebe seu ritmo."
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return suggestions[day % suggestions.count]
    }
}
