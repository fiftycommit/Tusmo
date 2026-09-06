//
//  ContentView.swift
//  Tusmo
//
//  Created by Max M'bey on 06/03/2023.
//

import SwiftUI
import Foundation

// MARK: - Modèles

enum EtatLettre: Equatable {
    case bonnePlace
    case mauvaisePlace
    case absent

    var description: String {
        switch self {
        case .bonnePlace: return "Bien placée"
        case .mauvaisePlace: return "Mal placée"
        case .absent: return "Absente"
        }
    }
}

struct LettreTuile: Identifiable {
    let id = UUID()
    let lettre: String
    let etat: EtatLettre

    var couleur: Color {
        switch etat {
        case .bonnePlace: return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .mauvaisePlace: return Color(red: 0.9, green: 0.7, blue: 0.1)
        case .absent: return .black
        }
    }

    var texteCouleur: Color {
        switch etat {
        case .bonnePlace: return .white
        case .mauvaisePlace: return .black
        case .absent: return Color.white.opacity(0.45)
        }
    }

    /// Contour discret pour que les cases noires restent lisibles sur le fond sombre.
    var bordureCouleur: Color {
        etat == .absent ? Color.white.opacity(0.15) : .clear
    }
}

enum EtatJeu {
    case enCours
    case gagne(essais: Int)
    case perdu(mot: String)
    case survieEncaissee(score: Int)
    case surviePerdue(mot: String, score: Int)
    case tournoiTermine(score: Int, gagne: Bool)
    case themeTermine
}

// MARK: - Écran principal (Navigation)

struct ContentView: View {
    @StateObject private var gestionnaireProfils = GestionnaireProfils()
    @StateObject private var selectionsSousThemes = SelectionSousThemes()

    var body: some View {
        NavigationStack {
            MenuView()
        }
        .environmentObject(gestionnaireProfils)
        .environmentObject(selectionsSousThemes)
    }
}

// MARK: - Fond commun

private let fondJeu = Color(red: 0.06, green: 0.06, blue: 0.1)

private func pourcentage(_ progression: Double) -> Int {
    Int((progression * 100).rounded())
}

// MARK: - Menu (choix du mode)

struct MenuView: View {
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                LogoTusmo()

                NavigationLink {
                    ProfilsView()
                } label: {
                    HStack(spacing: 12) {
                        Text("🎯")
                            .font(.title2)
                            .frame(width: 42, height: 42)
                            .background(
                                Circle()
                                    .fill(Color.yellow.opacity(0.15))
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(gestionnaireProfils.profilActif.nom)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Progression par thème")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.55))
                        }

                        Spacer()

                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                    )
                }
                .padding(.horizontal, 28)

                Spacer()

                VStack(spacing: 14) {
                    NavigationLink {
                        ChoixModeView()
                    } label: {
                        carteMode(
                            titre: "Solo",
                            sousTitre: "Progression, tournoi ou survie",
                            icone: "person.fill",
                            couleur: .red
                        )
                    }

                    NavigationLink {
                        DuoView()
                    } label: {
                        carteMode(
                            titre: "2 joueurs",
                            sousTitre: "Un joueur écrit le mot, l'autre devine",
                            icone: "person.2.fill",
                            couleur: .yellow
                        )
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                ReglesRapides()
            }
        }
        .navigationBarHidden(true)
    }

    private func carteMode(titre: String, sousTitre: String, icone: String, couleur: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icone)
                .font(.title2)
                .foregroundColor(couleur)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(couleur.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(sousTitre)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Éléments partagés

struct LogoTusmo: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(Array("TUSMO".enumerated()), id: \.offset) { i, c in
                    Text(String(c))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill([Color.red, .yellow, .red, .yellow, .red][i])
                        )
                }
            }

            Text("Le jeu de mots")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 4)
        }
    }
}

struct ReglesRapides: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("🔴 Bonne lettre, bon endroit")
            Text("🟡 Bonne lettre, mauvais endroit")
            Text("⚫ Lettre absente")
        }
        .font(.caption)
        .foregroundColor(.white.opacity(0.6))
        .padding(.bottom, 30)
    }
}

struct EnteteSecondaire: View {
    let titre: String
    let actionRetour: () -> Void

    var body: some View {
        HStack {
            Button(action: actionRetour) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Text(titre)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "chevron.left")
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

private func couleurMode(_ mode: ModeJeu) -> Color {
    switch mode {
    case .progression: return .red
    case .tournoi: return .yellow
    case .survie: return .orange
    case .duo: return .yellow
    }
}

// MARK: - Profils de sauvegarde

struct ProfilsView: View {
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils
    @Environment(\.dismiss) private var dismiss
    @State private var nouveauNom = ""

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 20) {
                EnteteSecondaire(titre: "Profils", actionRetour: { dismiss() })

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(gestionnaireProfils.profils) { profil in
                            HStack(spacing: 14) {
                                Button {
                                    gestionnaireProfils.selectionnerProfil(profil.id)
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: profil.id == gestionnaireProfils.profilActifID ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(profil.id == gestionnaireProfils.profilActifID ? .red : .white.opacity(0.25))
                                            .font(.title3)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(profil.nom)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("\(profil.victoires) victoire\(profil.victoires > 1 ? "s" : "") · niveaux par thème")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.55))
                                        }

                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)

                                if gestionnaireProfils.profils.count > 1 {
                                    Button(role: .destructive) {
                                        gestionnaireProfils.supprimerProfil(profil.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.white.opacity(0.35))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.06))
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Nouveau profil")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.7))

                            HStack(spacing: 10) {
                                TextField("Prénom ou pseudo", text: $nouveauNom)
                                    .padding(14)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .environment(\.colorScheme, .light)

                                Button {
                                    if gestionnaireProfils.creerProfil(nom: nouveauNom) != nil {
                                        nouveauNom = ""
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(nouveauNom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red.opacity(0.3) : Color.red)
                                        )
                                }
                                .disabled(nouveauNom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding(.top, 8)

                        profilDetail(gestionnaireProfils.profilActif)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func profilDetail(_ profil: ProfilSauvegarde) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Progression par thème")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(profil.niveauxParTheme.count) thème\(profil.niveauxParTheme.count > 1 ? "s" : "") commencé\(profil.niveauxParTheme.count > 1 ? "s" : "")")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.yellow)
            }

