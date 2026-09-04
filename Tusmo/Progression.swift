//
//  Progression.swift
//  Tusmo
//
//  Progression automatique et profils de sauvegarde de Tusmo.
//

import Foundation
import Combine

enum NiveauJeu: Int, CaseIterable, Codable, Identifiable {
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
        case .debutant: return "Des mots courts pour découvrir le jeu"
        case .apprenti: return "Un peu plus de lettres, le rythme s'accélère"
        case .confirme: return "Les mots deviennent plus longs"
        case .expert: return "Il faut rester concentré"
        case .maitre: return "Le défi ultime"
        }
    }

    /// Les mots disponibles dans la banque sont compris entre 5 et 9 lettres.
    var longueurs: ClosedRange<Int> {
        switch self {
        case .debutant: return 5...5
        case .apprenti: return 5...6
        case .confirme: return 6...7
        case .expert: return 7...8
        case .maitre: return 8...9
        }
    }

    /// Le temps de réflexion se réduit légèrement aux deux derniers niveaux.
    var nombreEssais: Int {
        rawValue >= NiveauJeu.expert.rawValue ? 5 : 6
    }

    /// Les mots longs rapportent davantage dans les modes à score.
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
    var niveau: NiveauJeu
    var experience: Int
    var partiesJouees: Int
    var victoires: Int
    var scoreTotal: Int
    var meilleurScore: Int
    var meilleurScoreSurvie: Int
    var tournoisJoues: Int
    var tournoisGagnes: Int

    init(id: UUID = UUID(), nom: String) {
        self.id = id
        self.nom = nom
        self.niveau = .debutant
        self.experience = 0
        self.partiesJouees = 0
        self.victoires = 0
        self.scoreTotal = 0
        self.meilleurScore = 0
        self.meilleurScoreSurvie = 0
        self.tournoisJoues = 0
        self.tournoisGagnes = 0
    }

    var experienceAffichee: String {
        if niveau.estMaximum {
            return "Niveau maximum"
        }
        return "\(experience)/\(niveau.experienceNecessaire) victoires"
    }

    var progressionNiveau: Double {
        guard !niveau.estMaximum else { return 1 }
        return min(1, Double(experience) / Double(niveau.experienceNecessaire))
    }

    mutating func enregistrerVictoire(score: Int) {
        partiesJouees += 1
        victoires += 1
        scoreTotal += score
        meilleurScore = max(meilleurScore, score)

        guard !niveau.estMaximum else { return }

        experience += 1
        if experience >= niveau.experienceNecessaire,
           let niveauSuivant = NiveauJeu(rawValue: niveau.rawValue + 1) {
            niveau = niveauSuivant
            experience = 0
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

    func enregistrerVictoire(score: Int) {
        guard let index = indexProfilActif else { return }
        profils[index].enregistrerVictoire(score: score)
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
