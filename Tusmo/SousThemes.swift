//
//  SousThemes.swift
//  Tusmo
//
//  Taxonomie éditoriale des banques. Les mots restent définis dans Mots.swift
//  et ces classifications ajoutent uniquement une couche de filtrage.
//

import Foundation
import Combine

struct SousTheme: Identifiable, Hashable {
    let id: String
    let nom: String
    let emoji: String?
}

enum FiltreSousTheme: Hashable, Identifiable {
    case aleatoire
    case sousTheme(String)

    static let identifiantAleatoire = "__all__"

    var identifiant: String {
        switch self {
        case .aleatoire:
            return Self.identifiantAleatoire
        case .sousTheme(let id):
            return id
        }
    }

    var id: String { identifiant }
}

/// Préférences de filtre indépendantes des profils et de leur progression.
/// Elles sont conservées localement pour retrouver le dernier choix après
/// avoir quitté une partie ou relancé l'application.
final class SelectionSousThemes: ObservableObject {
    @Published private(set) var selectionParTheme: [String: String]

    private let defaults: UserDefaults
    private let cleSauvegarde = "tusmo.lastSubthemes.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectionParTheme = defaults.dictionary(forKey: cleSauvegarde) as? [String: String] ?? [:]
    }

    func filtrePour(_ theme: Theme) -> FiltreSousTheme {
        guard let identifiant = selectionParTheme[theme.cleProgression],
              identifiant != FiltreSousTheme.identifiantAleatoire,
              theme.sousThemes.contains(where: { $0.id == identifiant }) else {
            return .aleatoire
        }
        return .sousTheme(identifiant)
    }

    func choisir(_ filtre: FiltreSousTheme, pour theme: Theme) {
        guard !theme.sousThemes.isEmpty else { return }
        selectionParTheme[theme.cleProgression] = filtre.identifiant
        defaults.set(selectionParTheme, forKey: cleSauvegarde)
    }
}

enum TaxonomieThemes {
    private static func classifications(
        _ categories: [String: [String]]
    ) -> [String: Set<String>] {
        categories.reduce(into: [:]) { resultat, entree in
            for mot in entree.value {
                resultat[mot, default: []].insert(entree.key)
            }
        }
    }

