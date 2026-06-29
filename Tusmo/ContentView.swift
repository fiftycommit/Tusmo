//
//  ContentView.swift
//  Tusmo
//
//  Created by Max M'bey on 06/03/2023.
//

import SwiftUI

// MARK: - Modèles

enum EtatLettre {
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
        case .absent: return Color.white.opacity(0.12)
        }
    }

    var texteCouleur: Color {
        switch etat {
        case .bonnePlace, .absent: return .white
        case .mauvaisePlace: return .black
        }
    }
}

enum EtatJeu {
    case enCours
    case gagne(essais: Int)
    case perdu(mot: String)
}

// MARK: - Écran principal (Navigation)

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MenuView()
        }
    }
}

// MARK: - Menu

struct MenuView: View {
    @State private var mot = ""
    @State private var motValide = false
    @State private var naviguer = false
    @State private var motVisible = false

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo
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
                        motValide = !mot.isEmpty && mot.allSatisfy(\.isLetter)
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

                // Règles rapides
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
    let motSecret: String

    @State private var proposition = ""
    @State private var historique: [[LettreTuile]] = []
    @State private var essai = 0
    @State private var etat: EtatJeu = .enCours
    @State private var tuileSelectionnee: EtatLettre?
    @Environment(\.dismiss) private var dismiss

    private let maxEssais = 6

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("\(motSecret.count) lettres")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    // Essais restants
                    HStack(spacing: 4) {
                        ForEach(0..<maxEssais, id: \.self) { i in
                            Circle()
                                .fill(i < (maxEssais - essai) ? Color.red : Color.white.opacity(0.12))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Grille des essais
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            // Historique
                            ForEach(historique.indices, id: \.self) { row in
                                HStack(spacing: 5) {
                                    ForEach(historique[row]) { tuile in
                                        Text(tuile.lettre)
                                            .font(.system(size: tilleFont, weight: .bold, design: .monospaced))
                                            .foregroundColor(tuile.texteCouleur)
                                            .frame(width: tilleSize, height: tilleSize)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(tuile.couleur)
                                            )
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.15)) {
                                                    tuileSelectionnee = tuileSelectionnee == tuile.etat ? nil : tuile.etat
                                                }
                                            }
                                    }
                                }
                                .id(row)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: historique.count) { _ in
                        if let last = historique.indices.last {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }

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
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .font(.system(.title3, design: .monospaced))
                            .environment(\.colorScheme, .light)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onSubmit { proposer() }

                        if !proposition.isEmpty && proposition.count != motSecret.count {
                            Text("Il faut \(motSecret.count) lettres (tu en as \(proposition.count))")
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

            // Overlay victoire / défaite
            if case .gagne(let nbEssais) = etat {
                overlayResultat {
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 60))
                        Text("Bravo !")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Trouvé en \(nbEssais) essai\(nbEssais > 1 ? "s" : "") !")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Score : \(max(0, 100 - motSecret.count * nbEssais))")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        boutonRejouer
                    }
                }
            }

            if case .perdu(let solution) = etat {
                overlayResultat {
                    VStack(spacing: 16) {
                        Text("😔")
                            .font(.system(size: 60))
                        Text("Perdu...")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Le mot était :")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))

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

                        boutonRejouer
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            if tuileSelectionnee != nil {
                withAnimation(.easeInOut(duration: 0.15)) {
                    tuileSelectionnee = nil
                }
            }
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Dimensions tuiles

    private var tilleSize: CGFloat {
        let count = CGFloat(motSecret.count)
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 48
        let spacing: CGFloat = 5
        let available = maxWidth - (count - 1) * spacing
        return min(50, max(30, available / count))
    }

    private var tilleFont: CGFloat {
        tilleSize > 40 ? 22 : 18
    }

    private var propositionValide: Bool {
        proposition.count == motSecret.count && proposition.allSatisfy(\.isLetter)
    }

    // MARK: - Logique (inspirée de la version Python)

    private func proposer() {
        let prop = proposition.uppercased()
        guard prop.count == motSecret.count else { return }

        essai += 1

        if prop == motSecret {
            let tuiles = motSecret.map { LettreTuile(lettre: String($0), etat: .bonnePlace) }
            historique.append(tuiles)
            etat = .gagne(essais: essai)
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
                    resultats[i] = LettreTuile(lettre: "·", etat: .absent)
                }
            }
        }

        historique.append(resultats.compactMap { $0 })
        proposition = ""

        if essai >= maxEssais {
            etat = .perdu(mot: motSecret)
        }
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
                Label("Rejouer", systemImage: "arrow.counterclockwise")
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

    private func resetPartie() {
        proposition = ""
        historique = []
        essai = 0
        etat = .enCours
    }
}