            Text("Chaque thème possède son propre niveau et sa propre expérience.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.55))

            HStack(spacing: 0) {
                statistique("Parties", valeur: profil.partiesJouees)
                statistique("Victoires", valeur: profil.victoires)
                statistique("Record survie", valeur: profil.meilleurScoreSurvie)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func statistique(_ titre: String, valeur: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(valeur)")
                .font(.headline)
                .foregroundColor(.white)
            Text(titre)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Solo : choix du mode

struct ChoixModeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 20) {
                EnteteSecondaire(titre: "Mode solo", actionRetour: { dismiss() })

                HStack(spacing: 10) {
                    Text("🎯")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Difficulté indépendante par thème")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Apple peut être Maître, tandis que Simpsons reste Débutant")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.red.opacity(0.12))
                )
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(ModeJeu.modesSolo) { mode in
                            NavigationLink {
                                ChoixThemeView(mode: mode)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: mode.icone)
                                        .font(.title2)
                                        .foregroundColor(couleurMode(mode))
                                        .frame(width: 46, height: 46)
                                        .background(
                                            RoundedRectangle(cornerRadius: 13)
                                                .fill(couleurMode(mode).opacity(0.15))
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(mode.titre)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(mode.sousTitre)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.52))
                                            .multilineTextAlignment(.leading)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.06))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Solo : choix du thème

private struct VueThemeTermine: View {
    let titre: String
    let emoji: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 56))
                Text("Thème terminé")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                Text("100 % de \(titre) a été découvert.")
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                Button("Retour") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(32)
        }
        .navigationBarHidden(true)
    }
}

struct ChoixThemeView: View {
    let mode: ModeJeu
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils

