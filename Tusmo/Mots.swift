//
//  Mots.swift
//  Tusmo
//
//  Banque de mots pour le mode solo : termes jouables, sans accent ni tiret.
//  Leur difficulté dépend de leur familiarité, pas de leur longueur.
//

import Foundation

private enum SurchargesNotoriete {
    /// Corrections des termes immédiatement reconnaissables qui ne sont pas
    /// forcément placés au début de leur banque. Les autres termes reçoivent
    /// un poids à partir de leur ordre éditorial.
    static let parTheme: [String: [String: Int]] = [
        "Sport": [
            "BALLON": 100, "PANIER": 96, "FOOTBALL": 100, "BASKET": 96,
            "TENNIS": 96, "RUGBY": 94, "STADE": 95, "SCORE": 100,
            "MATCH": 100, "BUT": 100, "EQUIPE": 100, "JOUEUR": 100,
            "CHAMPION": 94, "VICTOIRE": 94, "DEFAITE": 90, "PASSE": 94,
            "TIR": 94, "GOLF": 92, "SKI": 92, "SURF": 90
        ],
        "Musique": [
            "GUITARE": 100, "BATTERIE": 96, "CONCERT": 100, "PIANO": 100,
            "VIOLON": 94, "ALBUM": 95, "CHANSON": 100, "NOTE": 100,
            "RADIO": 100, "RAP": 100, "ROCK": 100, "POP": 100,
            "JAZZ": 94, "OPERA": 90, "HIT": 95, "TUBE": 94,
            "DANSER": 96, "GROUPE": 100, "SOLO": 90
        ],
        "Nourriture": [
            "PIZZA": 100, "GATEAU": 100, "FROMAGE": 100, "SALADE": 96,
            "POULET": 98, "CREPE": 98, "BURGER": 100, "CHOCOLAT": 100,
            "TOMATE": 100, "PATES": 100, "BANANE": 100, "GLACE": 100,
            "SEL": 100, "SUCRE": 100, "BEURRE": 98, "POMME": 100,
            "ORANGE": 98, "FRAISE": 98, "RIZ": 100, "STEAK": 96,
            "COOKIE": 96, "CHIPS": 98
        ],
        "Animaux": [
            "CHIEN": 100, "CHAT": 100, "LION": 100, "TIGRE": 100,
            "OURS": 100, "ELEPHANT": 100, "SINGE": 100, "CHEVAL": 100,
            "VACHE": 98, "POULE": 98, "COQ": 98,
            "PANDA": 100, "KOALA": 96, "PAPILLON": 98, "ABEILLE": 96,
            "FOURMI": 96, "DAUPHIN": 98, "BALEINE": 98, "REQUIN": 100,
            "GIRAFE": 100, "SERPENT": 100, "TORTUE": 100, "RENARD": 96,
            "LOUP": 98
        ],
        "Voyage": [
            "VALISE": 100, "AVION": 100, "PLAGE": 100, "HOTEL": 100,
            "BILLET": 98, "PASSEPORT": 100, "TRAIN": 100, "CAMPING": 96,
            "AEROPORT": 100, "BAGAGE": 98, "CARTE": 100, "GPS": 100,
            "OCEAN": 98, "ILE": 100, "PORT": 94, "ROUTE": 100,
            "BUS": 100, "TAXI": 100, "VELO": 98, "BATEAU": 100,
            "MUSEE": 98, "CHATEAU": 98, "PHOTO": 100, "VISA": 96,
            "TENTE": 94
        ],
        "Cinéma": [
            "ACTEUR": 100, "ACTRICE": 100, "CAMERA": 100, "ECRAN": 100,
            "COMEDIE": 96, "HORREUR": 100, "CINEMA": 100, "STUDIO": 94,
            "HEROS": 100, "VILAIN": 98, "DRAME": 98, "ACTION": 100,
            "ROMANCE": 98, "AVENTURE": 100, "SERIE": 100, "STAR": 100,
            "TICKET": 96, "OSCAR": 100, "NETFLIX": 100, "HOLLYWOOD": 100,
            "IMAGE": 100, "SON": 100, "DIALOGUE": 96
        ],
        "École": [
            "CAHIER": 100, "STYLO": 100, "DEVOIR": 100, "LYCEE": 98,
            "EXAMEN": 100, "CLASSE": 100, "TABLEAU": 100, "CANTINE": 98,
            "LECTURE": 100, "CALCUL": 98, "MANUEL": 96, "ETUDIANT": 100,
            "COLLEGE": 100, "ELEVE": 100, "COURS": 100, "NOTE": 100,
            "TRAVAIL": 100, "SCIENCE": 98, "HISTOIRE": 100, "FRANCAIS": 100,
            "ANGLAIS": 100, "MATHS": 100, "SPORT": 100, "LIVRE": 100,
            "QUESTION": 100, "REPONSE": 100, "RESULTAT": 96
        ],
        "Techno": [
            "CLAVIER": 100, "SOURIS": 100, "LOGICIEL": 96, "INTERNET": 100,
            "MEMOIRE": 96, "FICHIER": 98, "ROBOT": 100, "CONSOLE": 98,
            "DRONE": 100, "PIXEL": 96, "MOBILE": 100, "CHARGEUR": 100,
            "CABLE": 100, "WIFI": 100, "CODE": 100, "EMAIL": 100,
            "SITE": 100, "APP": 98, "CLOUD": 98, "SECURITE": 98,
            "LOGIN": 94, "COMPTE": 100, "MENU": 100, "BOUTON": 100,
            "VIDEO": 100, "AUDIO": 98, "VIRUS": 100
        ],
        "Nature": [
            "FORET": 100, "RIVIERE": 100, "ORAGE": 98, "NUAGE": 100,
            "VOLCAN": 100, "PRAIRIE": 96, "CASCADE": 100, "GLACIER": 96,
            "ARBRE": 100, "FLEUR": 100, "PLANTE": 100, "HERBE": 98,
            "JUNGLE": 100, "SAVANE": 98, "MONTAGNE": 100, "OCEAN": 100,
            "MER": 100, "LAC": 100, "ILE": 100, "PLAGE": 100,
            "PLUIE": 100, "NEIGE": 100, "SOLEIL": 100, "LUNE": 100,
            "ETOILE": 100, "OISEAU": 100, "ANIMAL": 100, "INSECTE": 98
        ],
        "Quotidien": [
            "MAISON": 100, "TELEPHONE": 100, "VOITURE": 100, "FENETRE": 100,
            "CANAPE": 98, "MIROIR": 100, "MATIN": 100, "NUIT": 100,
            "JOURNEE": 100, "SEMAINE": 100, "MOIS": 100, "ANNEE": 100,
            "TRAVAIL": 100, "ECOLE": 100, "FAMILLE": 100, "PARENT": 100,
            "ENFANT": 100, "AMOUR": 100, "RIRE": 100, "PLEUR": 96,
            "BONHEUR": 98, "ARGENT": 100, "CARTE": 100, "PORTE": 100,
            "CHAMBRE": 100, "SALON": 100, "MANGER": 100, "BOIRE": 100,
            "LIRE": 100, "ECRIRE": 100, "JOUER": 100, "FETE": 100,
            "CADEAU": 100, "APPEL": 100, "EMAIL": 100, "PHOTO": 100,
            "LIVRE": 100
        ],
        "Simpsons": [
            "HOMER": 100, "MARGE": 100, "BART": 100, "LISA": 100,
            "MAGGIE": 100, "MILHOUSE": 96, "FLANDERS": 96, "KRUSTY": 100,
            "BURNS": 100, "SMITHERS": 94, "NELSON": 96, "BARNEY": 94,
            "APU": 96, "MOE": 100, "PATTY": 90, "SELMA": 90,
            "WIGGUM": 92, "KANG": 90, "KODOS": 90,
            "SIDESHOW": 94, "BOB": 96, "SEYMOUR": 94, "EDNA": 90,
            "QUIMBY": 90, "CLETUS": 94, "ITCHY": 92, "SCRATCHY": 92,
            "BARTMAN": 94, "SANTA": 94, "SNOWBALL": 90
        ],
        "South Park": [
            "STAN": 100, "KYLE": 100, "CARTMAN": 100, "KENNY": 100,
            "BUTTERS": 100, "WENDY": 96, "RANDY": 100, "SHARON": 92,
            "SHELLEY": 90, "TWEEK": 96, "JIMMY": 96, "CRAIG": 96,
            "CHEF": 100, "IKE": 96, "TIMMY": 100, "MRHANKY": 94,
            "SATAN": 98, "SADDAM": 96, "PRINCIPAL": 94, "GARRISON": 96,
            "TOKEN": 92, "MANBEAR": 90, "DAMIEN": 88
        ],
        "Apple": [
            "APPLE": 100, "IPHONE": 100, "IPAD": 100, "IMAC": 96,
            "MACBOOK": 100, "WATCH": 96, "AIRPODS": 100, "AIRTAG": 92,
            "APPLETV": 94, "PENCIL": 88, "MACOS": 92, "IOS": 100,
            "ICLOUD": 96, "SAFARI": 100, "SIRI": 100, "FACETIME": 100,
            "IMESSAGE": 96, "TOUCHID": 94, "MAGSAFE": 90, "APPLEID": 92,
            "APPLEPAY": 96, "AIRDROP": 100, "CARPLAY": 92, "APPSTORE": 100,
            "ITUNES": 94, "IPOD": 96
        ],
        "Pays": [
            "FRANCE": 100, "ESPAGNE": 100, "ITALIE": 100, "ALLEMAGNE": 100,
            "PORTUGAL": 98, "BELGIQUE": 100, "SUISSE": 100, "CANADA": 100,
            "BRESIL": 100, "MEXIQUE": 100, "JAPON": 100, "CHINE": 100,
            "INDE": 100, "EGYPTE": 100, "MAROC": 100, "ALGERIE": 96,
            "TUNISIE": 96, "TURQUIE": 100, "GRECE": 100, "NORVEGE": 96,
            "SUEDE": 96, "RUSSIE": 100, "AUSTRALIE": 100, "ISRAEL": 96,
            "VIETNAM": 96, "THAILANDE": 94
        ],
        "Objets maison": [
            "TABLE": 100, "CHAISE": 100, "CANAPE": 100, "FAUTEUIL": 96,
            "LAMPE": 100, "MIROIR": 100, "RIDEAU": 96, "TAPIS": 100,
            "ARMOIRE": 96, "COUSSIN": 100, "OREILLER": 100, "MATELAS": 96,
            "ASSIETTE": 100, "CUILLERE": 100, "COUTEAU": 100, "POELE": 98,
            "CASSEROLE": 96, "FRIGO": 100, "VERRE": 100, "TASSE": 100,
            "MUG": 98, "BALAI": 100, "EPONGE": 100, "SAVON": 100,
            "BROSSE": 98, "POUBELLE": 100, "BOUTEILLE": 100, "HORLOGE": 100,
            "REVEIL": 100, "TELEPHONE": 100, "BOITE": 100, "TIROIR": 100,
            "PLACARD": 96, "PORTE": 100, "FENETRE": 100, "PRISE": 100,
            "CABLE": 100, "AMPOULE": 100, "MARTEAU": 100, "TOURNEVIS": 96,
            "FOURCHETTE": 100, "CAFETIERE": 96, "RADIATEUR": 96
        ]
    ]
}

