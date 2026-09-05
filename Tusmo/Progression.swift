//
//  Progression.swift
//  Tusmo
//
//  Progression automatique et profils de sauvegarde de Tusmo.
//

import Foundation
import Combine

enum NiveauJeu: Int, CaseIterable, Codable, Hashable, Identifiable {
    case debutant = 1
    case apprenti = 2
    case confirme = 3
    case expert = 4
    case maitre = 5

    var id: Int { rawValue }

    var nom: String {
        switch self {
        case .debutant: return "Débutant"
        case .apprenti: return "Apprenti"
        case .confirme: return "Confirmé"
        case .expert: return "Expert"
        case .maitre: return "Maître"
        }
    }

    var emoji: String {
        switch self {
        case .debutant: return "🌱"
        case .apprenti: return "🧩"
        case .confirme: return "🔥"
        case .expert: return "⚡️"
        case .maitre: return "👑"
        }
    }

    var description: String {
        switch self {
        case .debutant: return "Des termes très connus pour commencer"
        case .apprenti: return "Des termes courants, avec quelques pièges"
        case .confirme: return "La connaissance du thème devient importante"
        case .expert: return "Des termes plus spécifiques à retrouver"
        case .maitre: return "Les références les plus pointues du thème"
        }
    }

    /// Convertit un poids de notoriété en niveau de jeu.
    ///
    /// 100 représente un terme immédiatement identifiable, tandis que 1
    /// représente un terme très spécialisé. La longueur n'intervient pas.
    static func depuisPoids(_ poids: Int) -> NiveauJeu {
        switch min(max(poids, 1), 100) {
        case 80...100: return .debutant
        case 60..<80: return .apprenti
        case 40..<60: return .confirme
        case 20..<40: return .expert
        default: return .maitre
        }
    }

    /// Le temps de réflexion se réduit légèrement aux deux derniers niveaux.
    var nombreEssais: Int {
        rawValue >= NiveauJeu.expert.rawValue ? 5 : 6
    }

    /// Les termes plus spécifiques rapportent davantage dans les modes à score.
    var multiplicateurScore: Double {
        1.0 + Double(rawValue - 1) * 0.15
    }

    /// Nombre de victoires nécessaires pour débloquer le niveau suivant.
    var experienceNecessaire: Int {
        rawValue + 2
    }

    var estMaximum: Bool {
        self == .maitre
    }
}

/// Construit les poids de notoriété à partir de l'ordre éditorial d'une
/// banque. Chaque banque est organisée du terme le plus connu au plus
/// spécifique. Les surcharges permettent de remonter les références
/// emblématiques qui seraient naturellement placées plus loin dans une liste.
enum MoteurDifficulte {
    static func poidsParOrdreDeNotoriete(
        _ mots: [String],
        surcharges: [String: Int] = [:]
    ) -> [String: Int] {
        var uniques: [String] = []
        var dejaAjoutes = Set<String>()

        for mot in mots {
            let normalise = mot.uppercased()
            guard dejaAjoutes.insert(normalise).inserted else { continue }
            uniques.append(normalise)
        }

        guard !uniques.isEmpty else { return [:] }

        let denominateur = max(uniques.count - 1, 1)
        return Dictionary(uniqueKeysWithValues: uniques.enumerated().map { index, mot in
            let poidsEditorial = 100 - Int((Double(index) / Double(denominateur) * 99).rounded())
            let poids = surcharges[mot] ?? poidsEditorial
            return (mot, min(max(poids, 1), 100))
        })
    }
}

enum ModeJeu: String, CaseIterable, Codable, Hashable, Identifiable {
    case progression
    case tournoi
    case survie
    case duo

    static var modesSolo: [ModeJeu] {
        [.progression, .tournoi, .survie]
    }

    var id: String { rawValue }

    var titre: String {
        switch self {
        case .progression: return "Progression"
        case .tournoi: return "Tournoi"
        case .survie: return "Le plus loin possible"
        case .duo: return "2 joueurs"
        }
    }

    var sousTitre: String {
        switch self {
        case .progression: return "Monte de niveau automatiquement"
        case .tournoi: return "Cinq manches, un score final"
        case .survie: return "Encaisse ou tente le multiplicateur suivant"
        case .duo: return "Un mot secret à deviner"
        }
    }

    var icone: String {
        switch self {
        case .progression: return "chart.line.uptrend.xyaxis"
        case .tournoi: return "trophy.fill"
        case .survie: return "flame.fill"
        case .duo: return "person.2.fill"
        }
    }

}

struct ProfilSauvegarde: Identifiable, Codable, Equatable {
    let id: UUID
    var nom: String
    var niveauxParTheme: [String: NiveauJeu]
    var experiencesParTheme: [String: Int]
    var partiesJouees: Int
    var victoires: Int
    var scoreTotal: Int
    var meilleurScore: Int
    var meilleurScoreSurvie: Int
    var tournoisJoues: Int
    var tournoisGagnes: Int
    var motsTrouvesParTheme: [String: Set<String>]