    static let definitionsParTheme: [String: [SousTheme]] = [
        "Pays": [
            SousTheme(id: "europe", nom: "Europe", emoji: "🌍"),
            SousTheme(id: "afrique", nom: "Afrique", emoji: "🌍"),
            SousTheme(id: "asie", nom: "Asie", emoji: "🌏"),
            SousTheme(id: "ameriqueNord", nom: "Amérique du Nord", emoji: "🌎"),
            SousTheme(id: "ameriqueSud", nom: "Amérique du Sud", emoji: "🌎"),
            SousTheme(id: "oceanie", nom: "Océanie", emoji: "🌊")
        ],
        "École": [
            SousTheme(id: "matieres", nom: "Matières", emoji: "📚"),
            SousTheme(id: "fournitures", nom: "Fournitures / outils", emoji: "✏️"),
            SousTheme(id: "vieScolaire", nom: "Vie scolaire", emoji: "🎒"),
            SousTheme(id: "lieux", nom: "Lieux", emoji: "🏫"),
            SousTheme(id: "evaluations", nom: "Examens / évaluations", emoji: "📝"),
            SousTheme(id: "superieur", nom: "Enseignement supérieur", emoji: "🎓")
        ],
        "Sport": [
            SousTheme(id: "collectifs", nom: "Sports collectifs", emoji: "👥"),
            SousTheme(id: "individuels", nom: "Sports individuels", emoji: "🏅"),
            SousTheme(id: "combat", nom: "Sports de combat", emoji: "🥊"),
            SousTheme(id: "aquatiques", nom: "Sports aquatiques", emoji: "🌊"),
            SousTheme(id: "hiver", nom: "Sports d'hiver", emoji: "❄️"),
            SousTheme(id: "mecaniques", nom: "Sports mécaniques", emoji: "🏎️"),
            SousTheme(id: "athletisme", nom: "Athlétisme", emoji: "🏃"),
            SousTheme(id: "vocabulaire", nom: "Matériel / vocabulaire sportif", emoji: "🏟️")
        ],
        "Musique": [
            SousTheme(id: "instruments", nom: "Instruments", emoji: "🎸"),
            SousTheme(id: "genres", nom: "Genres", emoji: "🎵"),
            SousTheme(id: "chant", nom: "Chant / voix", emoji: "🎤"),
            SousTheme(id: "scene", nom: "Concert / scène", emoji: "🎟️"),
            SousTheme(id: "theorie", nom: "Théorie musicale", emoji: "🎼"),
            SousTheme(id: "production", nom: "Production / audio", emoji: "🎧")
        ],
        "Nourriture": [
            SousTheme(id: "fruits", nom: "Fruits", emoji: "🍎"),
            SousTheme(id: "legumes", nom: "Légumes", emoji: "🥕"),
            SousTheme(id: "viandesPoissons", nom: "Viandes / poissons", emoji: "🍗"),
            SousTheme(id: "feculents", nom: "Féculents", emoji: "🍞"),
            SousTheme(id: "desserts", nom: "Desserts / sucreries", emoji: "🍰"),
            SousTheme(id: "laitiers", nom: "Produits laitiers", emoji: "🧀"),
            SousTheme(id: "plats", nom: "Plats", emoji: "🍽️"),
            SousTheme(id: "condiments", nom: "Condiments / ingrédients", emoji: "🧂"),
            SousTheme(id: "boissons", nom: "Boissons", emoji: "☕️")
        ],
        "Animaux": [
            SousTheme(id: "mammiferes", nom: "Mammifères", emoji: "🐾"),
            SousTheme(id: "oiseaux", nom: "Oiseaux", emoji: "🦅"),
            SousTheme(id: "reptiles", nom: "Reptiles", emoji: "🐊"),
            SousTheme(id: "marins", nom: "Animaux marins", emoji: "🐬"),
            SousTheme(id: "insectesArachnides", nom: "Insectes / arachnides", emoji: "🕷️"),
            SousTheme(id: "ferme", nom: "Animaux de ferme", emoji: "🐄"),
            SousTheme(id: "sauvages", nom: "Animaux sauvages", emoji: "🦁")
        ],
        "Voyage": [
            SousTheme(id: "transports", nom: "Transports", emoji: "✈️"),
            SousTheme(id: "hebergement", nom: "Hébergement", emoji: "🏨"),
            SousTheme(id: "formalites", nom: "Documents / formalités", emoji: "🛂"),
            SousTheme(id: "destinations", nom: "Nature / destinations", emoji: "🏝️"),
            SousTheme(id: "tourisme", nom: "Tourisme", emoji: "📸"),
            SousTheme(id: "orientation", nom: "Navigation / orientation", emoji: "🧭")
        ],
        "Cinéma": [
            SousTheme(id: "genres", nom: "Genres", emoji: "🎭"),
            SousTheme(id: "metiers", nom: "Métiers", emoji: "🎬"),
            SousTheme(id: "tournage", nom: "Tournage", emoji: "🎥"),
            SousTheme(id: "diffusion", nom: "Salle / diffusion", emoji: "🎞️"),
            SousTheme(id: "narration", nom: "Narration", emoji: "📖"),
            SousTheme(id: "technique", nom: "Technique", emoji: "🎞️")
        ],
        "Techno": [
            SousTheme(id: "materiel", nom: "Matériel", emoji: "🖥️"),
            SousTheme(id: "reseau", nom: "Internet / réseau", emoji: "🌐"),
            SousTheme(id: "programmation", nom: "Programmation", emoji: "💻"),
            SousTheme(id: "cybersecurite", nom: "Cybersécurité", emoji: "🔒"),
            SousTheme(id: "systemes", nom: "Logiciels / systèmes", emoji: "⚙️"),
            SousTheme(id: "donnees", nom: "Données", emoji: "🗄️"),
            SousTheme(id: "ia", nom: "IA", emoji: "🤖")
        ],
        "Nature": [
            SousTheme(id: "vegetation", nom: "Végétation", emoji: "🌿"),
            SousTheme(id: "eau", nom: "Eau", emoji: "💧"),
            SousTheme(id: "reliefs", nom: "Reliefs", emoji: "⛰️"),
            SousTheme(id: "meteo", nom: "Météo", emoji: "🌦️"),
            SousTheme(id: "saisons", nom: "Saisons", emoji: "🍂"),
            SousTheme(id: "geologie", nom: "Géologie", emoji: "🪨"),
            SousTheme(id: "ecosystemes", nom: "Écosystèmes", emoji: "🌳")
        ],
        "Objets maison": [
            SousTheme(id: "cuisine", nom: "Cuisine", emoji: "🍳"),
            SousTheme(id: "chambre", nom: "Chambre", emoji: "🛏️"),
            SousTheme(id: "salon", nom: "Salon", emoji: "🛋️"),
            SousTheme(id: "salleBain", nom: "Salle de bain", emoji: "🧼"),
            SousTheme(id: "rangement", nom: "Rangement", emoji: "🗄️"),
            SousTheme(id: "bricolage", nom: "Bricolage", emoji: "🔨"),
            SousTheme(id: "electrique", nom: "Électrique / électronique", emoji: "💡"),
            SousTheme(id: "decoration", nom: "Décoration", emoji: "🪞")
        ],
        "Apps / Internet": [
            SousTheme(id: "sociaux", nom: "Réseaux sociaux", emoji: "📱"),
            SousTheme(id: "messagerie", nom: "Messagerie", emoji: "💬"),
            SousTheme(id: "video", nom: "Streaming vidéo", emoji: "▶️"),
            SousTheme(id: "musique", nom: "Musique", emoji: "🎧"),
            SousTheme(id: "shopping", nom: "Shopping", emoji: "🛍️"),
            SousTheme(id: "transport", nom: "Transport", emoji: "🚗"),
            SousTheme(id: "ia", nom: "IA", emoji: "🤖"),
            SousTheme(id: "services", nom: "Services", emoji: "🧰")
        ]
    ]