struct Theme: Identifiable, Hashable {
    let id = UUID()
    let nom: String
    let emoji: String
    let mots: [String]
    let poidsParMot: [String: Int]

    init(
        nom: String,
        emoji: String,
        mots: [String],
        poidsParMot: [String: Int] = [:]
    ) {
        self.nom = nom
        self.emoji = emoji
        self.mots = mots
        var surcharges = SurchargesNotoriete.parTheme[nom] ?? [:]
        for (mot, poids) in poidsParMot {
            surcharges[mot.uppercased()] = poids
        }
        self.poidsParMot = MoteurDifficulte.poidsParOrdreDeNotoriete(
            mots,
            surcharges: surcharges
        )
    }

    var estPokemon: Bool {
        nom == "Pokémon"
    }

    /// Clé stable utilisée pour sauvegarder les mots déjà trouvés.
    var cleProgression: String {
        "theme.\(nom)"
    }

    /// Poids de familiarité du terme : 100 = très connu, 1 = très spécialisé.
    func poidsDuMot(_ mot: String) -> Int {
        poidsParMot[mot.uppercased()] ?? 50
    }

    /// Classement éditorial du terme, indépendant de sa longueur.
    func niveauDuMot(_ mot: String) -> NiveauJeu {
        NiveauJeu.depuisPoids(poidsDuMot(mot))
    }

