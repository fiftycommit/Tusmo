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
        let compatibles = mots.filter {
            niveau.longueurs.contains($0.count) && $0 != sauf
        }
        let autresMots = mots.filter { $0 != sauf }
        guard !autresMots.isEmpty else { return "PIKACHU" }

        if !compatibles.isEmpty {
            return compatibles.randomElement() ?? "PIKACHU"
        }

        let distanceMinimum = autresMots
            .map { distance($0.count, de: niveau.longueurs) }
            .min() ?? 0
        let choix = autresMots.filter {
            distance($0.count, de: niveau.longueurs) == distanceMinimum
        }
        return choix.randomElement() ?? "PIKACHU"
    }

    private func distance(_ longueur: Int, de plage: ClosedRange<Int>) -> Int {
        if longueur < plage.lowerBound { return plage.lowerBound - longueur }
        if longueur > plage.upperBound { return longueur - plage.upperBound }
        return 0
    }
}