    private let colonnes = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    init(mode: ModeJeu = .progression) {
        self.mode = mode
    }

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Choisis un thème")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView {
                    LazyVGrid(columns: colonnes, spacing: 12) {
                        ForEach(BanqueDeMots.tous) { theme in
                            if gestionnaireProfils.estThemeComplet(theme) {
                                carteTheme(theme)
                                    .opacity(0.55)
                                    .overlay(alignment: .topTrailing) {
                                        Text("Terminé")
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color.green.opacity(0.14)))
                                            .padding(8)
                                    }
                            } else {
                                NavigationLink {
                                    destinationPourTheme(theme)
                                } label: {
                                    carteTheme(theme)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func destinationPourTheme(_ theme: Theme) -> some View {
        if theme.estPokemon {
            ChoixGenerationPokemonView(theme: theme, mode: mode)
        } else if theme.possedeSousThemes {
            ChoixSousThemeView(theme: theme, mode: mode)
        } else {
            PartieThemeView(theme: theme, mode: mode, filtre: .aleatoire)
        }
    }

    private func carteTheme(_ theme: Theme) -> some View {
        let progression = gestionnaireProfils.progressionTheme(theme)
        let niveau = gestionnaireProfils.niveauPourTheme(
            cle: theme.cleProgression,
            progression: progression
        )

        return VStack(spacing: 8) {
            Text(theme.emoji)
                .font(.system(size: 32))
            Text(theme.nom)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            Text(theme.estPokemon
                 ? "\(GenerationPokemon.totalMots) Pokémon · 9 générations"
                 : "\(theme.mots.count) mots")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
            if theme.estPokemon {
                Text("Niveau indépendant par génération")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.yellow.opacity(0.8))
            } else {
                Text("\(niveau.emoji) Niveau \(niveau.rawValue) · \(niveau.nom)")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.red.opacity(0.9))
            }
            ProgressView(value: progression)
                .tint(theme.estPokemon ? .yellow : .red)
            Text("\(pourcentage(progression)) % découvert")
                .font(.caption2.weight(.semibold))
                .foregroundColor(progression >= 1 ? .green : .white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Choix générique du sous-thème

struct ChoixSousThemeView: View {
    let theme: Theme
    let mode: ModeJeu

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils
    @EnvironmentObject private var selectionsSousThemes: SelectionSousThemes
    @State private var filtreALancer = FiltreSousTheme.aleatoire
    @State private var naviguer = false

    private var filtreActuel: FiltreSousTheme {
        selectionsSousThemes.filtrePour(theme)
    }

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 18) {
                EnteteSecondaire(titre: theme.nom, actionRetour: { dismiss() })

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Text(theme.emoji)
                            .font(.title2)
                        Text("Choisis une catégorie")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Text("Le niveau et la progression restent ceux de \(theme.nom).")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    Text("Sélection actuelle : \(theme.libellePour(filtreActuel))")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.red.opacity(0.9))
                }
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 10) {
                        carteFiltre(.aleatoire, nom: nomFiltreAleatoire, emoji: "🎲")

                        ForEach(theme.sousThemes) { sousTheme in
                            carteFiltre(
                                .sousTheme(sousTheme.id),
                                nom: sousTheme.nom,
                                emoji: sousTheme.emoji ?? "🔹"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $naviguer) {
            PartieThemeView(theme: theme, mode: mode, filtre: filtreALancer)
        }
    }

    private var nomFiltreAleatoire: String {
        switch theme.nom {
        case "Pays": return "Tous les continents"
        case "Villes": return "Toutes les villes"
        default: return "Aléatoire"
        }
    }

    private func nombreMots(_ filtre: FiltreSousTheme) -> (restants: Int, total: Int) {
        let mots = theme.motsPour(filtre)
        let trouves = gestionnaireProfils.motsTrouves(cle: theme.cleProgression)
        return (
            mots.filter { !trouves.contains($0) }.count,
            Set(mots).count
        )
    }

    @ViewBuilder
    private func carteFiltre(
        _ filtre: FiltreSousTheme,
        nom: String,
        emoji: String
    ) -> some View {
        let compte = nombreMots(filtre)
        let termine = compte.total > 0 && compte.restants == 0

        Button {
            guard !termine || filtre == .aleatoire else { return }
            selectionsSousThemes.choisir(filtre, pour: theme)
            filtreALancer = filtre
            naviguer = true
        } label: {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.white.opacity(0.08)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(nom)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(termine
                         ? "✅ Sous-thème terminé"
                         : "\(compte.restants) mot\(compte.restants > 1 ? "s" : "") disponible\(compte.restants > 1 ? "s" : "") · \(compte.total) au total")
                        .font(.caption)
                        .foregroundColor(termine ? .green.opacity(0.85) : .white.opacity(0.5))
                }

                Spacer()
                if !termine || filtre == .aleatoire {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(filtre == filtreActuel ? Color.red.opacity(0.16) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(filtre == filtreActuel ? Color.red.opacity(0.55) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(termine && filtre != .aleatoire ? 0.55 : 1)
        .disabled(termine && filtre != .aleatoire)
    }
}

/// Prépare le premier mot d'une partie après l'application du filtre.
struct PartieThemeView: View {
    let theme: Theme
    let mode: ModeJeu
    let filtre: FiltreSousTheme

    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils

    var body: some View {
        let niveau = gestionnaireProfils.niveauPourTheme(
            cle: theme.cleProgression,
            progression: gestionnaireProfils.progressionTheme(theme)
        )
        let exclus = gestionnaireProfils.motsTrouves(cle: theme.cleProgression)

        if let motSecret = theme.motAleatoireNonTrouve(
            niveau: niveau,
            exclus: exclus,
            filtre: filtre
        ) {
            JeuView(
                motSecret: motSecret,
                theme: theme,
                mode: mode,
                niveau: niveau,
                filtreSousTheme: filtre
            )
        } else if case .sousTheme(let identifiant) = filtre,
                  let sousTheme = theme.sousTheme(identifiant) {
            VueSousThemeTermine(theme: theme, mode: mode, sousTheme: sousTheme)
        } else {
            VueThemeTermine(titre: theme.nom, emoji: theme.emoji)
        }
    }
}

struct VueSousThemeTermine: View {
    let theme: Theme
    let mode: ModeJeu
    let sousTheme: SousTheme

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var selectionsSousThemes: SelectionSousThemes
    @State private var lancerTous = false

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 18) {
                Text("✅")
                    .font(.system(size: 54))
                Text("Sous-thème terminé")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text("Tous les mots de « \(sousTheme.nom) » ont été découverts.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.65))

                Button {
                    selectionsSousThemes.choisir(.aleatoire, pour: theme)
                    lancerTous = true
                } label: {
                    Text(theme.nom == "Pays" ? "Jouer tous les pays" : "Jouer toute la banque")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.red))
                }

                Button("Changer de sous-thème") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.7))
            }
            .padding(28)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $lancerTous) {
            PartieThemeView(theme: theme, mode: mode, filtre: .aleatoire)
        }
    }
}

// MARK: - Pokémon : choix de la génération