    private static let classificationsParTheme: [String: [String: Set<String>]] = [
        "Pays": classifications([
            "europe": [
                "FRANCE", "ESPAGNE", "ITALIE", "ALLEMAGNE", "BELGIQUE", "SUISSE", "PORTUGAL",
                "GRECE", "NORVEGE", "SUEDE", "FINLANDE", "ISLANDE", "IRLANDE", "UKRAINE",
                "CROATIE", "MOLDAVIE", "SLOVAQUIE", "SERBIE", "SLOVENIE", "BULGARIE", "ROUMANIE",
                "LITUANIE", "LETTONIE", "ESTONIE", "RUSSIE", "TURQUIE", "GEORGIE", "ARMENIE"
            ],
            "afrique": [
                "MAROC", "EGYPTE", "ALGERIE", "TUNISIE", "KENYA", "NIGERIA", "SENEGAL", "CAMEROUN",
                "SOMALIE", "OUGANDA", "TANZANIE", "ZAMBIE", "ZIMBABWE", "ANGOLA", "MAURICE", "COMORES", "ETHIOPIE",
                "DJIBOUTI", "BOTSWANA", "BURUNDI", "LESOTHO", "ESWATINI", "MALAWI"
            ],
            "asie": [
                "JAPON", "CHINE", "INDE", "EGYPTE", "TURQUIE", "RUSSIE", "VIETNAM", "THAILANDE",
                "ISRAEL", "NEPAL", "GEORGIE", "ARMENIE", "QATAR", "JORDANIE", "CAMBODGE", "MALAISIE",
                "SINGAPOUR", "INDONESIE"
            ],
            "ameriqueNord": ["CANADA", "MEXIQUE"],
            "ameriqueSud": ["BRESIL", "CHILI", "PEROU", "COLOMBIE", "BOLIVIE", "GUYANA", "URUGUAY", "EQUATEUR", "SURINAME"],
            "oceanie": ["AUSTRALIE", "FIDJI", "SAMOA", "TONGA", "KIRIBATI", "TUVALU", "VANUATU", "NAURU", "PALAU"]
        ]),
        "Villes": classifications([
            "france": [
                "PARIS", "LYON", "MARSEILLE", "NICE", "BORDEAUX", "TOULOUSE", "NANTES", "LILLE",
                "STRASBOURG", "RENNES", "MONTPELLIER", "GRENOBLE", "CANNES", "DIJON", "REIMS", "ANGERS",
                "AVIGNON", "BIARRITZ", "COLMAR", "ANNECY", "ROUEN", "CAEN", "BREST", "PERPIGNAN",
                "CLERMONTFERRAND", "LIMOGES", "BESANCON", "AJACCIO", "DUNKERQUE", "LEHAVRE", "POITIERS", "CALVI"
            ],
            "royaumeUni": ["LONDRES"],
            "etatsUnis": ["NEWYORK", "LOSANGELES", "SANFRANCISCO"],
            "espagne": ["MADRID", "BARCELONE"],
            "italie": ["ROME", "NAPLES", "FLORENCE", "MILAN", "VENISE"],
            "allemagne": ["BERLIN"],
            "belgique": ["BRUXELLES"],
            "portugal": ["LISBONNE"],
            "paysBas": ["AMSTERDAM"],
            "grece": ["ATHENES"],
            "turquie": ["ISTANBUL"],
            "tchequie": ["PRAGUE"],
            "autriche": ["VIENNE"],
            "irlande": ["DUBLIN"],
            "maroc": ["MARRAKECH"],
            "suisse": ["GENEVE"],
            "canada": ["MONTREAL"],
            "australie": ["SYDNEY"],
            "emiratsArabesUnis": ["DUBAI"],
            "norvege": ["OSLO"],
            "suede": ["STOCKHOLM"],
            "finlande": ["HELSINKI"],
            "japon": ["TOKYO"],
            "coreeDuSud": ["SEOUL"],
            "chine": ["PEKIN"],
            "estonie": ["TALLINN"],
            "lettonie": ["RIGA"],
            "bulgarie": ["SOFIA"],
            "croatie": ["ZAGREB"],
            "slovenie": ["LJUBLJANA"],
            "russie": ["MOSCOU"],
            "egypte": ["LECAIRE"],
            "mongolie": ["OULANBATOR"],
            "turkmenistan": ["ASHGABAT"],
            "kirghizistan": ["BISCHKEK"],
            "tadjikistan": ["DOUCHANBE"],
            "suriname": ["PARAMARIBO"],
            "lesotho": ["MASERU"],
            "eswatini": ["MBABANE"],
            "groenland": ["NUUK"],
            "monaco": ["MONACO"]
        ]),
        "École": classifications([
            "matieres": [
                "MATHS", "FRANCAIS", "ANGLAIS", "CALCUL", "SCIENCE", "HISTOIRE", "ESPAGNOL", "PHYSIQUE",
                "CHIMIE", "BIOLOGIE", "GEOGRAPHIE", "LITTERATURE", "PHILOSOPHIE", "LECTURE", "SPORT"
            ],
            "fournitures": [
                "CAHIER", "STYLO", "TABLEAU", "LIVRE", "CARTABLE", "TROUSSE", "CRAYON", "GOMME", "FEUILLE",
                "PAPIER", "CLASSEUR", "REGLE", "COMPAS", "PUPITRE", "AGENDA", "PLANNING", "DOSSIER", "EQUERRE", "MARQUEUR"
            ],
            "vieScolaire": [
                "DEVOIR", "CLASSE", "ELEVE", "COURS", "COLLEGE", "LYCEE", "CANTINE", "RENTREE", "BULLETIN", "RECRE",
                "QUESTION", "REPONSE", "EXERCICE", "MATIERE", "LECON", "ETUDE", "TRAVAIL", "PROJET", "CASIER", "SONNERIE",
                "INTERNAT", "PROVISEUR", "PRINCIPAL", "SURVEILLANT", "PUPITRE"
            ],
            "lieux": ["CLASSE", "COLLEGE", "LYCEE", "CANTINE", "CAMPUS", "LABORATOIRE", "AMPHITHEATRE", "BIBLIOTHEQUE", "INTERNAT"],
            "evaluations": [
                "DEVOIR", "EXAMEN", "DIPLOME", "BULLETIN", "NOTE", "QUESTION", "REPONSE", "EXERCICE", "CONTROLE", "CONCOURS",
                "MOYENNE", "BACCALAUREAT", "DISSERTATION", "SOUTENANCE"
            ],
            "superieur": ["ETUDIANT", "CAMPUS", "SEMESTRE", "TRIMESTRE", "RECHERCHE", "LABORATOIRE", "AMPHITHEATRE", "BIBLIOTHEQUE", "DOCTORAT", "SOUTENANCE", "PROJET", "BIBLIOGRAPHIE", "PEDAGOGIE", "DIDACTIQUE"]
        ]),
        "Sport": classifications([
            "collectifs": ["FOOTBALL", "BASKET", "RUGBY", "VOLLEY", "HANDBALL", "EQUIPE", "JOUEUR", "GARDIEN", "ATTAQUE", "DEFENSE"],
            "individuels": ["TENNIS", "GOLF", "NATATION", "CYCLISME", "PETANQUE", "BOWLING", "ESCALADE", "MARATHON", "YOGA", "PILATES", "RANDONNEE", "HYROX", "ATHLETE", "COUREUR"],
            "combat": ["BOXE", "JUDO", "KARATE", "ESCRIME"],
            "aquatiques": ["NATATION", "SURF", "PLONGEE", "VOILE", "PISCINE"],
            "hiver": ["SKI", "SNOWBOARD", "PATINAGE", "BIATHLON"],
            "mecaniques": ["RALLYE", "PILOTE", "CIRCUIT"],
            "athletisme": ["MARATHON", "SPRINT", "RELAIS", "SPRINTER", "CHRONO", "COULOIR", "BATON", "HEPTATHLON", "DECATHLON", "COUREUR"],
            "vocabulaire": [
                "BALLON", "STADE", "MATCH", "SCORE", "EQUIPE", "JOUEUR", "MAILLOT", "RAQUETTE", "PANIER", "ARBITRE", "GARDIEN",
                "MEDAILLE", "TROPHEE", "COURSE", "PISCINE", "FILET", "PASSE", "PENALTY", "DRIBBLE", "PODIUM", "TRIBUNE", "TOURNOI",
                "RECORD", "ENDURANCE", "ATHLETE", "ARBITRAGE", "VESTIAIRE", "ATTAQUE", "DEFENSE", "CHAMPION", "VICTOIRE", "DEFAITE"
            ]
        ]),
        "Musique": classifications([
            "instruments": ["GUITARE", "PIANO", "BATTERIE", "VIOLON", "TROMPETTE", "SAXO", "FLUTE", "BASSE", "ACCORDEON", "HARPE", "ORGUE", "HARMONICA", "TAMBOUR", "PERCUSSION"],
            "genres": ["RAP", "ROCK", "POP", "JAZZ", "TECHNO", "METAL", "SLAM", "SOUL", "BLUES", "FOLK", "ELECTRO", "OPERA"],
            "chant": ["CHANTEUR", "PAROLES", "REFRAIN", "COUPLET", "CHANT", "CHORALE", "SOPRANO", "CONTRALTO", "BATTEUR", "PIANISTE", "SOLO", "BASSISTE"],
            "scene": ["CONCERT", "FESTIVAL", "SCENE", "SPECTACLE", "TOURNEE", "GROUPE", "RADIO", "DANSE", "MUSICIEN"],
            "theorie": ["RYTHME", "PAROLES", "REFRAIN", "COUPLET", "ACCORD", "HARMONIE", "MELODIE", "NOTE", "TEMPO", "GAMME", "SOLFEGE", "PARTITION", "OCTAVE", "ARPEGE", "CADENCE", "LEGATO", "STACCATO", "TREMOLO", "VIBRATO", "OUVERTURE", "SYMPHONIE", "SONATE", "SOLO", "METRONOME"],
            "production": ["MUSIQUE", "CHANSON", "ALBUM", "MICRO", "CASQUE", "AMPLI", "ENCEINTE", "VINYLE", "DISQUE", "CASSETTE", "ORCHESTRE", "BATTERIE", "PIANO", "GUITARE", "TUBE", "HIT", "PLAYLIST", "COMPOSITEUR"]
        ]),
        "Nourriture": classifications([
            "fruits": ["POMME", "BANANE", "ORANGE", "FRAISE", "CERISE", "RAISIN", "MELON", "PASTEQUE", "TOMATE"],
            "legumes": ["TOMATE", "POIVRON", "CAROTTE", "PATATE", "OIGNON", "POIREAU", "EPINARD", "HARICOT", "NAVET", "AUBERGINE", "COURGETTE", "LENTILLE", "ARTICHAUT", "FENOUIL", "ECHALOTE", "TOPINAMBOUR", "PANAIS"],
            "viandesPoissons": ["POULET", "JAMBON", "STEAK", "SAUMON", "CREVETTE", "POISSON", "VIANDE", "SAUCISSE"],
            "feculents": ["PAIN", "PATES", "RIZ", "FRITE", "BAGUETTE", "CROISSANT", "NOUILLES", "COUSCOUS", "POLENTA", "RISOTTO", "BRIOCHE", "TARTINE", "BAGEL"],
            "desserts": ["GATEAU", "CHOCOLAT", "CREPE", "CROISSANT", "GLACE", "COOKIE", "CHIPS", "GAUFRE", "TARTE", "MACARON", "MUFFIN", "BROWNIE", "PANCAKE", "POPCORN", "SORBET", "MOUSSE", "BRIOCHE", "DESSERT", "BISCUIT"],
            "laitiers": ["FROMAGE", "YAOURT", "BEURRE", "CAMEMBERT", "CREME", "RACLETTE", "FONDUE"],
            "plats": ["PIZZA", "BURGER", "SANDWICH", "RACLETTE", "FONDUE", "QUICHE", "OMELETTE", "COUSCOUS", "GASPACHO", "TAPENADE", "RISOTTO", "SALADE"],
            "condiments": ["SEL", "SUCRE", "POIVRE", "FARINE", "HUILE", "VINAIGRE", "MIEL", "CONFITURE", "BEURRE", "CREME", "CEREALES"],
            "boissons": ["CAFE", "THE"]
        ]),
        "Animaux": classifications([
            "mammiferes": [
                "CHAT", "CHIEN", "LION", "TIGRE", "CHEVAL", "ELEPHANT", "OURS", "SINGE", "BALEINE", "PANDA", "LAPIN", "VACHE", "LOUP", "GIRAFE",
                "RENARD", "PANTHERE", "GORILLE", "KOALA", "KANGOUROU", "MOUTON", "SOURIS", "COCHON", "CHEVRE", "ECUREUIL", "BLAIREAU", "LAMA", "CHAMEAU",
                "RAT", "CASTOR", "HERISSON", "CERF", "ANE", "PONEY", "BABOUIN", "MARMOTTE", "DAIM", "SANGLIER", "CHEVREUIL", "LOUTRE", "BELETTE",
                "FURET", "CHACAL", "BISON", "OKAPI", "CARACAL", "TAPIR", "WOMBAT", "GLOUTON", "ZEBRE", "TAUPE"
            ],
            "oiseaux": ["PERROQUET", "CANARD", "POULE", "COQ", "AIGLE", "HIBOU", "FAUCON", "CHOUETTE", "CORBEAU", "CYGNE", "FLAMANT", "MANCHOT", "OIE", "CIGOGNE", "HERON", "DINDON", "ORNITHORYNQUE"],
            "reptiles": ["TORTUE", "SERPENT", "CROCODILE", "LEZARD", "IGUANE", "CRAPAUD"],
            "marins": ["DAUPHIN", "BALEINE", "REQUIN", "ORQUE", "PHOQUE", "PIEUVRE", "CALAMAR", "NARVAL", "MANCHOT"],
            "insectesArachnides": ["PAPILLON", "ABEILLE", "ESCARGOT", "ARAIGNEE", "MOUSTIQUE", "SCORPION", "FOURMI", "LIMACE"],
            "ferme": ["CHEVAL", "VACHE", "LAPIN", "MOUTON", "CANARD", "POULE", "COQ", "COCHON", "CHEVRE", "ANE", "PONEY", "OIE", "DINDON"],
            "sauvages": [
                "LION", "TIGRE", "ELEPHANT", "OURS", "SINGE", "PANDA", "LOUP", "GIRAFE", "RENARD", "PANTHERE", "SERPENT", "GORILLE", "KOALA", "KANGOUROU",
                "CROCODILE", "AIGLE", "ECUREUIL", "HIBOU", "LEZARD", "BLAIREAU", "LAMA", "CHAMEAU", "CASTOR", "HERISSON", "CERF", "FAUCON", "CHOUETTE",
                "CORBEAU", "CYGNE", "FLAMANT", "ORQUE", "PHOQUE", "SCORPION", "BABOUIN", "MARMOTTE", "DAIM", "SANGLIER", "CHEVREUIL", "IGUANE", "LOUTRE",
                "CHACAL", "BISON", "OKAPI", "CARACAL", "TAPIR", "WOMBAT", "NARVAL", "AXOLOTL", "PANGOLIN", "ORNITHORYNQUE", "GLOUTON"
            ]
        ]),
        "Voyage": classifications([
            "transports": ["AVION", "TRAIN", "BATEAU", "TAXI", "BUS", "VELO", "METRO", "FERRY", "NAVIRE", "YACHT", "CATAMARAN", "CROISIERE", "TELEPHERIQUE", "FUNICULAIRE"],
            "hebergement": ["HOTEL", "CAMPING", "AUBERGE", "RESORT", "TENTE", "CABINE", "BIVOUAC", "CARAVANSERAIL"],
            "formalites": ["PASSEPORT", "BILLET", "DOUANE", "TICKET", "VISA", "DOUANIER", "EMBARQUEMENT"],
            "destinations": ["PLAGE", "MONTAGNE", "OCEAN", "ILE", "DESERT", "LAC", "VALLEE", "RIVAGE", "LITTORAL", "PLATEAU", "PAYSAGE", "VILLAGE", "PHARE", "RANDONNEE", "TREK", "TRANSATLANTIQUE"],
            "tourisme": ["PHOTO", "MUSEE", "CHATEAU", "CROISIERE", "TOURISTE", "MONUMENT", "EXCURSION", "GUIDE", "VACANCES", "SEJOUR", "CROISIERISTE"],
            "orientation": ["GPS", "ROUTE", "CARTE", "BOUSSOLE", "ATLAS", "AUTOROUTE", "FRONTIERE", "QUAI", "ITINERAIRE", "TERMINAL", "PORT", "AEROPORT", "AEROGARE", "DEPART", "ARRIVEE", "ESCALE", "TRANSFERT", "VOYAGE", "VOYAGEUR", "BAGAGE", "VALISE"]
        ]),
        "Cinéma": classifications([
            "genres": ["COMEDIE", "HORREUR", "ACTION", "DRAME", "AVENTURE", "ROMANCE", "THRILLER", "WESTERN", "MUSICAL", "FANTASY", "BIOPIC", "ANIMATION", "DESSIN", "FICTION"],
            "metiers": ["ACTEUR", "ACTRICE", "REALISATEUR", "SCENARISTE", "PRODUCTEUR", "CASCADEUR", "FIGURANT"],
            "tournage": ["CAMERA", "DECOR", "COSTUME", "PRISE", "TOURNAGE", "STUDIO", "ACTEUR", "ACTRICE", "FIGURANT", "CASCADEUR"],
            "diffusion": ["CINEMA", "FILM", "ECRAN", "STAR", "SERIE", "SALLE", "OSCAR", "HOLLYWOOD", "SAISON", "EPISODE", "SAGA", "AFFICHE", "SEANCE", "PREMIERE", "PALME", "GENRE", "VEDETTE", "CESAR", "TEASER"],
            "narration": ["HEROS", "VILAIN", "SCENARIO", "ROLE", "TITRE", "DIALOGUE", "INTRIGUE", "REPLIQUE", "HEROINE", "CAMEO", "MONSTRE", "SUSPENSE", "PITCH", "GENERIQUE", "VOIXOFF", "TEASER"],
            "technique": ["CAMERA", "IMAGE", "SON", "MONTAGE", "DOUBLAGE", "PLAN", "ANGLE", "LUMIERE", "EFFET", "FOCUS", "BOBINE", "PELICULE", "TRAVELLING", "STORYBOARD", "RACCORD", "CHROMAKEY", "STEADICAM", "DIAGETIQUE", "DOLLY", "ETALONNAGE"]
        ]),
        "Techno": classifications([
            "materiel": ["CLAVIER", "SOURIS", "TELEPHONE", "CONSOLE", "ROBOT", "ECRAN", "TABLETTE", "CHARGEUR", "CABLE", "MANETTE", "ECOUTEUR", "PIXEL", "WEBCAM", "CAPTEUR", "DISQUE", "CARTE", "PUCE", "LASER", "LED", "PROCESSEUR", "JOYSTICK"],
            "reseau": ["INTERNET", "WIFI", "EMAIL", "VIDEO", "SITE", "BLUETOOTH", "ROUTEUR", "MODEM", "LIEN", "RESEAU", "CLOUD", "SERVEUR", "COURRIEL", "BROWSER", "LATENCE", "BANDEPASSANTE", "PROTOCOLE", "SOCKET", "MESSAGE"],
            "programmation": ["CODE", "PROGRAMME", "CODAGE", "ALGORITHME", "FRAMEWORK", "BACKEND", "FRONTEND", "COMPILATEUR", "TERMINAL", "ASSEMBLEUR", "SERIALISATION", "ORCHESTRATION", "MICROCODE"],
            "cybersecurite": ["VIRUS", "PIRATE", "SECURITE", "FIREWALL", "LOGIN", "CHIFFREMENT", "CRYPTO", "CRYPTOGRAPHIE"],
            "systemes": ["ANDROID", "GOOGLE", "APPLI", "LOGICIEL", "FIRMWARE", "KERNEL", "CACHE", "TERMINAL", "HYPERVISEUR", "CONTENEUR", "VIRTUALISATION", "MEMOIRE", "STOCKAGE", "MENU", "BOUTON"],
            "donnees": ["FICHIER", "DOSSIER", "IMAGE", "AUDIO", "PIXEL", "DONNEE", "DATABASE", "DATA", "STOCKAGE", "MEMOIRE", "PROFIL", "ICONE", "COMPTE"],
            "ia": ["ROBOT", "ALGORITHME", "DATA", "PROGRAMME"]
        ]),
        "Nature": classifications([
            "vegetation": ["ARBRE", "FLEUR", "FORET", "PLANTE", "HERBE", "JUNGLE", "PRAIRIE", "FEUILLE", "BUISSON", "RACINE", "GRAINE", "POLLEN", "SEVE", "MOUSSE", "ALGUE", "MANGROVE", "TAIGA", "TUNDRA", "CONIFERE", "LITTORAL"],
            "eau": ["MER", "OCEAN", "PLAGE", "RIVIERE", "FLEUVE", "LAC", "ILE", "CASCADE", "ETANG", "RUISSEAU", "SOURCE", "DELTA", "LAVE", "ESTUAIRE", "RECIF", "GLACIER", "ALGUE", "MANGROVE"],
            "reliefs": ["MONTAGNE", "VOLCAN", "SENTIER", "FALAISE", "COLLINE", "VALLEE", "CANYON", "DUNE", "ROCHER", "PIERRE", "GLACIER"],
            "meteo": ["SOLEIL", "PLUIE", "NEIGE", "NUAGE", "ORAGE", "VENT", "TEMPETE", "BRUME", "ECLAIR", "TONNERRE", "GIVRE", "ROSEE", "ARCENCIEL", "AUBE", "HORIZON"],
            "saisons": ["PRINTEMPS", "AUTOMNE", "HIVER", "NEIGE", "GIVRE", "ROSEE"],
            "geologie": ["VOLCAN", "LAVE", "ROCHER", "PIERRE", "MINERAL", "CRISTAL", "GRAINE", "GLACIER", "PERMAFROST", "DUNE", "RECIF", "SABLE"],
            "ecosystemes": ["FORET", "JUNGLE", "PRAIRIE", "SAVANE", "OASIS", "MARAIS", "TOURBIERE", "TAIGA", "TUNDRA", "BIOSPHERE", "MANGROVE", "PHYTOPLANCTON", "ANIMAL", "OISEAU", "INSECTE", "ESPECE", "LUNE", "ETOILE"]
        ]),
        "Objets maison": classifications([
            "cuisine": ["TABLE", "VERRE", "TASSE", "ASSIETTE", "CUILLERE", "COUTEAU", "FOUR", "POELE", "CASSEROLE", "MUG", "EPONGE", "BOUTEILLE", "CAFETIERE", "PLATEAU", "MIXEUR", "NAPPE", "POT", "LOUCHE", "MANDOLINE", "DECAPSULEUR", "PASSOIRE", "ECUMOIRE", "DESSOUSPLAT", "ESSOREUSE"],
            "chambre": ["LIT", "ARMOIRE", "COUSSIN", "OREILLER", "MATELAS", "REVEIL", "COMMODE", "CINTRE"],
            "salon": ["CANAPE", "FAUTEUIL", "TABLE", "LAMPE", "TAPIS", "BUREAU", "BANC", "MEUBLE", "RIDEAU", "CADRE", "TABLEAU", "BOUGIE", "CHAISE", "TABOURET"],
            "salleBain": ["SAVON", "SERVIETTE", "BROSSE", "SECHOIR", "MIROIR", "SEAU"],
            "rangement": ["ARMOIRE", "BOITE", "TIROIR", "ETAGERE", "PLACARD", "PANIER", "COMMODE", "BUFFET", "MEUBLE", "CINTRE", "ETENDOIR"],
            "bricolage": ["BALAI", "POUBELLE", "PINCE", "MARTEAU", "TOURNEVIS", "CLOU", "PELLE", "PERCEUSE", "ECHELLE", "ESCABEAU", "ALLUMETTE", "SERREJOINT", "CHAUSSEPIED", "TRINGLE"],
            "electrique": ["LAMPE", "FRIGO", "FOUR", "HORLOGE", "REVEIL", "PRISE", "AMPOULE", "RADIATEUR", "CABLE", "RALLONGE", "ABATJOUR", "SECHOIR", "CAFETIERE"],
            "decoration": ["MIROIR", "RIDEAU", "TAPIS", "VASE", "NAPPE", "CADRE", "TABLEAU", "BOUGIE", "VOLET", "POIGNEE", "POT", "PATERE", "VIDEPOCHE", "DESSOUSPLAT", "PORTE", "FENETRE"]
        ]),
        "Apps / Internet": classifications([
            "sociaux": ["INSTAGRAM", "TIKTOK", "SNAPCHAT", "FACEBOOK", "TWITTER", "LINKEDIN", "PINTEREST", "REDDIT", "HASHTAG", "RESEAU", "PROFIL"],
            "messagerie": ["WHATSAPP", "DISCORD", "TELEGRAM", "MESSAGE", "TINDER", "NOTIFICATION", "IDENTIFIANT", "COMPTE"],
            "video": ["YOUTUBE", "NETFLIX", "TWITCH", "STREAMING", "PLATEFORME"],
            "musique": ["SPOTIFY", "DEEZER", "SHAZAM", "PODCAST"],
            "shopping": ["AMAZON", "VINTED", "LEBONCOIN", "PAYPAL", "DELIVEROO", "ABONNEMENT"],
            "transport": ["UBER", "BLABLACAR", "WAZE", "AIRBNB", "NAVIGATEUR"],
            "ia": ["CHATGPT", "ALGORITHME", "DEEPFAKE"],
            "services": [
                "GOOGLE", "DOCTOLIB", "AIRBNB", "PAYPAL", "DUOLINGO", "WIKIPEDIA", "PRONOTE", "CANVA", "NOTION", "NAVIGATEUR", "COMPTE", "PROFIL",
                "CLOUD", "FORUM", "BLOG", "PLATEFORME", "ABONNEMENT", "MOTDEPASSE", "IDENTIFIANT", "SERVEUR", "DOMAINE", "LIEN", "VPN", "FIREWALL",
                "PHISHING", "COOKIE", "CAPTCHA", "DNS", "HTTP", "URL", "API", "CACHE", "CYBERSECURITE", "MODERATION", "RANSOMWARE", "BOTNET", "SPAM",
                "DNSSEC", "REVERSEPROXY", "CDN", "OAUTH", "WEBSOCKET", "TOR", "FEDIVERSE"
            ]
        ])
    ]

