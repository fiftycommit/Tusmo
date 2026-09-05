//
//  Pokemon.swift
//  Tusmo
//
//  Banque de Pokémon classée par génération.
//

import Foundation

enum GenerationPokemon: Int, CaseIterable, Hashable, Identifiable {
    case une = 1
    case deux = 2
    case trois = 3
    case quatre = 4
    case cinq = 5
    case six = 6
    case sept = 7
    case huit = 8
    case neuf = 9

    var id: Int { rawValue }

    var titre: String {
        "Génération \(rawValue)"
    }

    /// Clé stable utilisée pour sauvegarder les Pokémon déjà trouvés.
    var cleProgression: String {
        "pokemon.generation.\(rawValue)"
    }

    static var totalMots: Int {
        allCases.reduce(0) { total, generation in
            total + Set(generation.mots).count
        }
    }

    /// Poids éditorial propre à la génération.
    /// La difficulté mesure la notoriété du Pokémon, pas la longueur de son
    /// nom ni son numéro de génération.
    var poidsParMot: [String: Int] {
        let plages: [ClosedRange<Int>] = [80...100, 60...79, 40...59, 20...39, 1...19]
        var resultats: [String: Int] = [:]

        for (index, groupe) in motsParNiveau.enumerated() {
            let plage = plages[index]
            let denominateur = max(groupe.count - 1, 1)
            let amplitude = plage.upperBound - plage.lowerBound

            for (position, mot) in groupe.enumerated() {
                let poids = plage.upperBound - Int(
                    (Double(position) / Double(denominateur) * Double(amplitude)).rounded()
                )
                resultats[mot] = poids
            }
        }

        return resultats
    }

    func poidsDuMot(_ mot: String) -> Int {
        poidsParMot[mot.uppercased()] ?? 50
    }

    func niveauDuMot(_ mot: String) -> NiveauJeu {
        NiveauJeu.depuisPoids(poidsDuMot(mot))
    }

    var repartitionDifficulte: [NiveauJeu: Int] {
        mots.reduce(into: [:]) { resultats, mot in
            let niveau = niveauDuMot(mot)
            resultats[niveau, default: 0] += 1
        }
    }

    /// Pokémon emblématiques à proposer lors de la découverte d'une
    /// génération. Les formes moins connues arrivent seulement ensuite.
    private var premiersMots: Set<String> {
        Set(motsParNiveau.first ?? [])
    }

    var region: String {
        switch self {
        case .une: return "Kanto"
        case .deux: return "Johto"
        case .trois: return "Hoenn"
        case .quatre: return "Sinnoh"
        case .cinq: return "Unys"
        case .six: return "Kalos"
        case .sept: return "Alola"
        case .huit: return "Galar"
        case .neuf: return "Paldea"
        }
    }