    var repartitionDifficulte: [NiveauJeu: Int] {
        mots.reduce(into: [:]) { resultats, mot in
            let niveau = niveauDuMot(mot)
            resultats[niveau, default: 0] += 1
        }
    }

    /// Un mot au hasard, différent de `sauf` si possible.
    func motAleatoire(sauf: String? = nil) -> String {
        let choix = mots.filter { $0 != sauf }
        return (choix.isEmpty ? mots : choix).randomElement() ?? "MOTUS"
    }

    /// Un mot adapté au niveau du joueur, différent de `sauf` si possible.
    ///
    /// Les mots sont classés par familiarité. Si un thème n'a plus de mot au
    /// niveau exact, on prend la difficulté la plus proche.
    func motAleatoire(niveau: NiveauJeu, sauf: String? = nil) -> String {
        motAleatoireNonTrouve(niveau: niveau, sauf: sauf, exclus: []) ?? "MOTUS"
    }

    /// Tire un mot qui n'appartient pas à `exclus`.
    /// Retourne `nil` quand le thème est entièrement découvert.
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

        let motsDuNiveau = disponibles.filter { niveauDuMot($0) == niveau }
        if let mot = motsDuNiveau.randomElement() {
            return mot
        }

        let distanceMinimum = disponibles
            .map { abs(niveauDuMot($0).rawValue - niveau.rawValue) }
            .min() ?? 0
        let motsLesPlusProches = disponibles.filter {
            abs(niveauDuMot($0).rawValue - niveau.rawValue) == distanceMinimum
        }
        return motsLesPlusProches.randomElement()
    }
}