    private static let nomsPaysVilles: [String: String] = [
        "france": "France", "royaumeUni": "Royaume-Uni", "etatsUnis": "États-Unis", "espagne": "Espagne",
        "italie": "Italie", "allemagne": "Allemagne", "belgique": "Belgique", "portugal": "Portugal",
        "paysBas": "Pays-Bas", "grece": "Grèce", "turquie": "Turquie", "tchequie": "Tchéquie",
        "autriche": "Autriche", "irlande": "Irlande", "maroc": "Maroc", "suisse": "Suisse", "canada": "Canada",
        "australie": "Australie", "emiratsArabesUnis": "Émirats arabes unis", "norvege": "Norvège", "suede": "Suède",
        "finlande": "Finlande", "japon": "Japon", "coreeDuSud": "Corée du Sud", "chine": "Chine", "estonie": "Estonie",
        "lettonie": "Lettonie", "bulgarie": "Bulgarie", "croatie": "Croatie", "slovenie": "Slovénie", "russie": "Russie",
        "egypte": "Égypte", "mongolie": "Mongolie", "turkmenistan": "Turkménistan", "kirghizistan": "Kirghizistan",
        "tadjikistan": "Tadjikistan", "suriname": "Suriname", "lesotho": "Lesotho", "eswatini": "Eswatini",
        "groenland": "Groenland", "monaco": "Monaco"
    ]

    static func classificationsPour(_ nom: String) -> [String: Set<String>] {
        classificationsParTheme[nom] ?? [:]
    }

    static func sousThemesPour(
        nom: String,
        classifications: [String: Set<String>]
    ) -> [SousTheme] {
        let presents = Set(classifications.values.flatMap { $0 })

        if nom == "Villes" {
            return presents
                .sorted { (nomsPaysVilles[$0] ?? $0).localizedCaseInsensitiveCompare(nomsPaysVilles[$1] ?? $1) == .orderedAscending }
                .map { SousTheme(id: $0, nom: nomsPaysVilles[$0] ?? $0, emoji: "🌍") }
        }

        return (definitionsParTheme[nom] ?? []).filter { presents.contains($0.id) }
    }
}