struct ChoixGenerationPokemonView: View {
    let theme: Theme
    let mode: ModeJeu

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 20) {
                EnteteSecondaire(titre: "Choisis une génération", actionRetour: { dismiss() })

                HStack(spacing: 10) {
                    Text("⚡️")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pokémon · niveau indépendant par génération")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Chaque génération conserve sa propre progression")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.yellow.opacity(0.12))
                )
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(GenerationPokemon.allCases) { generation in
                            if gestionnaireProfils.estGenerationComplete(generation) {
                                HStack(spacing: 14) {
                                    Text("G\(generation.rawValue)")
                                        .font(.headline.monospaced())
                                        .foregroundColor(.black)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            Circle()
                                                .fill(Color.yellow)
                                        )

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(generation.titre)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("\(generation.region) · \(generation.mots.count) Pokémon · 100 %")
                                            .font(.caption)
                                            .foregroundColor(.green.opacity(0.8))
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.06))
                                )
                                .opacity(0.55)
                                .overlay(alignment: .topTrailing) {
                                    Text("Terminé")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.green.opacity(0.14)))
                                        .padding(8)
                                }
                            } else {
                                NavigationLink {
                                    jeuPourGeneration(generation)
                                } label: {
                                    carteGeneration(generation)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func jeuPourGeneration(_ generation: GenerationPokemon) -> some View {
        let niveau = gestionnaireProfils.niveauPourTheme(
            cle: generation.cleProgression,
            progression: gestionnaireProfils.progressionGeneration(generation)
        )
        let exclus = gestionnaireProfils.motsTrouves(cle: generation.cleProgression)
        if let motSecret = generation.motAleatoireNonTrouve(
            niveau: niveau,
            exclus: exclus
        ) {
            JeuView(
                motSecret: motSecret,
                theme: theme,
                generationPokemon: generation,
                mode: mode,
                niveau: niveau
            )
        } else {
            VueThemeTermine(titre: "Pokémon · \(generation.titre)", emoji: "⚡️")
        }
    }

    private func carteGeneration(_ generation: GenerationPokemon) -> some View {
        let progression = gestionnaireProfils.progressionGeneration(generation)
        let niveau = gestionnaireProfils.niveauPourTheme(
            cle: generation.cleProgression,
            progression: progression
        )

        return HStack(spacing: 14) {
            Text("G\(generation.rawValue)")
                .font(.headline.monospaced())
                .foregroundColor(.black)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(Color.yellow)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(generation.titre)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(generation.region) · \(generation.mots.count) Pokémon")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text("\(niveau.emoji) Niveau \(niveau.rawValue) · \(niveau.nom)")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.yellow.opacity(0.85))
                ProgressView(value: progression)
                    .tint(.yellow)
                Text("\(pourcentage(progression)) % découvert")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - 2 joueurs : saisie du mot secret

struct DuoView: View {
    @State private var mot = ""
    @State private var motValide = false
    @State private var naviguer = false
    @State private var motVisible = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 32) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                LogoTusmo()

                Spacer()

                // Saisie du mot secret
                VStack(alignment: .leading, spacing: 10) {
                    Label("Joueur 1 — Mot secret", systemImage: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)

                    HStack(spacing: 0) {
                        Group {
                            if motVisible {
                                TextField("Entre un mot secret", text: $mot)
                            } else {
                                SecureField("Entre un mot secret", text: $mot)
                            }
                        }
                        .font(.title3)
                        .submitLabel(.send)
                        .onSubmit {
                            if motValide { naviguer = true }
                        }

                        Button {
                            motVisible.toggle()
                        } label: {
                            Image(systemName: motVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .font(.body)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .environment(\.colorScheme, .light)
                    .onChange(of: mot) { _ in
                        if mot.count > 9 {
                            mot = String(mot.prefix(9))
                        }
                        motValide = mot.count >= 3 && mot.allSatisfy(\.isLetter)
                    }
                }
                .padding(.horizontal, 28)

                // Bouton lancer
                Button {
                    naviguer = true
                } label: {
                    Text("C'est parti")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(motValide ? Color.red : Color.red.opacity(0.3))
                        )
                }
                .disabled(!motValide)
                .padding(.horizontal, 28)
                .navigationDestination(isPresented: $naviguer) {
                    JeuView(motSecret: mot.uppercased())
                }

                Spacer()

                ReglesRapides()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            mot = ""
            motValide = false
            motVisible = false
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Écran de jeu

struct JeuView: View {
    /// Thème du mode solo ; `nil` en mode 2 joueurs.
    let theme: Theme?
    let generationPokemon: GenerationPokemon?
    let filtreSousTheme: FiltreSousTheme?
    let mode: ModeJeu
    let niveauInitial: NiveauJeu

    @EnvironmentObject private var gestionnaireProfils: GestionnaireProfils
    @State private var motSecret: String
    @State private var niveauActuel: NiveauJeu
    @State private var proposition = ""
    @State private var historique: [[LettreTuile]] = []
    @State private var essai = 0
    @State private var etat: EtatJeu = .enCours
    @State private var tuileSelectionnee: EtatLettre?
    @State private var scoreTournoi = 0
    @State private var mancheTournoi = 1
    @State private var scoreSurvie = 0
    @State private var multiplicateurSurvie = 1.0
    @State private var dernierScore = 0
    @Environment(\.dismiss) private var dismiss

    private let nombreManchesTournoi = 5

    init(
        motSecret: String,
        theme: Theme? = nil,
        generationPokemon: GenerationPokemon? = nil,
        mode: ModeJeu = .duo,
        niveau: NiveauJeu = .debutant,
        filtreSousTheme: FiltreSousTheme? = nil
    ) {
        _motSecret = State(initialValue: motSecret.uppercased())
        _niveauActuel = State(initialValue: niveau)
        self.theme = theme
        self.generationPokemon = generationPokemon
        self.filtreSousTheme = filtreSousTheme
        self.mode = mode
        self.niveauInitial = niveau
    }

    var body: some View {
        ZStack {
            fondJeu.ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        if mode != .duo {
                            Text("\(mode == .tournoi ? "🏆" : mode == .survie ? "🔥" : "📈") \(mode.titre)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                        }
                        Text(sourceTitre)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        if let theme, theme.possedeSousThemes, let filtreSousTheme {
                            Text(theme.libellePour(filtreSousTheme))
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.red.opacity(0.85))
                        }
                        Text("\(nbLettres) lettres · niveau \(niveauActuel.rawValue)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        if let difficulteMot {
                            HStack(spacing: 4) {
                                Text(difficulteMot.emoji)
                                Text(difficulteMot.nom)
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundColor(couleurDifficulteMot)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(couleurDifficulteMot.opacity(0.16))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(couleurDifficulteMot.opacity(0.45), lineWidth: 1)
                            )
                            .accessibilityLabel("Difficulté du mot : \(difficulteMot.nom)")
                        }

                        HStack(spacing: 4) {
                            ForEach(0..<maxEssais, id: \.self) { i in
                                Circle()
                                    .fill(i < (maxEssais - essai) ? Color.red : Color.white.opacity(0.12))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        if mode == .tournoi {
                            Text("Manche \(mancheTournoi)/\(nombreManchesTournoi)")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.yellow)
                        } else if mode == .survie {
                            Text("×\(String(format: "%.1f", multiplicateurSurvie)) · \(scoreSurvie) pts")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Grille complète (comme au vrai Motus)
                VStack(spacing: 6) {
                    ForEach(0..<maxEssais, id: \.self) { ligne in
                        HStack(spacing: 5) {
                            ForEach(0..<nbLettres, id: \.self) { colonne in
                                caseGrille(ligne: ligne, colonne: colonne)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)

                // Bulle d'info
                if let etatTuile = tuileSelectionnee {
                    Text(etatTuile.description)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.85))
                        )
                        .transition(.opacity)
                }

                Spacer()

                // Zone de saisie
                if case .enCours = etat {
                    VStack(spacing: 12) {
                        TextField("Devine le mot", text: $proposition)
                            .onChange(of: proposition) { _ in normaliserProposition() }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .font(.system(.title3, design: .monospaced))
                            .environment(\.colorScheme, .light)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onSubmit { proposer() }

                        if proposition.count > 1 && proposition.count != nbLettres {
                            Text("Il faut \(nbLettres) lettres (tu en as \(proposition.count))")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }

                        Button {
                            proposer()
                        } label: {
                            Text("Proposer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(propositionValide ? Color.red : Color.red.opacity(0.3))
                                )
                        }
                        .disabled(!propositionValide)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }

            // Overlay victoire / défaite / choix de risque
            switch etat {
            case .enCours:
                EmptyView()
            case .gagne(let nbEssais):
                overlayResultat {
                    contenuVictoire(essais: nbEssais)
                }
            case .perdu(let solution):
                overlayResultat {
                    contenuDefaite(solution: solution)
                }
            case .survieEncaissee(let score):
                overlayResultat {
                    contenuSurvieEncaissee(score: score)
                }
            case .surviePerdue(let solution, let score):
                overlayResultat {
                    contenuSurviePerdue(solution: solution, score: score)
                }
            case .tournoiTermine(let score, let gagne):
                overlayResultat {
                    contenuTournoiTermine(score: score, gagne: gagne)
                }
            case .themeTermine:
                overlayResultat {
                    contenuThemeTermine
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if proposition.isEmpty { proposition = premiereLettre }
        }
        .onTapGesture {
            if tuileSelectionnee != nil {
                withAnimation(.easeInOut(duration: 0.15)) {
                    tuileSelectionnee = nil
                }
            }
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Résultats et choix de mode

    @ViewBuilder
    private func contenuVictoire(essais: Int) -> some View {
        VStack(spacing: 16) {
            if mode == .survie {
                Text("🔥")
                    .font(.system(size: 56))
                Text("Mot trouvé !")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("En risque : \(scoreSurvie) points")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.orange)
                if let adaptationVictoireTexte = adaptationVictoireTexte {
                    Text(adaptationVictoireTexte)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                Text("Tu encaisses maintenant, ou tu tentes le multiplicateur suivant.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)

                Button {
                    continuerSurvie()
                } label: {
                    Label("Continuer · \(multiplicateurSuivantTexte)", systemImage: "flame.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.orange)
                        )
                }

                Button {
                    encaisserSurvie()
                } label: {
                    Label("Arrêter et encaisser", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
            } else if mode == .tournoi {
                Text("🏆")
                    .font(.system(size: 56))
                Text("Manche réussie !")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("+\(dernierScore) points · total \(scoreTournoi)")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.yellow)
                if let adaptationVictoireTexte = adaptationVictoireTexte {
                    Text(adaptationVictoireTexte)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green.opacity(0.9))
                }
                Button {
                    continuerTournoi()
                } label: {
                    Label("Manche suivante", systemImage: "arrow.right")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.yellow.opacity(0.85))
                        )
                }
            } else if mode == .progression {
                contenuProgressionVictoire(essais: essais)
            } else {
                Text("🎉")
                    .font(.system(size: 60))
                Text("Bravo !")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Trouvé en \(essais) essai\(essais > 1 ? "s" : "") !")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                if let adaptationVictoireTexte = adaptationVictoireTexte {
                    Text(adaptationVictoireTexte)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green.opacity(0.9))
                }
                Text("Score : \(dernierScore)")
                    .font(.headline)
                    .foregroundColor(.yellow)

                boutonRejouer
            }
        }
    }

    private func contenuProgressionVictoire(essais: Int) -> some View {
        let niveau = niveauProgression
        let cle = progressionCle ?? ""

        return VStack(spacing: 14) {
            Text("📈")
                .font(.system(size: 50))
            Text("Progression")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Mot trouvé en \(essais) essai\(essais > 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
            if let adaptationVictoireTexte = adaptationVictoireTexte {
                Text(adaptationVictoireTexte)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.green.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(niveau.emoji) Niveau \(niveau.rawValue) · \(niveau.nom)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(gestionnaireProfils.experienceAfficheePourTheme(cle: cle))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                ProgressView(value: gestionnaireProfils.progressionNiveauPourTheme(cle: cle))
                    .tint(.red)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
            )

            if let titre = sourceProgressionTitre,
               let progression = sourceProgression {
                blocProgressionTheme(
                    titre: titre,
                    progression: progression,
                    total: sourceProgressionTotal
                )
            }

            Text("Score : \(dernierScore)")
                .font(.headline)
                .foregroundColor(.yellow)

            if sourceProgressionComplete {
                boutonMenu
            } else {
                boutonRejouer
            }
        }
    }

    private func blocProgressionTheme(
        titre: String,
        progression: Double,
        total: Int
    ) -> some View {
        let trouves = Int((Double(total) * progression).rounded())

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(titre)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(trouves)/\(total)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            ProgressView(value: progression)
                .tint(.green)
            Text("\(pourcentage(progression)) % du thème découvert")
                .font(.caption)
                .foregroundColor(progression >= 1 ? .green : .white.opacity(0.6))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.08))
        )
    }

    @ViewBuilder
    private func contenuDefaite(solution: String) -> some View {
        VStack(spacing: 16) {
            Text(mode == .tournoi ? "🏁" : "😔")
                .font(.system(size: 60))
            Text(mode == .tournoi ? "Tournoi terminé" : "Perdu...")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            if mode == .tournoi {
                Text("Éliminé à la manche \(mancheTournoi)/\(nombreManchesTournoi)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.65))
                Text("Score final : \(scoreTournoi)")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("Le mot était :")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }

            motSolution(solution)
            if mode != .duo, progressionCle != nil {
                Text("Le niveau de ce thème baisse pour le prochain mot.")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.orange.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            boutonRejouer
        }
    }

    private func contenuSurvieEncaissee(score: Int) -> some View {
        VStack(spacing: 16) {
            Text("💰")
                .font(.system(size: 60))
            Text("Points encaissés !")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Tu repars avec \(score) points.")
                .font(.title3)
                .foregroundColor(.orange)
            Text("Record du profil : \(gestionnaireProfils.profilActif.meilleurScoreSurvie) points")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            boutonRejouer
        }
    }

    private func contenuSurviePerdue(solution: String, score: Int) -> some View {
        VStack(spacing: 16) {
            Text("💥")
                .font(.system(size: 60))
            Text("Tout est perdu")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Tu avais \(score) points en jeu.")
                .font(.title3)
                .foregroundColor(.orange)
            Text("Le mot était :")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            motSolution(solution)
            if progressionCle != nil {
                Text("Le niveau de ce thème baisse pour le prochain mot.")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.orange.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            boutonRejouer
        }
    }

    private func contenuTournoiTermine(score: Int, gagne: Bool) -> some View {
        VStack(spacing: 16) {
            Text(gagne ? "🏆" : "🏁")
                .font(.system(size: 60))
            Text(gagne ? "Tournoi gagné !" : "Tournoi terminé")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Score final : \(score)")
                .font(.title3.weight(.semibold))
                .foregroundColor(.yellow)
            Text("\(nombreManchesTournoi) manches · niveau \(niveauActuel.nom)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            boutonRejouer
        }
    }

    private var contenuThemeTermine: some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))
            Text("Thème terminé !")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("100 % des mots disponibles ont été trouvés.")
                .font(.title3.weight(.semibold))
                .foregroundColor(.green)
                .multilineTextAlignment(.center)

            if mode == .survie {
                Text("Score encaissé : \(scoreSurvie) points")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            } else if mode == .tournoi {
                Text("Score actuel : \(scoreTournoi) points")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }

            Text("Choisis un autre thème pour continuer à jouer.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            boutonMenu
        }
    }

    private func motSolution(_ solution: String) -> some View {
        HStack(spacing: 5) {
            ForEach(Array(solution.enumerated()), id: \.offset) { _, c in
                Text(String(c))
                    .font(.system(size: tilleFont, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: tilleSize, height: tilleSize)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                    )
            }
        }
    }

    // MARK: - Grille

    private var maxEssais: Int {
        mode == .duo ? 6 : niveauActuel.nombreEssais
    }

    private var adaptationVictoireTexte: String? {
        guard mode != .duo, progressionCle != nil else { return nil }
        if niveauProgression.estMaximum {
            return "👑 Maître atteint · continue à découvrir le thème"
        }

        if let progression = sourceProgression,
           let niveauSuivant = niveauProgression.niveauSuivant,
           progression + 0.000_001 < niveauSuivant.pourcentageMinimumDecouvert {
            let seuil = pourcentage(niveauSuivant.pourcentageMinimumDecouvert)
            return "🔒 " + String(seuil) + " % du thème pour débloquer " + niveauSuivant.nom
        }

        let seuilRapide = max(1, maxEssais / 2)
        return essai <= seuilRapide
            ? "⚡ Victoire rapide · progression accélérée"
            : "Progression normale pour ce thème"
    }

    private var sourceTitre: String {
        if let generationPokemon {
            return "⚡️ Pokémon · \(generationPokemon.titre)"
        }
        if let theme {
            return "\(theme.emoji) \(theme.nom)"
        }
        return "Mot secret"
    }

    private var progressionCle: String? {
        if let generationPokemon {
            return generationPokemon.cleProgression
        }
        if let theme, !theme.estPokemon {
            return theme.cleProgression
        }
        return nil
    }

    private var sourceProgressionTitre: String? {
        if let generationPokemon {
            return "Pokémon · \(generationPokemon.titre)"
        }
        return theme?.nom
    }

    private var sourceProgression: Double? {
        if let generationPokemon {
            return gestionnaireProfils.progressionGeneration(generationPokemon)
        }
        if let theme {
            return gestionnaireProfils.progressionTheme(theme)
        }
        return nil
    }

    private var sourceProgressionTotal: Int {
        if let generationPokemon {
            return Set(generationPokemon.mots).count
        }
        if let theme {
            return theme.estPokemon ? GenerationPokemon.totalMots : Set(theme.mots).count
        }
        return 0
    }

    private var sourceProgressionComplete: Bool {
        if let generationPokemon {
            return gestionnaireProfils.estGenerationComplete(generationPokemon)
        }
        if let theme {
            return gestionnaireProfils.estThemeComplet(theme)
        }
        return false
    }

    private var niveauProgression: NiveauJeu {
        guard let progressionCle else { return niveauActuel }
        return gestionnaireProfils.niveauPourTheme(
            cle: progressionCle,
            progression: sourceProgression ?? 0
        )
    }

    private var nbLettres: Int { motSecret.count }

    /// Difficulté éditoriale du mot actuel, indépendante du niveau du profil.
    private var difficulteMot: NiveauJeu? {
        if let generationPokemon {
            return generationPokemon.niveauDuMot(motSecret)
        }
        if let theme, !theme.estPokemon {
            return theme.niveauDuMot(motSecret)
        }
        // En mode 2 joueurs, le mot est choisi par l'autre joueur et n'a pas
        // de classement thématique fiable à afficher.
        return nil
    }

    private var couleurDifficulteMot: Color {
        switch difficulteMot {
        case .debutant: return .green
        case .apprenti: return .blue
        case .confirme: return .yellow
        case .expert: return .orange
        case .maitre: return .purple
        case nil: return .white
        }
    }

    private var multiplicateurSuivantTexte: String {
        String(format: "×%.1f", multiplicateurSurvie + 0.5)
    }

    private var premiereLettre: String {
        String(motSecret.prefix(1))
    }

    /// Une case de la grille : historique, ligne en cours de saisie, ou case vide.
    @ViewBuilder
    private func caseGrille(ligne: Int, colonne: Int) -> some View {
        if ligne < historique.count {
            let tuile = historique[ligne][colonne]
            texteTuile(tuile.lettre, couleur: tuile.couleur, texte: tuile.texteCouleur)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(tuile.bordureCouleur, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        tuileSelectionnee = tuileSelectionnee == tuile.etat ? nil : tuile.etat
                    }
                }
        } else if ligne == historique.count, case .enCours = etat {
            let saisie = Array(proposition.uppercased())
            let lettre = colonne < saisie.count ? String(saisie[colonne]) : ""
            texteTuile(lettre, couleur: Color.white.opacity(0.06), texte: .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            colonne == min(saisie.count, nbLettres - 1) ? Color.red : Color.white.opacity(0.2),
                            lineWidth: colonne == min(saisie.count, nbLettres - 1) ? 2 : 1
                        )
                )
        } else {
            // Lignes à venir : seule la première lettre est donnée
            texteTuile(colonne == 0 ? premiereLettre : "", couleur: Color.white.opacity(0.04), texte: .white.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private func texteTuile(_ lettre: String, couleur: Color, texte: Color) -> some View {
        Text(lettre)
            .font(.system(size: tilleFont, weight: .bold, design: .monospaced))
            .foregroundColor(texte)
            .frame(width: tilleSize, height: tilleSize)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(couleur)
            )
    }

    /// Force la saisie en majuscules, commençant par la première lettre offerte,
    /// et limitée à la longueur du mot.
    private func normaliserProposition() {
        var texte = proposition.uppercased().filter(\.isLetter)
        if !texte.hasPrefix(premiereLettre) {
            texte = premiereLettre + texte
        }
        if texte.count > nbLettres {
            texte = String(texte.prefix(nbLettres))
        }
        if texte != proposition {
            proposition = texte
        }
    }

    // MARK: - Dimensions tuiles

    private var tilleSize: CGFloat {
        let count = CGFloat(nbLettres)
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 48
        let spacing: CGFloat = 5
        let available = maxWidth - (count - 1) * spacing
        return min(50, max(30, available / count))
    }

    private var tilleFont: CGFloat {
        tilleSize > 40 ? 22 : 18
    }

    private var propositionValide: Bool {
        proposition.count == nbLettres && proposition.allSatisfy(\.isLetter)
    }

    // MARK: - Logique (inspirée de la version Python)

    private func proposer() {
        guard case .enCours = etat else { return }

        let prop = proposition.uppercased()
        guard prop.count == motSecret.count else { return }

        essai += 1

        if prop == motSecret {
            let tuiles = motSecret.map { LettreTuile(lettre: String($0), etat: .bonnePlace) }
            historique.append(tuiles)
            dernierScore = scorePourVictoire(essais: essai)
            traiterVictoire()
            return
        }

        // Compteur d'occurrences (comme dans motusv2.py)
        var lettres: [Character: Int] = [:]
        for c in motSecret {
            lettres[c, default: 0] += 1
        }

        let motArr = Array(motSecret)
        let propArr = Array(prop)
        var resultats = [LettreTuile?](repeating: nil, count: motSecret.count)

        // Premier passage : lettres bien placées
        for i in 0..<motArr.count {
            if propArr[i] == motArr[i] {
                resultats[i] = LettreTuile(lettre: String(propArr[i]), etat: .bonnePlace)
                lettres[propArr[i]]! -= 1
            }
        }

        // Deuxième passage : lettres mal placées ou absentes
        for i in 0..<motArr.count {
            if resultats[i] == nil {
                let c = propArr[i]
                if lettres[c, default: 0] > 0 {
                    resultats[i] = LettreTuile(lettre: String(c).lowercased(), etat: .mauvaisePlace)
                    lettres[c]! -= 1
                } else {
                    resultats[i] = LettreTuile(lettre: String(c), etat: .absent)
                }
            }
        }

        historique.append(resultats.compactMap { $0 })
        proposition = premiereLettre

        if essai >= maxEssais {
            terminerSurEchec()
        }
    }

    private func scorePourVictoire(essais: Int) -> Int {
        let rapidite = maxEssais - essais + 1
        let base = 50 + nbLettres * 10 + rapidite * 15
        return Int((Double(base) * niveauActuel.multiplicateurScore).rounded())
    }

    private func traiterVictoire() {
        if mode != .duo {
            if let progressionCle {
                gestionnaireProfils.enregistrerMotTrouve(motSecret, cle: progressionCle)
                gestionnaireProfils.enregistrerVictoire(
                    score: dernierScore,
                    cle: progressionCle,
                    essais: essai,
                    maxEssais: maxEssais,
                    progressionTheme: sourceProgression ?? 0
                )
            }
        }

        switch mode {
        case .survie:
            let pointsGagnes = Int((Double(dernierScore) * multiplicateurSurvie).rounded())
            scoreSurvie += pointsGagnes
            etat = .gagne(essais: essai)

        case .tournoi:
            scoreTournoi += dernierScore
            if mancheTournoi == nombreManchesTournoi {
                gestionnaireProfils.enregistrerTournoi(score: scoreTournoi, gagne: true)
                etat = .tournoiTermine(score: scoreTournoi, gagne: true)
            } else {
                etat = .gagne(essais: essai)
            }

        case .progression, .duo:
            etat = .gagne(essais: essai)
        }
    }

    private func terminerSurEchec() {
        if mode == .survie {
            let pointsPerdus = scoreSurvie
            scoreSurvie = 0
            if let progressionCle {
                gestionnaireProfils.enregistrerDefaite(cle: progressionCle)
                niveauActuel = gestionnaireProfils.niveauPourTheme(
                    cle: progressionCle,
                    progression: sourceProgression ?? 0
                )
            }
            etat = .surviePerdue(mot: motSecret, score: pointsPerdus)
            return
        }

        if mode != .duo {
            if let progressionCle {
                gestionnaireProfils.enregistrerDefaite(cle: progressionCle)
                niveauActuel = gestionnaireProfils.niveauPourTheme(
                    cle: progressionCle,
                    progression: sourceProgression ?? 0
                )
            }
        }

        if mode == .tournoi {
            gestionnaireProfils.enregistrerTournoi(score: scoreTournoi, gagne: false)
        }
        etat = .perdu(mot: motSecret)
    }

    private func continuerSurvie() {
        multiplicateurSurvie += 0.5
        commencerMotSuivant()
    }

    private func encaisserSurvie() {
        gestionnaireProfils.enregistrerSurvie(score: scoreSurvie)
        etat = .survieEncaissee(score: scoreSurvie)
    }

    private func continuerTournoi() {
        guard mancheTournoi < nombreManchesTournoi else { return }
        mancheTournoi += 1
        commencerMotSuivant()
    }

    private func commencerMotSuivant() {
        guard theme != nil || generationPokemon != nil else { return }

        if let progressionCle {
            niveauActuel = gestionnaireProfils.niveauPourTheme(
                cle: progressionCle,
                progression: sourceProgression ?? 0
            )
        }

        guard let nouveauMot = motAleatoirePourPartie(sauf: motSecret) else {
            terminerQuandThemeEstComplet()
            return
        }

        motSecret = nouveauMot.uppercased()
        proposition = premiereLettre
        historique = []
        essai = 0
        dernierScore = 0
        tuileSelectionnee = nil
        etat = .enCours
    }

    // MARK: - UI Helpers

    private func overlayResultat<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            VStack {
                content()
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
            )
            .padding(32)
        }
    }

    private var boutonRejouer: some View {
        VStack(spacing: 12) {
            Button {
                resetPartie()
            } label: {
                Label(libelleRejouer, systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.red)
                    )
            }

            Button {
                dismiss()
            } label: {
                Label("Menu", systemImage: "house.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
        }
        .padding(.top, 8)
    }

    private var boutonMenu: some View {
        Button {
            dismiss()
        } label: {
            Label("Choisir un autre thème", systemImage: "square.grid.2x2.fill")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.red)
                )
        }
        .padding(.top, 8)
    }

    private var libelleRejouer: String {
        switch mode {
        case .progression: return "Mot suivant"
        case .tournoi: return "Rejouer le tournoi"
        case .survie: return "Nouvelle tentative"
        case .duo: return "Rejouer"
        }
    }

    private func resetPartie() {
        if mode != .duo {
            if let progressionCle {
                niveauActuel = gestionnaireProfils.niveauPourTheme(
                    cle: progressionCle,
                    progression: sourceProgression ?? 0
                )
            } else {
                niveauActuel = niveauInitial
            }
        } else {
            niveauActuel = niveauInitial
        }

        guard let nouveauMot = motAleatoirePourPartie(sauf: motSecret) else {
            etat = .themeTermine
            return
        }

        motSecret = nouveauMot.uppercased()
        proposition = String(motSecret.prefix(1))
        historique = []
        essai = 0
        scoreTournoi = 0
        mancheTournoi = 1
        scoreSurvie = 0
        multiplicateurSurvie = 1.0
        dernierScore = 0
        tuileSelectionnee = nil
        etat = .enCours
    }

    private func terminerQuandThemeEstComplet() {
        if mode == .survie {
            gestionnaireProfils.enregistrerSurvie(score: scoreSurvie)
        } else if mode == .tournoi {
            gestionnaireProfils.enregistrerTournoi(score: scoreTournoi, gagne: false)
        }
        etat = .themeTermine
    }

    private func motAleatoirePourPartie(sauf: String?) -> String? {
        if mode == .duo {
            return motSecret
        }

        guard let progressionCle else { return nil }
        let exclus = gestionnaireProfils.motsTrouves(cle: progressionCle)

        if let generationPokemon {
            return generationPokemon.motAleatoireNonTrouve(
                niveau: niveauActuel,
                sauf: sauf,
                exclus: exclus
            )
        }
        return theme?.motAleatoireNonTrouve(
            niveau: niveauActuel,
            sauf: sauf,
            exclus: exclus,
            filtre: filtreSousTheme ?? .aleatoire
        )
    }
}