    init(id: UUID = UUID(), nom: String) {
        self.id = id
        self.nom = nom
        self.niveauxParTheme = [:]
        self.experiencesParTheme = [:]
        self.partiesJouees = 0
        self.victoires = 0
        self.scoreTotal = 0
        self.meilleurScore = 0
        self.meilleurScoreSurvie = 0
        self.tournoisJoues = 0
        self.tournoisGagnes = 0
        self.motsTrouvesParTheme = [:]
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case nom
        case niveauxParTheme
        case experiencesParTheme
        case partiesJouees
        case victoires
        case scoreTotal
        case meilleurScore
        case meilleurScoreSurvie
        case tournoisJoues
        case tournoisGagnes
        case motsTrouvesParTheme
    }

    /// Les profils créés avec l'ancien niveau global restent lisibles. Comme
    /// leurs victoires n'étaient pas rattachées à un thème, leur progression
    /// thématique démarre proprement au niveau Débutant.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        nom = try container.decode(String.self, forKey: .nom)
        niveauxParTheme = try container.decodeIfPresent(
            [String: NiveauJeu].self,
            forKey: .niveauxParTheme
        ) ?? [:]
        experiencesParTheme = try container.decodeIfPresent(
            [String: Int].self,
            forKey: .experiencesParTheme
        ) ?? [:]
        partiesJouees = try container.decode(Int.self, forKey: .partiesJouees)
        victoires = try container.decode(Int.self, forKey: .victoires)
        scoreTotal = try container.decode(Int.self, forKey: .scoreTotal)
        meilleurScore = try container.decode(Int.self, forKey: .meilleurScore)
        meilleurScoreSurvie = try container.decode(Int.self, forKey: .meilleurScoreSurvie)
        tournoisJoues = try container.decode(Int.self, forKey: .tournoisJoues)
        tournoisGagnes = try container.decode(Int.self, forKey: .tournoisGagnes)
        motsTrouvesParTheme = try container.decodeIfPresent(
            [String: Set<String>].self,
            forKey: .motsTrouvesParTheme
        ) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nom, forKey: .nom)
        try container.encode(niveauxParTheme, forKey: .niveauxParTheme)
        try container.encode(experiencesParTheme, forKey: .experiencesParTheme)
        try container.encode(partiesJouees, forKey: .partiesJouees)
        try container.encode(victoires, forKey: .victoires)
        try container.encode(scoreTotal, forKey: .scoreTotal)
        try container.encode(meilleurScore, forKey: .meilleurScore)
        try container.encode(meilleurScoreSurvie, forKey: .meilleurScoreSurvie)
        try container.encode(tournoisJoues, forKey: .tournoisJoues)
        try container.encode(tournoisGagnes, forKey: .tournoisGagnes)
        try container.encode(motsTrouvesParTheme, forKey: .motsTrouvesParTheme)
    }

    func motsTrouves(cle: String) -> Set<String> {
        motsTrouvesParTheme[cle] ?? []
    }

    func progressionMots(cle: String, mots: [String]) -> Int {
        Set(mots).intersection(motsTrouves(cle: cle)).count
    }

    func progression(cle: String, mots: [String]) -> Double {
        let motsUniques = Set(mots)
        guard !motsUniques.isEmpty else { return 0 }
        return min(1, Double(progressionMots(cle: cle, mots: mots)) / Double(motsUniques.count))
    }

    /// Chaque clé de progression possède son propre niveau et sa propre
    /// expérience. Une nouvelle clé commence toujours au niveau Débutant.
    func niveauPourTheme(cle: String) -> NiveauJeu {
        niveauxParTheme[cle] ?? .debutant
    }

    func experiencePourTheme(cle: String) -> Int {
        experiencesParTheme[cle] ?? 0
    }

    func experienceAfficheePourTheme(cle: String) -> String {
        let niveauTheme = niveauPourTheme(cle: cle)
        if niveauTheme.estMaximum {
            return "Niveau maximum"
        }
        return "\(experiencePourTheme(cle: cle))/\(niveauTheme.experienceNecessaire) victoires"
    }

    func progressionNiveauPourTheme(cle: String) -> Double {
        let niveauTheme = niveauPourTheme(cle: cle)
        guard !niveauTheme.estMaximum else { return 1 }
        return min(
            1,
            Double(experiencePourTheme(cle: cle)) / Double(niveauTheme.experienceNecessaire)
        )
    }

    /// Enregistre une victoire et ne fait progresser que le thème joué.
    mutating func enregistrerVictoire(score: Int, cle: String) {
        partiesJouees += 1
        victoires += 1
        scoreTotal += score
        meilleurScore = max(meilleurScore, score)

        let niveauTheme = niveauPourTheme(cle: cle)
        guard !niveauTheme.estMaximum else {
            return
        }

        let nouvelleExperience = experiencePourTheme(cle: cle) + 1
        if nouvelleExperience >= niveauTheme.experienceNecessaire,
           let niveauSuivant = NiveauJeu(rawValue: niveauTheme.rawValue + 1) {
            niveauxParTheme[cle] = niveauSuivant
            experiencesParTheme[cle] = 0
        } else {
            niveauxParTheme[cle] = niveauTheme
            experiencesParTheme[cle] = nouvelleExperience
        }
    }

    mutating func enregistrerDefaite() {
        partiesJouees += 1
    }

    mutating func enregistrerSurvie(score: Int) {
        meilleurScoreSurvie = max(meilleurScoreSurvie, score)
    }

    mutating func enregistrerTournoi(score: Int, gagne: Bool) {
        tournoisJoues += 1
        tournoisGagnes += gagne ? 1 : 0
        meilleurScore = max(meilleurScore, score)
    }

    mutating func enregistrerMotTrouve(_ mot: String, cle: String) {
        motsTrouvesParTheme[cle, default: []].insert(mot.uppercased())
    }
}

