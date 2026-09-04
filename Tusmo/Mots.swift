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

    /// Clé stable utilisée pour sauvegarder les mots déjà trouvés.
    var cleProgression: String {
        "theme.\(nom)"
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

        let motsDuNiveau = disponibles.filter {
            niveau.longueurs.contains($0.count)
        }
        if let mot = motsDuNiveau.randomElement() {
            return mot
        }

        let distanceMinimum = disponibles
            .map { distance($0.count, de: niveau.longueurs) }
            .min() ?? 0
        let motsLesPlusProches = disponibles.filter {
            distance($0.count, de: niveau.longueurs) == distanceMinimum
        }
        return motsLesPlusProches.randomElement()
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
            "GARDIEN", "ESCALADE", "VESTIAIRE", "COUREUR", "TENNIS", "ESCRIME",
            "ATHLETE", "ENTRAINER", "CHAMPION", "EQUIPE", "JOUEUR", "COACH",
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
            "REAL", "HERO", "HEROINE", "VILAIN", "MONSTRE", "DRAME", "ACTION",
            "THRILLER", "ROMANCE", "AVENTURE", "FANTASY", "FICTION", "WESTERN",
            "BIOPIC", "MUSICAL", "DESSIN", "ANIMATION", "SERIE", "SAISON", "EPISODE",
            "ACTRICE", "STAR", "VEDETTE", "ROLE", "TITRE", "PLOT", "PRISE",
            "PLAN", "ANGLE", "FOCUS", "LUMIERE", "SON", "EFFET", "IMAGE", "BANDE",
            "SALLE", "DIALOGUE", "TICKET", "BOBINE", "PELICULE", "PREMIERE", "PALME",
            "OSCAR", "CESAR", "CANNES", "HOLLYWOOD", "NETFLIX", "GENRE", "RIRE",
            "LARME", "SAGA", "TRAILER"
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
            "MARQUEUR", "CRAYON", "POINTE", "TABLETTE", "ECRAN", "PROJECT", "LIVRE",
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
            "DAMIEN", "CHRISTOPHE", "SKEETER", "RED", "WIDE", "BECKY", "BARBRADY", "HARRISON",
            "THOMAS", "KELLY", "KIM", "TANGINA", "HARRIET", "VICTORIA", "MELVIN",
            "SHEILA"
        ]),
        Theme(nom: "Apple", emoji: "🍎", mots: [
            "APPLE", "IPHONE", "IPAD", "IMAC", "MACBOOK", "WATCH", "AIRPODS",
            "MACOS", "ICLOUD", "SAFARI", "SIRI", "STORE", "PENCIL", "KEYNOTE",
            "NUMBERS", "PAGES", "AIRPLAY", "FACETIME", "TOUCHID", "MAGSAFE",
            "IMESSAGE", "VISIONPRO", "HOMEKIT", "APPLETV", "TVPLUS", "IOS",
            "MACMINI", "MACPRO", "MACSTUDIO", "MACAIR", "IPOD", "IPODTOUCH", "IPHONESE",
            "IPHONEPRO", "IPHONEPLUS", "IPADMINI", "IPADAIR", "IPADPRO", "ULTRA", "AIRTAG",
            "HOMEPOD", "APPLEONE", "APPLECARE", "APPLEPAY", "AIRPRINT", "AIRDROP", "HANDOFF",
            "CARPLAY", "SWIFT", "XCODE", "DEVELOPER", "APPSTORE", "ITUNES", "PODCASTS",
            "MUSIC", "TVAPP", "BOOKS", "HEALTH", "FITNESS", "WEATHER", "MAPS", "PHOTOS",
            "NOTES", "REMINDERS", "CALENDAR", "CONTACTS", "SHORTCUTS", "WALLET", "LOGICPRO",
            "FINALCUT", "MOTION"
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
            "ASSIETTE", "CUILLERE", "COUTEAU", "POELE", "CASSEROLE", "BOL",
            "VERRE", "TASSE", "MUG", "PLATEAU", "MIXEUR", "BALAI", "EPONGE",
            "LESSIVE", "SAVON", "BROSSE", "SERVIETTE", "PAPIER", "POUBELLE",
            "PANIER", "BOUTEILLE", "HORLOGE", "REVEIL", "TELEPHONE", "CINTRE",
            "VALET", "RANGEMENT", "BOITE", "TIROIR", "PLACARD", "VASE", "NAPPE",
            "MEUBLE", "COMMODE", "BUFFET", "BANC", "TABOURET", "BUREAU", "ETENDOIR",
            "TRINGLE", "PORTE", "FENETRE", "VOLET", "POIGNEE", "PRISE", "RALLONGE",
            "CABLE", "AMPOULE", "ABATJOUR", "CADRE", "TABLEAU", "PLANTE", "POT", "BOUGIE",
            "ALLUMETTE", "SEAU", "PELLE", "PINCE", "MARTEAU", "TOURNEVIS", "CLOU", "PERCEUSE",
            "ECHELLE", "ESCABEAU", "OUTIL", "SAC", "PARAPLUIE", "CHAUSSURE", "MANTEAU",
            "PANTOUFLE"
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
        mots: GenerationPokemon.allCases.flatMap(\.mots)
    )

    static var tous: [Theme] { themes + [melange, pokemon] }
}
