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

    /// Poids de familiarité propre aux Pokémon de cette génération.
    /// L'ordre de la banque va du plus connu au plus spécifique, avec des
    /// corrections pour les mascottes et les Pokémon emblématiques.
    var poidsParMot: [String: Int] {
        MoteurDifficulte.poidsParOrdreDeNotoriete(
            mots,
            surcharges: surchargesNotoriete
        )
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

    private var surchargesNotoriete: [String: Int] {
        switch self {
        case .une:
            return [
                "PIKACHU": 100, "DRACAUFEU": 98, "MEWTWO": 96,
                "TORTANK": 94, "SALAMECHE": 94, "CARAPUCE": 94,
                "EVOLI": 93, "RAICHU": 88, "LEVIATOR": 88
            ]
        case .deux:
            return [
                "LUGIA": 100, "NOCTALI": 94, "MENTALI": 94,
                "TYRANOCIF": 93, "CELEBI": 92, "SUICUNE": 90,
                "RAIKOU": 89, "ENTEI": 89, "AZUMARILL": 86
            ]
        case .trois:
            return [
                "GARDEVOIR": 96, "KYOGRE": 100, "GROUDON": 99,
                "RAYQUAZA": 100, "ABSOL": 92, "LAGGRON": 91,
                "BRASEGALI": 90
            ]
        case .quatre:
            return [
                "LUCARIO": 100, "ARCEUS": 99, "GIRATINA": 98,
                "DARKRAI": 96, "SHAYMIN": 93, "ROSERADE": 87
            ]
        case .cinq:
            return [
                "ZORUA": 96, "ZOROARK": 96, "RESHIRAM": 99,
                "ZEKROM": 99, "KYUREM": 96, "VICTINI": 93
            ]
        case .six:
            return [
                "GRENOUSSE": 96, "NYMPHALI": 97, "XERNEAS": 99,
                "YVELTAL": 98, "ZYGARDE": 95
            ]
        case .sept:
            return [
                "MIMIQUI": 100, "LUNALA": 98, "SOLGALEO": 98,
                "MELTAN": 96, "MELMETAL": 96, "LOUGAROC": 89
            ]
        case .huit:
            return [
                "ZACIAN": 100, "ZAMAZENTA": 99, "ETERNATOS": 97,
                "CALYREX": 93, "SHIFOURS": 90, "DURALUGON": 89
            ]
        case .neuf:
            return [
                "MIRAIDON": 100, "KORAIDON": 100, "PALAFIN": 95,
                "OGERPON": 95, "TERAPAGOS": 94, "TINKATON": 93
            ]
        }
    }

    /// Pokémon emblématiques à proposer lors de la découverte d'une
    /// génération. Les formes moins connues arrivent seulement ensuite.
    private var premiersMots: Set<String> {
        switch self {
        case .une:
            return ["PIKACHU", "SALAMECHE", "CARAPUCE", "DRACAUFEU", "MEWTWO", "EVOLI"]
        case .deux:
            return ["LUGIA", "MENTALI", "NOCTALI", "TYRANOCIF", "SUICUNE"]
        case .trois:
            return ["POUSSIFEU", "GARDEVOIR", "KYOGRE", "GROUDON", "RAYQUAZA", "BRASEGALI"]
        case .quatre:
            return ["TIPLOUF", "LUCARIO", "ARCEUS", "GIRATINA", "DARKRAI", "SHAYMIN"]
        case .cinq:
            return ["GRUIKUI", "ZORUA", "ZOROARK", "RESHIRAM", "ZEKROM", "KYUREM"]
        case .six:
            return ["FEUNNEC", "GRENOUSSE", "NYMPHALI", "XERNEAS", "YVELTAL", "ZYGARDE"]
        case .sept:
            return ["BRINDIBOU", "MIMIQUI", "LUNALA", "SOLGALEO", "MELTAN", "MELMETAL"]
        case .huit:
            return ["FLAMBINO", "DURALUGON", "SHIFOURS", "ZACIAN", "ZAMAZENTA", "ETERNATOS"]
        case .neuf:
            return ["POUSSACHA", "TINKATON", "PALAFIN", "KORAIDON", "MIRAIDON", "OGERPON"]
        }
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

    /// Noms sans accents, espaces ni signes : ils sont directement jouables
    /// avec la saisie actuelle de Tusmo.
    var mots: [String] {
        switch self {
        case .une:
            return [
                "SALAMECHE", "CARAPUCE", "PIKACHU", "RAICHU", "RATTATA",
                "ROUCOOL", "PIAFABEC", "CANINOS", "MIAOUSS", "PSYKOKWAK",
                "TETARTE", "LOKHLASS", "DRACAUFEU", "TORTANK", "LEVIATOR",
                "EVOLI", "AQUALI", "VOLTALI", "PYROLI", "MEWTWO",
                "ARTIKODIN", "ELECTHOR", "SULFURA"
            ]
        case .deux:
            return [
                "GERMIGNON", "KAIMINUS", "FOUINETTE", "HOOTHOOT", "MIMIGAL",
                "CROCRODIL", "PHARAMP", "MARILL", "AZUMARILL", "MENTALI",
                "NOCTALI", "CORAYON", "SCARHINO", "FARFURET", "TEDDIURSA",
                "URSARING", "LIMAGMA", "COCHIGNON", "CORBOSS", "LUGIA",
                "CELEBI", "TYRANOCIF", "SUICUNE", "RAIKOU", "ENTEI"
            ]
        case .trois:
            return [
                "ARCKO", "POUSSIFEU", "GOBOU", "GALIFEU", "FLOBIO",
                "JUNGKO", "BRASEGALI", "LAGGRON", "ZIGZATON",
                "GOELISE", "TARSAL", "KIRLIA", "GARDEVOIR", "MEDHYENA",
                "GRAHYENA", "WAILMER", "BARPAU", "KRAKNOIX", "VIBRANINF",
                "LIBEGON", "ALTARIA", "ABSOL", "LATIAS", "LATIOS",
                "KYOGRE", "GROUDON", "RAYQUAZA", "JIRACHI", "DEOXYS"
            ]
        case .quatre:
            return [
                "TIPLOUF", "ETOURMI", "STARAVIA", "KEUNOTOR", "CRIKZIK",
                "ROZBOUTON", "ROSERADE", "PACHIRISU",
                "FLOATZEL", "CHERUBI", "BAUDRIVE", "MOUFFLAIR", "RIOLU",
                "LUCARIO", "SCORVOL", "BLIZZI", "BLIZZAROI", "MOTISMA",
                "CREHELF", "CREFOLLET", "CREFADET", "REGIGIGAS", "GIRATINA",
                "ARCEUS", "DARKRAI", "SHAYMIN", "MANAPHY"
            ]
        case .cinq:
            return [
                "GRUIKUI", "PONCHIOT", "FLAMAJOU", "FLOTAJOU", "RATENTIF",
                "ROTOTAUPE", "DARUMACHO", "MARACACHI", "KUNGFUINE", "MASCAIMAN",
                "ESCROCO", "ZORUA", "ZOROARK", "FRAGILADY", "VIVALDAIM", "EMOLGA",
                "CARABING", "LANCARGOT", "SCALPION", "SCALPROIE",
                "GAULET", "MIAMIASME", "ZEKROM", "RESHIRAM", "KYUREM",
                "VICTINI", "MELOETTA", "GENESECT"
            ]
        case .six:
            return [
                "MARISSON", "FEUNNEC", "GRENOUSSE", "SAPEREAU", "PEREGRAIN",
                "GALVARAN", "AMAGARA", "NYMPHALI", "FLORGES", "GOUPELIN",
                "CHEVROUM", "MONORPALE", "DIMOCLES",
                "EXAGIDE", "VENALGUE", "KRAVARECH", "SUCROQUIN", "DEDENNE",
                "COCOTINE", "DRAGMARA", "XERNEAS",
                "YVELTAL", "ZYGARDE", "DIANCIE", "HOOPA", "VOLCANION"
            ]
        case .sept:
            return [
                "BRINDIBOU", "FLAMIAOU", "OTAQUIN", "PICASSAUT", "PLUMELINE",
                "ROCABOT", "LOUGAROC", "SOVKIPOU", "BACABOUH", "MIMANTIS",
                "SPODODO", "LAMPIGNON", "CROQUINE", "CANDINE", "SUCREINE",
                "BOMBYDOU", "SILVALLIE", "MIMIQUI",
                "DODOALA", "BOUMATA", "METENO", "KATAGAMI", "NECROZMA",
                "LUNALA", "SOLGALEO", "MARSHADOW", "ZERAORA", "MELTAN",
                "MELMETAL"
            ]
        case .huit:
            return [
                "OUISTEMPO", "FLAMBINO", "LARMELEON", "MINISANGE",
                "MOUMOUTON", "KHELOCROK", "TORGAMORD", "VOLTOUTOU", "FULGUDOG",
                "BLANCOTON", "CHARIBARI", "DURALUGON", "FANTYRM", "POULPAF",
                "KRAKOS", "WUSHOURS", "SHIFOURS", "ZACIAN", "ZAMAZENTA",
                "ETERNATOS", "CALYREX", "REGIELEKI", "REGIDRAGO", "BLIZZEVAL",
                "AMOVENUS", "SYLVEROY"
            ]
        case .neuf:
            return [
                "POUSSACHA", "MATOUGEON", "CROCOGRIL", "COIFFETON", "GOURMELET",
                "OLIVINI", "PATACHIOT", "BALBALEZE",
                "COMPAGNOL", "FAMIGNOL", "ZAPETREL", "FULGULAIR", "GRONDOGUE",
                "DOGRINO", "AMPIBIDOU", "SCOVILAIN",
                "BELLIBOLT", "TINKATON", "CERULEDGE", "PALAFIN", "CETITAN",
                "KORAIDON", "MIRAIDON", "GHOLDENGO", "OGERPON", "TERAPAGOS",
                "ARBOLIVA", "LOKIX"
            ]
        }
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

        // Une génération commence par ses mascottes, starters et légendaires
        // les plus connus, quel que soit le nombre de lettres de leur nom.
        if niveau == .debutant {
            let premiersDisponibles = disponibles.filter { premiersMots.contains($0) }
            if let mot = premiersDisponibles.randomElement() {
                return mot
            }
        }

        let compatibles = disponibles.filter {
            niveauDuMot($0) == niveau
        }
        if let mot = compatibles.randomElement() {
            return mot
        }

        let distanceMinimum = disponibles
            .map { abs(niveauDuMot($0).rawValue - niveau.rawValue) }
            .min() ?? 0
        let choix = disponibles.filter {
            abs(niveauDuMot($0).rawValue - niveau.rawValue) == distanceMinimum
        }
        return choix.randomElement()
    }
}