/// Gestionnaire unique des profils : chaque profil conserve sa progression.
final class GestionnaireProfils: ObservableObject {
    @Published private(set) var profils: [ProfilSauvegarde]
    @Published private(set) var profilActifID: UUID

    private let defaults: UserDefaults
    private let cleSauvegarde = "tusmo.profils.v1"

    private struct DonneesSauvegardees: Codable {
        var profils: [ProfilSauvegarde]
        var profilActifID: UUID
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let donnees = defaults.data(forKey: cleSauvegarde),
           let sauvegarde = try? JSONDecoder().decode(DonneesSauvegardees.self, from: donnees),
           !sauvegarde.profils.isEmpty {
            profils = sauvegarde.profils
            profilActifID = sauvegarde.profils.contains { $0.id == sauvegarde.profilActifID }
                ? sauvegarde.profilActifID
                : sauvegarde.profils[0].id
        } else {
            let profil = ProfilSauvegarde(nom: "Joueur 1")
            profils = [profil]
            profilActifID = profil.id
            sauvegarder()
        }
    }

    var profilActif: ProfilSauvegarde {
        profils.first { $0.id == profilActifID } ?? profils[0]
    }

    func selectionnerProfil(_ id: UUID) {
        guard profils.contains(where: { $0.id == id }) else { return }
        profilActifID = id
        sauvegarder()
    }

    func motsTrouves(cle: String) -> Set<String> {
        profilActif.motsTrouves(cle: cle)
    }

    func niveauPourTheme(cle: String) -> NiveauJeu {
        profilActif.niveauPourTheme(cle: cle)
    }

    func experiencePourTheme(cle: String) -> Int {
        profilActif.experiencePourTheme(cle: cle)
    }

    func experienceAfficheePourTheme(cle: String) -> String {
        profilActif.experienceAfficheePourTheme(cle: cle)
    }

    func progressionNiveauPourTheme(cle: String) -> Double {
        profilActif.progressionNiveauPourTheme(cle: cle)
    }

    func progressionTheme(_ theme: Theme) -> Double {
        if theme.estPokemon {
            let total = GenerationPokemon.totalMots
            guard total > 0 else { return 0 }
            let trouves = GenerationPokemon.allCases.reduce(0) {
                $0 + profilActif.progressionMots(cle: $1.cleProgression, mots: $1.mots)
            }
            return min(1, Double(trouves) / Double(total))
        }
        return profilActif.progression(cle: theme.cleProgression, mots: theme.mots)
    }

    func estThemeComplet(_ theme: Theme) -> Bool {
        progressionTheme(theme) >= 1
    }

    func progressionGeneration(_ generation: GenerationPokemon) -> Double {
        profilActif.progression(cle: generation.cleProgression, mots: generation.mots)
    }

    func estGenerationComplete(_ generation: GenerationPokemon) -> Bool {
        progressionGeneration(generation) >= 1
    }

    func enregistrerMotTrouve(_ mot: String, cle: String) {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerMotTrouve(mot, cle: cle)
        sauvegarder()
    }

    @discardableResult
    func creerProfil(nom: String) -> UUID? {
        let nomNettoye = nom.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nomNettoye.isEmpty else { return nil }

        let profil = ProfilSauvegarde(nom: nomNettoye)
        profils.append(profil)
        profilActifID = profil.id
        sauvegarder()
        return profil.id
    }

    func supprimerProfil(_ id: UUID) {
        guard profils.count > 1,
              let index = profils.firstIndex(where: { $0.id == id }) else { return }

        profils.remove(at: index)
        if profilActifID == id {
            profilActifID = profils[max(0, index - 1)].id
        }
        sauvegarder()
    }

    func enregistrerVictoire(score: Int, cle: String) {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerVictoire(score: score, cle: cle)
        sauvegarder()
    }

    func enregistrerDefaite() {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerDefaite()
        sauvegarder()
    }

    func enregistrerSurvie(score: Int) {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerSurvie(score: score)
        sauvegarder()
    }

    func enregistrerTournoi(score: Int, gagne: Bool) {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerTournoi(score: score, gagne: gagne)
        sauvegarder()
    }

    private var indexProfilActif: Int? {
        profils.firstIndex { $0.id == profilActifID }
    }

    private func sauvegarder() {
        let donnees = DonneesSauvegardees(profils: profils, profilActifID: profilActifID)
        guard let data = try? JSONEncoder().encode(donnees) else { return }
        defaults.set(data, forKey: cleSauvegarde)
    }
}
