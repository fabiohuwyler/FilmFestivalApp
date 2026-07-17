import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case german = "de"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        }
    }
}

class LanguageManager: ObservableObject {
    @Published var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Language.german.rawValue
        selectedLanguage = Language(rawValue: savedLanguage) ?? .german
    }
    
    static let shared = LanguageManager()
}

// Extension to help with localized strings
extension String {
    func possessiveForm(language: Language) -> String {
        switch language {
        case .german:
            return self + "s"
        case .french:
            return "de " + self
        }
    }
    func localized(_ language: Language) -> String {
        switch language {
        case .german:
            return germanStrings[self] ?? self
        case .french:
            return frenchStrings[self] ?? self
        }
    }
}

// String dictionaries for each language
private let germanStrings: [String: String] = [
    // Locations
    "accessibility": "Zugänglichkeit",
    
    // Movie Details
    "add_to_program": "Zum Programm hinzufügen",
    "remove_from_program": "Aus Programm entfernen",
    "buy_tickets": "Tickets kaufen",
    "back": "Zurück",
    "screenings": "Vorführungen",
    
    // Onboarding
    "choose_theme": "Wähle dein Farbschema",
    "select_theme_description": "Wähle ein Farbschema, das zu dir passt. Du kannst es später jederzeit ändern.",
    "continue": "Weiter",
    "personalize": "Personalisiere deine App",
    "enter_name_optional": "Gib deinen Namen ein (optional)",
    "your_name": "Dein Name",
    "get_started": "Los geht's!",
    // Existing strings
    "about_queersicht": "Über Queersicht",
    "about_description": "Das Festival wird von einem etwa 20-köpfigen Organisationskommitee ehrenamtlich organisiert und vom Verein Queersicht getragen. Ziel von Queersicht ist es, Höhepunkte des \"queer cinema\" zu zeigen, die in der Regel den Weg ins übliche Kinoprogramm nicht finden. Wir wollen das vielfältige Filmschaffen von und mit LGBTIAQ+ Menschen widerspiegeln. Das Filmprogramm umfasst Kurz-, Spiel- und Dokumentarfilme. An den besten sowie an den kontroversesten Kurzfilm werden die Publikumspreise \"Die Rosa Brille\" verliehen. Zudem vermitteln wir in unserem Rahmenprogramm queere Kultur.",
    "contact": "Kontakt",
    "social_media": "Social Media",
    "app_development": "App-Entwicklung",
    "festival_info": "Festival Info",
    "my_program": "Mein Programm",
    "view_all": "Alle anzeigen",
    "add_to_program_hint": "Füge Filme und Events zu deinem Programm hinzu, indem du auf das Herz-Symbol tippst",
    "movies": "Filme",
    "all": "Alle",
    "events": "Events",
    "queer_crush": "Queer Crush",
    "play_minigame": "Spiele unser Match-3 Mini-Spiel",
    "about_and_contacts": "Über das Festival, Barrierefreiheit & Kontakte",
    "settings": "Einstellungen",
    "language": "Sprache",
    "theme": "Farbschema",
    "done": "Fertig",
    "restart_game": "Neu starten",
    "time": "Zeit",
    "score": "Punkte",
    "times_up": "Zeit abgelaufen!",
    "final_score": "Endpunktzahl",
    "submit_score": "Punktzahl einreichen",
    "play_again": "Fertig",
    "submit_as": "Einreichen als",
    "score_submitted": "Punktzahl erfolgreich eingereicht!",
    "use_different_name": "Anderen Namen verwenden",
    "submit": "Einreichen",
    "enter_name": "Name eingeben",
    "name": "Name",
    "cancel": "Abbrechen",
    "error": "Fehler",
    "score_submit_error": "Fehler beim Einreichen der Punktzahl. Bitte versuche es später erneut.",
    "view_high_scores": "Bestenliste",
    "high_scores": "Bestenliste",
    "retry": "Erneut versuchen",
    "last_updated": "Zuletzt aktualisiert"
]

private let frenchStrings: [String: String] = [
    // Locations
    "accessibility": "Accessibilité",
    
    // Movie Details
    "add_to_program": "Ajouter au programme",
    "remove_from_program": "Retirer du programme",
    "buy_tickets": "Acheter des billets",
    "back": "Retour",
    "screenings": "Séances",
    
    // Onboarding
    "choose_theme": "Choisissez votre thème",
    "select_theme_description": "Choisissez un thème qui vous convient. Vous pourrez le modifier à tout moment.",
    "continue": "Continuer",
    "personalize": "Personnalisez votre app",
    "enter_name_optional": "Entrez votre nom (optionnel)",
    "your_name": "Votre nom",
    "get_started": "Commencer!",
    // Existing strings
    "about_queersicht": "À propos de Queersicht",
    "about_description": "Le festival est organisé bénévolement par un comité d'organisation composé d'environ 20 personnes et soutenu par l'association Queersicht. L'objectif de Queersicht est de montrer les perles cinéma queer qui ne trouvent pas le chemin du cinéma mainstream. Nous voulons refléter la diversité des films réalisés par et avec des personnes LGBTIAQ+. Le programme de films comprend des courts métrages, des films fictifs ainsi que des documentaires. Les prix du public Rosa Brille seront décernés au meilleur court-métrage ainsi qu'au plus controversé. En outre, nos événements permettent de faire vivre la culture queer.",
    "contact": "Contact",
    "social_media": "Réseaux sociaux",
    "app_development": "Développement de l'app",
    "festival_info": "Info Festival",
    "my_program": "Mon Programme",
    "view_all": "Voir tout",
    "add_to_program_hint": "Ajoutez des films et des événements à votre programme en appuyant sur l'icône cœur",
    "movies": "Films",
    "all": "Tous",
    "events": "Événements",
    "queer_crush": "Queer Crush",
    "play_minigame": "Jouez à notre mini-jeu Match-3",
    "about_and_contacts": "À propos du festival, accessibilité & contacts",
    "settings": "Paramètres",
    "language": "Langue",
    "theme": "Thème",
    "done": "Terminé",
    "restart_game": "Recommencer",
    "time": "Temps",
    "score": "Score",
    "times_up": "Temps écoulé!",
    "final_score": "Score final",
    "submit_score": "Soumettre le score",
    "play_again": "Rejouer",
    "submit_as": "Soumettre en tant que",
    "score_submitted": "Score soumis avec succès !",
    "use_different_name": "Utiliser un autre nom",
    "submit": "Soumettre",
    "enter_name": "Entrez votre nom",
    "name": "Nom",
    "cancel": "Annuler",
    "error": "Erreur",
    "score_submit_error": "Erreur lors de la soumission du score. Veuillez réessayer plus tard.",
    "view_high_scores": "Voir les meilleurs scores",
    "high_scores": "Meilleurs scores",
    "retry": "Réessayer",
    "last_updated": "Dernière mise à jour"
]