enum BanqueDeMots {
    // Chaque banque est organisée du terme le plus connu au plus spécifique.
    static let themes: [Theme] = [
        Theme(nom: "Sport", emoji: "🏀", mots: [
            "BALLON", "PANIER", "ARBITRE", "MAILLOT", "RAQUETTE", "NATATION",
            "MARATHON", "DRIBBLE", "PODIUM", "SPRINT", "TRIBUNE", "PENALTY",
            "GARDIEN", "ESCALADE", "VESTIAIRE", "COUREUR", "TENNIS", "ESCRIME",
            "ATHLETE", "ENTRAINEUR", "CHAMPION", "EQUIPE", "JOUEUR", "COACH",
            "STADE", "SCORE", "MATCH", "TOURNOI", "MEDAILLE", "RECORD",
            "VICTOIRE", "DEFAITE", "ATTAQUE", "DEFENSE", "PASSE", "TIR",
            "BUT", "FOOTBALL", "RUGBY", "BASKET", "VOLLEY", "HANDBALL",
            "CYCLISME", "BOXEUR", "JUDO", "KARATE", "SKI", "SURF", "GOLF",
            "BALLE", "BATON", "FILET", "LIGNE", "COULOIR", "CHRONO",
            "ENDURANCE", "VITESSE", "SPRINTER", "PISCINE", "PLONGEE", "REGATE",
            "VOILE", "PATINAGE", "GYMNASTE", "PILOTE", "MUSCLE", "TROPHEE",
            "ARBITRAGE", "ECHANGE", "RELAIS", "CIRCUIT", "RALLYE"
        ]),
        Theme(nom: "Musique", emoji: "🎵", mots: [
            "GUITARE", "BATTERIE", "CONCERT", "MELODIE", "REFRAIN", "COUPLET",
            "CHANTEUR", "RYTHME", "PIANO", "VIOLON", "PAROLES", "ALBUM",
            "SCENE", "TROMPETTE", "CASQUE", "ACCORD", "SILENCE", "TAMBOUR",
            "HARMONIE", "MUSICIEN", "ORCHESTRE", "BATTEUR", "PIANISTE", "SAXO",
            "FLUTE", "HARPE", "ORGUE", "BASSE", "BASSISTE", "MICRO", "AMPLI",
            "ENCEINTE", "RADIO", "CHANSON", "TEMPO", "NOTE", "GAMME",
            "PARTITION", "SOLFEGE", "CHORALE", "CHANT", "DANSER", "DANSEUR",
            "PUBLIC", "FESTIVAL", "SPECTACLE", "TOURNEE", "VINYLE", "DISQUE",
            "CASSETTE", "TUBE", "HIT", "PLAYLIST", "AUTEUR", "COMPOSER",
            "RAP", "JAZZ", "ROCK", "OPERA", "BLUES", "SOUL", "FOLK", "METAL",
            "TECHNO", "POP", "ELECTRO", "GROUPE", "SALLE", "OUVERTURE", "SOLO"
        ]),
        Theme(nom: "Nourriture", emoji: "🍕", mots: [
            "PIZZA", "GATEAU", "FROMAGE", "SALADE", "POULET", "CREPE",
            "BURGER", "DESSERT", "CHOCOLAT", "TOMATE", "BAGUETTE", "PATES",
            "SANDWICH", "YAOURT", "RACLETTE", "POIVRON", "BANANE", "GLACE",
            "POIVRE", "SEL", "SUCRE", "FARINE", "BEURRE", "HUILE", "VINAIGRE",
            "MIEL", "CONFITURE", "CEREALES", "BISCUIT", "TARTINE", "CROISSANT",
            "BRIOCHE", "BAGEL", "POMME", "ORANGE", "FRAISE", "CERISE", "RAISIN",
            "MELON", "PASTEQUE", "CAROTTE", "PATATE", "OIGNON", "AIL", "POIREAU",
            "EPINARD", "HARICOT", "POISSON", "SAUMON", "THON", "CREVETTE", "VIANDE",
            "STEAK", "JAMBON", "SAUCISSE", "OMELETTE", "SORBET", "CREME", "MOUSSE",
            "TARTE", "MUFFIN", "COOKIE", "BROWNIE", "PANCAKE", "GAUFRE", "POPCORN",
            "CHIPS", "NOUILLES", "RIZ", "COUSCOUS"
        ]),
        Theme(nom: "Animaux", emoji: "🐾", mots: [
            "RENARD", "PANTHERE", "DAUPHIN", "ECUREUIL", "TORTUE", "PERROQUET",
            "GIRAFE", "SERPENT", "HIBOU", "REQUIN", "LEZARD", "BALEINE",
            "CHEVAL", "MOUTON", "CANARD", "ARAIGNEE", "PINGOUIN", "BLAIREAU",
            "LION", "TIGRE", "ELEPHANT", "ZEBRE", "SINGE", "GORILLE", "BABOUIN",
            "OURS", "PANDA", "KOALA", "KANGOUROU", "LAMA", "CHAMEAU", "LOUP",
            "CHIEN", "CHAT", "LAPIN", "RAT", "SOURIS", "CASTOR", "HERISSON",
            "TAUPE", "CERF", "DAIM", "SANGLIER", "CHEVREUIL", "CHEVRE", "VACHE",
            "COCHON", "ANE", "PONEY", "POULE", "COQ", "OIE", "DINDON", "AIGLE",
            "FAUCON", "CHOUETTE", "CORBEAU", "CYGNE", "FLAMANT", "MANCHOT", "ORQUE",
            "PHOQUE", "CROCODILE", "IGUANE", "MOUSTIQUE", "CRAPAUD", "SCORPION",
            "PAPILLON", "ABEILLE", "FOURMI"
        ]),
        Theme(nom: "Voyage", emoji: "✈️", mots: [
            "VALISE", "AVION", "PLAGE", "HOTEL", "BILLET", "DOUANE",
            "DESERT", "MONTAGNE", "PASSEPORT", "TRAIN", "SEJOUR", "CROISIERE",
            "CAMPING", "AEROPORT", "BAGAGE", "ESCALE", "RANDONNEE", "BOUSSOLE",
            "DESTIN", "VACANCIER", "VOYAGEUR", "TOURISTE", "TOURISME", "DEPART",
            "ARRIVEE", "CARTE", "GUIDE", "ATLAS", "GPS", "AUBERGE", "RESORT",
            "VILLAGE", "PAYSAGE", "OCEAN", "LAC", "ILE", "PLATEAU", "VALLEE",
            "RIVAGE", "PORT", "QUAI", "PHARE", "ROUTE", "AUTOROUTE", "PONT",
            "TUNNEL", "METRO", "BUS", "TAXI", "VELO", "BATEAU", "NAVIRE",
            "FERRY", "YACHT", "CABINE", "TOUR", "MUSEE", "MONUMENT", "CHATEAU",
            "TEMPLE", "PALAIS", "PLAZA", "RANDO", "TREK", "TENTE", "PHOTO",
            "SOUVENIR", "TICKET", "VISA", "FRONTIERE"
        ]),
        Theme(nom: "Cinéma", emoji: "🎬", mots: [
            "ACTEUR", "CAMERA", "ECRAN", "COMEDIE", "SUSPENSE", "TOURNAGE",
            "REPLIQUE", "SCENARIO", "DECOR", "COSTUME", "MONTAGE", "HORREUR",
            "CINEMA", "SEANCE", "AFFICHE", "DOUBLAGE", "STUDIO", "INTRIGUE",
            "CAMEO", "HEROS", "HEROINE", "VILAIN", "MONSTRE", "DRAME", "ACTION",
            "THRILLER", "ROMANCE", "AVENTURE", "FANTASY", "FICTION", "WESTERN",
            "BIOPIC", "MUSICAL", "DESSIN", "ANIMATION", "SERIE", "SAISON", "EPISODE",
            "ACTRICE", "STAR", "VEDETTE", "ROLE", "TITRE", "PITCH", "PRISE",
            "PLAN", "ANGLE", "FOCUS", "LUMIERE", "SON", "EFFET", "IMAGE", "BANDE",
            "SALLE", "DIALOGUE", "TICKET", "BOBINE", "PELICULE", "PREMIERE", "PALME",
            "OSCAR", "CESAR", "CANNES", "HOLLYWOOD", "NETFLIX", "GENRE", "RIRE",
            "LARME", "SAGA", "TEASER"
        ]),
        Theme(nom: "École", emoji: "🎓", mots: [
            "CAHIER", "STYLO", "DEVOIR", "LYCEE", "EXAMEN", "CLASSE",
            "TABLEAU", "CANTINE", "DIPLOME", "LECTURE", "CALCUL", "MANUEL",
            "TROUSSE", "BULLETIN", "PUPITRE", "ETUDIANT", "RENTREE", "CARTABLE",
            "COLLEGE", "ELEVE", "ETUDE", "MATIERE", "LECON", "COURS", "NOTE",
            "MOYENNE", "TRAVAIL", "RECHERCHE", "SCIENCE", "HISTOIRE", "GEO", "FRANCAIS",
            "ANGLAIS", "ESPAGNOL", "MATHS", "PHYSIQUE", "CHIMIE", "BIOLOGIE", "ARTS",
            "SPORT", "RECRE", "SEMESTRE", "TRIMESTRE", "AGENDA", "PLANNING", "DOSSIER",
            "CLASSEUR", "FEUILLE", "PAPIER", "GOMME", "REGLE", "COMPAS", "EQUERRE",
            "MARQUEUR", "CRAYON", "POINTE", "TABLETTE", "ECRAN", "PROJET", "LIVRE",
            "ROMAN", "POESIE", "EXERCICE", "QUESTION", "REPONSE", "CONTROLE", "CONCOURS",
            "RESULTAT", "CAMPUS", "COULOIR", "CASIER", "UNIFORME", "SONNERIE"
        ]),
        Theme(nom: "Techno", emoji: "💻", mots: [
            "CLAVIER", "SOURIS", "LOGICIEL", "RESEAU", "INTERNET", "MEMOIRE",
            "FICHIER", "ROBOT", "CONSOLE", "MANETTE", "DRONE", "CAPTEUR",
            "PIXEL", "ECOUTEUR", "MESSAGE", "PIRATE", "TABLETTE", "MOTEUR",
            "MOBILE", "CHARGEUR", "CABLE", "ADAPTATEUR", "WEBCAM", "SERVEUR", "ROUTEUR",
            "MODEM", "WIFI", "BLUETOOTH", "PROGRAMME", "CODE", "CODAGE", "DONNEE",
            "DATABASE", "DOSSIER", "COURRIEL", "EMAIL", "SITE", "PAGE", "LIEN", "BROWSER",
            "JOYSTICK", "IMAGE", "VIDEO", "AUDIO", "APPLI", "APP", "SERVICES", "CLOUD",
            "CRYPTO", "SECURITE", "LOGIN", "COMPTE", "PROFIL", "ICONE", "MENU", "BOUTON",
            "TOUCHE", "STOCKAGE", "RECHARGE", "CHARGE", "DATA", "PUCE", "CARTE", "LED",
            "LASER", "DISQUE", "RECHERCHE", "IMPRIME", "SMART", "VIRUS"
        ]),
        Theme(nom: "Nature", emoji: "🌳", mots: [
            "FORET", "RIVIERE", "ORAGE", "NUAGE", "VOLCAN", "PRAIRIE",
            "CASCADE", "GLACIER", "SENTIER", "FEUILLE", "RACINE", "SABLE",
            "MARAIS", "ARBRE", "TEMPETE", "HORIZON", "BRUME", "FALAISE",
            "FLEUR", "PLANTE", "HERBE", "BUISSON", "JUNGLE", "SAVANE", "OASIS",
            "COLLINE", "MONTAGNE", "VALLEE", "CANYON", "LITTORAL", "OCEAN", "MER",
            "LAC", "ETANG", "RUISSEAU", "SOURCE", "DELTA", "ILE", "PLAGE", "ROCHER",
            "PIERRE", "MINERAL", "CRISTAL", "LAVE", "ECLAIR", "TONNERRE", "BROUILLARD",
            "VENT", "BOURRASQUE", "PLUIE", "NEIGE", "GIVRE", "SOLEIL", "LUNE", "ETOILE",
            "AUBE", "PRINTEMPS", "ETE", "AUTOMNE", "HIVER", "BOIS", "ESPECE", "OISEAU",
            "ANIMAL", "INSECTE", "GRAINE", "POLLEN", "SEVE", "MOUSSE", "ALGUE"
        ]),
        Theme(nom: "Quotidien", emoji: "🏠", mots: [
            "REVEIL", "SOIREE", "AMITIE", "SOURIRE", "VOISIN", "CUISINE",
            "JARDIN", "MAISON", "TELEPHONE", "MARCHE", "QUARTIER", "DIMANCHE",
            "VOITURE", "FENETRE", "CANAPE", "MIROIR", "COURSES", "VACANCES",
            "MATIN", "NUIT", "JOURNEE", "SEMAINE", "MOIS", "ANNEE", "AGENDA",
            "TRAVAIL", "BUREAU", "ECOLE", "FAMILLE", "PARENT", "ENFANT", "AMOUR",
            "RIRE", "PLEUR", "BONHEUR", "PROBLEME", "SOLUTION", "COURRIER", "COLIS",
            "PAQUET", "ACHAT", "VENTE", "PRIX", "ARGENT", "CARTE", "CLE", "PORTE",
            "MUR", "SOL", "PLAFOND", "ESCALIER", "COULOIR", "CHAMBRE", "SALON", "DORMIR",
            "MANGER", "BOIRE", "DANSER", "LIRE", "ECRIRE", "JOUER", "SORTIE", "PROMENADE",
            "RENCONTRE", "FETE", "CADEAU", "APPEL", "EMAIL", "PHOTO", "LIVRE"
        ]),
        Theme(nom: "Simpsons", emoji: "🍩", mots: [
            "HOMER", "MARGE", "BART", "LISA", "MAGGIE", "MILHOUSE",
            "FLANDERS", "SKINNER", "KRUSTY", "BURNS", "SMITHERS", "NELSON",
            "RALPH", "BARNEY", "APU", "MOE", "PATTY", "SELMA", "WIGGUM",
            "HIBBERT", "LOVEJOY", "MARTIN", "OTTO", "KANG", "KODOS",
            "ABRAHAM", "CLANCY", "HERB", "MARVIN", "LENNY", "CARL", "REV", "HELEN",
            "MAUDE", "TODD", "ROD", "DOLPH", "JIMBO", "KIRK", "LUANN", "RUTH",
            "COOKIE", "MEL", "COMIC", "SIDESHOW", "BOB", "TROY", "SEYMOUR", "EDNA",
            "AGNES", "MAYOR", "QUIMBY", "CLETUS", "BRANDINE", "SHERRI", "TERRI", "JASPER",
            "FRINK", "KENT", "NICK", "ITCHY", "SCRATCHY", "SNOWBALL", "BARTMAN", "SANTA",
            "LURLEEN", "AMBER", "MINDY", "GIL", "FINK"
        ]),
        Theme(nom: "South Park", emoji: "🏔️", mots: [
            "STAN", "KYLE", "CARTMAN", "KENNY", "BUTTERS", "WENDY",
            "RANDY", "SHARON", "SHELLEY", "GERALD", "STUART", "TWEEK",
            "JIMMY", "CRAIG", "CLYDE", "BEBE", "TOKEN", "GARRISON",
            "CHEF", "IKE", "TIMMY", "MRHANKY", "SATAN", "SADDAM",
            "TERRANCE", "PHILLIP", "PIP", "DOUG", "SCOTT", "GREGORY", "HEIDI",
            "PRINCIPAL", "MACKY", "MILLIE", "LEROY", "STEVEN", "LINDA", "RICHARD",
            "CAROL", "MARCY", "GARY", "JESUS", "MOSES", "GOD", "MRSLAVE", "MRHAT",
            "MRMOUSE", "MANBEAR", "JONAS", "MATT", "DEVON", "BRADLEY", "ROMAN", "FOSSEY",
            "DAMIEN", "CHRISTOPHE", "SKEETER", "RED", "TENORMAN", "BECKY", "BARBRADY", "HARRISON",
            "THOMAS", "KELLY", "KIM", "TANGINA", "HARRIET", "VICTORIA", "MELVIN",
            "SHEILA"
        ]),
        Theme(nom: "Apple", emoji: "🍎", mots: [
            "APPLE", "IPHONE", "IPAD", "IMAC", "MACBOOK", "WATCH", "AIRPODS",
            "VISIONPRO", "AIRTAG", "HOMEPOD", "APPLETV", "PENCIL", "MACOS", "IOS",
            "ICLOUD", "SAFARI", "SIRI", "FACETIME", "IMESSAGE", "AIRPLAY", "TOUCHID",
            "MAGSAFE", "HOMEKIT", "APPLEID", "APPLEONE", "APPLECARE", "APPLEPAY",
            "AIRPRINT", "AIRDROP", "HANDOFF", "CARPLAY", "APPSTORE", "SWIFT", "SWIFTUI",
            "XCODE", "ARKIT", "COREML", "METAL", "DARWIN", "QUICKTIME", "ITUNES",
            "KEYNOTE", "NUMBERS", "PAGES", "LOGICPRO", "FINALCUT", "MOTION", "WATCHOS",
            "TVOS", "IPOD"
        ]),
        Theme(nom: "Pays", emoji: "🌍", mots: [
            "FRANCE", "ESPAGNE", "ITALIE", "ALLEMAGNE", "PORTUGAL", "BELGIQUE",
            "SUISSE", "CANADA", "BRESIL", "MEXIQUE", "JAPON", "CHINE", "INDE",
            "NEPAL", "EGYPTE", "KENYA", "NIGERIA", "MAROC", "ALGERIE", "TUNISIE",
            "TURQUIE", "GRECE", "NORVEGE", "SUEDE", "FINLANDE", "ISLANDE",
            "IRLANDE", "UKRAINE", "GEORGIE", "ARMENIE", "CHILI", "BOLIVIE",
            "PEROU", "GUYANA", "URUGUAY", "EQUATEUR", "COLOMBIE", "AUSTRALIE",
            "FIDJI", "SAMOA", "TONGA", "QATAR", "ISRAEL", "JORDANIE", "VIETNAM",
            "THAILANDE", "CAMBODGE", "MALAISIE", "SINGAPOUR", "INDONESIE", "RUSSIE",
            "SENEGAL", "CAMEROUN", "ETHIOPIE", "SOMALIE", "OUGANDA", "TANZANIE",
            "ZAMBIE", "ZIMBABWE", "ANGOLA", "MAURICE", "COMORES", "DJIBOUTI",
            "MOLDAVIE", "SLOVAQUIE", "CROATIE", "SERBIE", "SLOVENIE", "LITUANIE",
            "LETTONIE", "ESTONIE", "BULGARIE", "ROUMANIE"
        ]),
        Theme(nom: "Objets maison", emoji: "🛋️", mots: [
            "TABLE", "CHAISE", "CANAPE", "FAUTEUIL", "LAMPE", "MIROIR", "RIDEAU",
            "TAPIS", "ARMOIRE", "ETAGERE", "COUSSIN", "OREILLER", "MATELAS",
            "ASSIETTE", "CUILLERE", "COUTEAU", "POELE", "CASSEROLE", "FRIGO",
            "VERRE", "TASSE", "MUG", "PLATEAU", "MIXEUR", "BALAI", "EPONGE",
            "CAFETIERE", "SAVON", "BROSSE", "SERVIETTE", "PAPIER", "POUBELLE",
            "PANIER", "BOUTEILLE", "HORLOGE", "REVEIL", "TELEPHONE", "CINTRE",
            "RADIATEUR", "RANGEMENT", "BOITE", "TIROIR", "PLACARD", "VASE", "NAPPE",
            "MEUBLE", "COMMODE", "BUFFET", "BANC", "TABOURET", "BUREAU", "ETENDOIR",
            "TRINGLE", "PORTE", "FENETRE", "VOLET", "POIGNEE", "PRISE", "RALLONGE",
            "CABLE", "AMPOULE", "ABATJOUR", "CADRE", "TABLEAU", "PLANTE", "POT", "BOUGIE",
            "ALLUMETTE", "SEAU", "PELLE", "PINCE", "MARTEAU", "TOURNEVIS", "CLOU", "PERCEUSE",
            "ECHELLE", "ESCABEAU", "OUTIL", "MACHINE", "FOURCHETTE", "SECHOIR", "LOUCHE",
            "PASSOIRE"
        ])
    ]

    /// Thème spécial qui pioche dans tous les autres.
    static let melange = Theme(
        nom: "Mélange",
        emoji: "🎲",
        mots: themes.flatMap(\.mots),
        poidsParMot: themes.reduce(into: [:]) { resultats, theme in
            for (mot, poids) in theme.poidsParMot {
                resultats[mot] = resultats[mot] ?? poids
            }
        }
    )

    /// Thème avec une étape supplémentaire pour choisir la génération.
    static let pokemon = Theme(
        nom: "Pokémon",
        emoji: "⚡️",
        mots: GenerationPokemon.allCases.flatMap(\.mots),
        poidsParMot: GenerationPokemon.allCases.reduce(into: [:]) { resultats, generation in
            for (mot, poids) in generation.poidsParMot {
                resultats[mot] = poids
            }
        }
    )

    static var tous: [Theme] { themes + [melange, pokemon] }
}