    /// Groupes éditoriaux : Débutant, Apprenti, Confirmé, Expert, Maître.
    /// Une génération peut ne pas avoir de mot dans les derniers groupes.
    private var motsParNiveau: [[String]] {
        switch self {
        case .une:
            return [
                ["PIKACHU", "SALAMECHE", "CARAPUCE", "DRACAUFEU", "TORTANK", "EVOLI", "MEWTWO"],
                ["RAICHU", "MIAOUSS", "PSYKOKWAK", "LEVIATOR", "AQUALI", "VOLTALI", "PYROLI", "LOKHLASS", "ARTIKODIN", "ELECTHOR", "SULFURA"],
                ["RATTATA", "ROUCOOL", "CANINOS", "TETARTE"],
                ["PIAFABEC"],
                []
            ]
        case .deux:
            return [
                ["LUGIA", "CELEBI", "TYRANOCIF", "SUICUNE", "ENTEI"],
                ["GERMIGNON", "KAIMINUS", "MARILL", "MENTALI", "NOCTALI", "RAIKOU"],
                ["FOUINETTE", "PHARAMP", "AZUMARILL", "SCARHINO", "FARFURET", "TEDDIURSA", "URSARING"],
                ["HOOTHOOT", "MIMIGAL", "CROCRODIL", "CORAYON", "LIMAGMA", "COCHIGNON"],
                []
            ]
        case .trois:
            return [
                ["GARDEVOIR", "BRASEGALI", "LAGGRON", "RAYQUAZA", "KYOGRE", "GROUDON", "ABSOL"],
                ["ARCKO", "POUSSIFEU", "GOBOU", "JUNGKO", "TARSAL", "LIBEGON", "ALTARIA", "LATIAS", "LATIOS", "JIRACHI"],
                ["GALIFEU", "FLOBIO", "KIRLIA", "ZIGZATON", "WAILMER", "BARPAU", "KRAKNOIX", "DEOXYS"],
                ["GOELISE", "MEDHYENA", "GRAHYENA", "VIBRANINF"],
                []
            ]
        case .quatre:
            return [
                ["TIPLOUF", "LUCARIO", "GIRATINA", "ARCEUS", "DARKRAI"],
                ["RIOLU", "PACHIRISU", "ROSERADE", "MOTISMA", "SHAYMIN", "MANAPHY", "REGIGIGAS"],
                ["ETOURMI", "STARAVIA", "KEUNOTOR", "BAUDRIVE", "SCORVOL", "BLIZZAROI", "CREHELF", "CREFOLLET", "CREFADET", "CORBOSS"],
                ["CRIKZIK", "ROZBOUTON", "FLOATZEL", "CHERUBI", "MOUFFLAIR", "BLIZZI"],
                []
            ]
        case .cinq:
            return [
                ["ZOROARK", "ZEKROM", "RESHIRAM", "KYUREM"],
                ["ZORUA", "VICTINI", "GENESECT", "GRUIKUI", "EMOLGA", "DARUMACHO"],
                ["PONCHIOT", "ROTOTAUPE", "MASCAIMAN", "ESCROCO", "FRAGILADY", "VIVALDAIM", "SCALPION", "SCALPROIE", "MELOETTA"],
                ["FLAMAJOU", "FLOTAJOU", "RATENTIF", "MARACACHI", "KUNGFUINE", "CARABING", "LANCARGOT", "GAULET", "MIAMIASME"],
                []
            ]
        case .six:
            return [
                ["GRENOUSSE", "NYMPHALI", "XERNEAS", "YVELTAL"],
                ["FEUNNEC", "MARISSON", "EXAGIDE", "ZYGARDE", "HOOPA"],
                ["GOUPELIN", "DEDENNE", "MONORPALE", "DIMOCLES", "AMAGARA", "DRAGMARA", "DIANCIE", "VOLCANION"],
                ["SAPEREAU", "PEREGRAIN", "GALVARAN", "FLORGES", "CHEVROUM", "VENALGUE", "KRAVARECH", "SUCROQUIN", "COCOTINE"],
                []
            ]
        case .sept:
            return [
                ["BRINDIBOU", "FLAMIAOU", "OTAQUIN", "MIMIQUI", "SOLGALEO", "LUNALA"],
                ["ROCABOT", "LOUGAROC", "NECROZMA", "ZERAORA", "MELTAN", "MELMETAL", "MARSHADOW"],
                ["PICASSAUT", "PLUMELINE", "SILVALLIE", "DODOALA", "BOUMATA", "METENO", "KATAGAMI"],
                ["SOVKIPOU", "BACABOUH", "MIMANTIS", "SPODODO", "LAMPIGNON", "CROQUINE", "CANDINE", "SUCREINE", "BOMBYDOU"],
                []
            ]
        case .huit:
            return [
                ["FLAMBINO", "ZACIAN", "ZAMAZENTA", "ETERNATOS"],
                ["OUISTEMPO", "LARMELEON", "MOUMOUTON", "DURALUGON", "WUSHOURS", "SHIFOURS", "SYLVEROY"],
                ["MINISANGE", "VOLTOUTOU", "FULGUDOG", "FANTYRM", "REGIELEKI", "REGIDRAGO", "AMOVENUS"],
                ["KHELOCROK", "TORGAMORD", "BLANCOTON", "CHARIBARI", "POULPAF", "KRAKOS", "BLIZZEVAL"],
                []
            ]
        case .neuf:
            return [
                ["POUSSACHA", "KORAIDON", "MIRAIDON", "OGERPON"],
                ["MATOUGEON", "CROCOGRIL", "COIFFETON", "AMPIBIDOU", "FORGELINA", "MALVALAME", "SUPERDOFIN", "GROMAGO"],
                ["GOURMELET", "OLIVINI", "PATACHIOT", "COMPAGNOL", "FAMIGNOL", "ZAPETREL", "FULGULAIRO", "GRONDOGUE", "DOGRINO", "SCOVILAIN", "BALBALEZE", "ARBOLIVA", "TERAPAGOS"],
                [],
                []
            ]
        }
    }

    /// Liste aplatie utilisée par le moteur de jeu.
    var mots: [String] {
        motsParNiveau.flatMap { $0 }
    }

    func motAleatoire(niveau: NiveauJeu, sauf: String? = nil) -> String {
        motAleatoireNonTrouve(niveau: niveau, sauf: sauf, exclus: []) ?? "PIKACHU"
    }

    /// Tire un Pokémon qui n'appartient pas à `exclus`.
    /// Retourne `nil` quand toute la génération est découverte.
    func motAleatoireNonTrouve(
        niveau: NiveauJeu,
        sauf: String? = nil,
        exclus: Set<String>
    ) -> String? {
        let nonExclus = Array(Set(mots.filter { !exclus.contains($0) }))
        let disponibles = nonExclus.count > 1
            ? nonExclus.filter { $0 != sauf }
            : nonExclus
        guard !disponibles.isEmpty else { return nil }

        let progression = mots.isEmpty
            ? 0
            : Double(Set(mots).intersection(exclus).count) / Double(Set(mots).count)
        let niveauMaximum = NiveauJeu.maximumDebloque(
            pourcentageDecouvert: progression
        )
        let niveauSelection = niveau.rawValue <= niveauMaximum.rawValue
            ? niveau
            : niveauMaximum

        // Une génération commence par ses mascottes, starters et légendaires
        // les plus connus, quel que soit le nombre de lettres de leur nom.
        if niveauSelection == .debutant {
            let premiersDisponibles = disponibles.filter { premiersMots.contains($0) }
            if let mot = premiersDisponibles.randomElement() {
                return mot
            }
        }

        let compatibles = disponibles.filter {
            niveauDuMot($0) == niveauSelection
        }
        if let mot = compatibles.randomElement() {
            return mot
        }

        let distanceMinimum = disponibles
            .map { abs(niveauDuMot($0).rawValue - niveauSelection.rawValue) }
            .min() ?? 0
        let choix = disponibles.filter {
            abs(niveauDuMot($0).rawValue - niveauSelection.rawValue) == distanceMinimum
        }
        return choix.randomElement()
    }
}
