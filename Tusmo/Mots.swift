//
//  Mots.swift
//  Tusmo
//
//  Banque de mots pour le mode solo : mots français courants, sans accent
//  ni tiret, de 5 à 9 lettres.
//

import Foundation

struct Theme: Identifiable, Hashable {
    let id = UUID()
    let nom: String
    let emoji: String
    let mots: [String]

    var estPokemon: Bool {
        nom == "Pokémon"
    }

    /// Un mot au hasard, différent de `sauf` si possible.
    func motAleatoire(sauf: String? = nil) -> String {
        let choix = mots.filter { $0 != sauf }
        return (choix.isEmpty ? mots : choix).randomElement() ?? "MOTUS"
    }

    /// Un mot adapté au niveau du joueur, différent de `sauf` si possible.
    ///
    /// Certains thèmes n'ont pas de mot dans chaque plage de longueur. Dans
    /// ce cas, on revient au mot du thème le plus proche afin qu'une partie
    /// reste toujours lançable.
    func motAleatoire(niveau: NiveauJeu, sauf: String? = nil) -> String {
        let motsDuNiveau = mots.filter {
            niveau.longueurs.contains($0.count) && $0 != sauf
        }

        if let mot = motsDuNiveau.randomElement() {
            return mot
        }

        let autresMots = mots.filter { $0 != sauf }
        guard !autresMots.isEmpty else { return "MOTUS" }

        let distanceMinimum = autresMots
            .map { distance($0.count, de: niveau.longueurs) }
            .min() ?? 0
        let motsLesPlusProches = autresMots.filter {
            distance($0.count, de: niveau.longueurs) == distanceMinimum
        }
        return motsLesPlusProches.randomElement() ?? "MOTUS"
    }

    private func distance(_ longueur: Int, de plage: ClosedRange<Int>) -> Int {
        if longueur < plage.lowerBound { return plage.lowerBound - longueur }
        if longueur > plage.upperBound { return longueur - plage.upperBound }
        return 0
    }
}

enum BanqueDeMots {
    static let themes: [Theme] = [
        Theme(nom: "Sport", emoji: "🏀", mots: [
            "BALLON", "PANIER", "ARBITRE", "MAILLOT", "RAQUETTE", "NATATION",
            "MARATHON", "DRIBBLE", "PODIUM", "SPRINT", "TRIBUNE", "PENALTY",
            "GARDIEN", "ESCALADE", "VESTIAIRE", "COUREUR", "TENNIS", "ESCRIME"
        ]),
        Theme(nom: "Musique", emoji: "🎵", mots: [
            "GUITARE", "BATTERIE", "CONCERT", "MELODIE", "REFRAIN", "COUPLET",
            "CHANTEUR", "RYTHME", "PIANO", "VIOLON", "PAROLES", "ALBUM",
            "SCENE", "TROMPETTE", "CASQUE", "ACCORD", "SILENCE", "TAMBOUR"
        ]),
        Theme(nom: "Nourriture", emoji: "🍕", mots: [
            "PIZZA", "GATEAU", "FROMAGE", "SALADE", "POULET", "CREPE",
            "BURGER", "DESSERT", "CHOCOLAT", "TOMATE", "BAGUETTE", "PATES",
            "SANDWICH", "YAOURT", "RACLETTE", "POIVRON", "BANANE", "GLACE"
        ]),
        Theme(nom: "Animaux", emoji: "🐾", mots: [
            "RENARD", "PANTHERE", "DAUPHIN", "ECUREUIL", "TORTUE", "PERROQUET",
            "GIRAFE", "SERPENT", "HIBOU", "REQUIN", "LEZARD", "BALEINE",
            "CHEVAL", "MOUTON", "CANARD", "ARAIGNEE", "PINGOUIN", "BLAIREAU"
        ]),
        Theme(nom: "Voyage", emoji: "✈️", mots: [
            "VALISE", "AVION", "PLAGE", "HOTEL", "BILLET", "DOUANE",
            "DESERT", "MONTAGNE", "PASSEPORT", "TRAIN", "SEJOUR", "CROISIERE",
            "CAMPING", "AEROPORT", "BAGAGE", "ESCALE", "RANDONNEE", "BOUSSOLE"
        ]),
        Theme(nom: "Cinéma", emoji: "🎬", mots: [
            "ACTEUR", "CAMERA", "ECRAN", "COMEDIE", "SUSPENSE", "TOURNAGE",
            "REPLIQUE", "SCENARIO", "DECOR", "COSTUME", "MONTAGE", "HORREUR",
            "CINEMA", "SEANCE", "AFFICHE", "DOUBLAGE", "STUDIO", "INTRIGUE"
        ]),
        Theme(nom: "École", emoji: "🎓", mots: [
            "CAHIER", "STYLO", "DEVOIR", "LYCEE", "EXAMEN", "CLASSE",
            "TABLEAU", "CANTINE", "DIPLOME", "LECTURE", "CALCUL", "MANUEL",
            "TROUSSE", "BULLETIN", "PUPITRE", "ETUDIANT", "RENTREE", "CARTABLE"
        ]),
        Theme(nom: "Techno", emoji: "💻", mots: [
            "CLAVIER", "SOURIS", "LOGICIEL", "RESEAU", "INTERNET", "MEMOIRE",
            "FICHIER", "ROBOT", "CONSOLE", "MANETTE", "DRONE", "CAPTEUR",
            "PIXEL", "ECOUTEUR", "MESSAGE", "PIRATE", "TABLETTE", "MOTEUR"
        ]),
        Theme(nom: "Nature", emoji: "🌳", mots: [
            "FORET", "RIVIERE", "ORAGE", "NUAGE", "VOLCAN", "PRAIRIE",
            "CASCADE", "GLACIER", "SENTIER", "FEUILLE", "RACINE", "SABLE",
            "MARAIS", "ARBRE", "TEMPETE", "HORIZON", "BRUME", "FALAISE"
        ]),
        Theme(nom: "Quotidien", emoji: "🏠", mots: [
            "REVEIL", "SOIREE", "AMITIE", "SOURIRE", "VOISIN", "CUISINE",
            "JARDIN", "MAISON", "TELEPHONE", "MARCHE", "QUARTIER", "DIMANCHE",
            "VOITURE", "FENETRE", "CANAPE", "MIROIR", "COURSES", "VACANCES"
        ])
    ]

    /// Thème spécial qui pioche dans tous les autres.
    static let melange = Theme(
        nom: "Mélange",
        emoji: "🎲",
        mots: themes.flatMap(\.mots)
    )

    /// Thème avec une étape supplémentaire pour choisir la génération.
    static let pokemon = Theme(
        nom: "Pokémon",
        emoji: "⚡️",
        mots: []
    )

    static var tous: [Theme] { themes + [melange, pokemon] }
}
