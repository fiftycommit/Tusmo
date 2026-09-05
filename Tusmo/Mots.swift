//
//  Mots.swift
//  Tusmo
//
//  Banque de mots pour le mode solo : termes jouables, sans accent ni tiret.
//  Leur difficulté dépend de leur familiarité, pas de leur longueur.
//  Les couples faciles/moyens/difficiles de undercover.gg/fr/words servent
//  aussi de repère pour les ajouts français réellement reconnaissables.
//

import Foundation

private enum SurchargesNotoriete {
    /// Barème de repli pour une éventuelle banque ajoutée sans calibration.
    /// Les thèmes actuels utilisent `calibrageParTheme` ci-dessous.
    static let parTheme: [String: [String: Int]] = [
        "Sport": [
            "BALLON": 75, "PANIER": 75, "FOOTBALL": 100, "BASKET": 92,
            "TENNIS": 90, "RUGBY": 78, "STADE": 75, "SCORE": 75,
            "MATCH": 80, "BUT": 78, "EQUIPE": 80, "JOUEUR": 78,
            "CHAMPION": 94, "VICTOIRE": 94, "DEFAITE": 90, "PASSE": 94,
            "TIR": 75, "GOLF": 45, "SKI": 65, "SURF": 45,
            "RANDONNEE": 55, "ESCALADE": 55, "YOGA": 55, "PILATES": 35,
            "HIROX": 15, "BOXE": 78, "JUDO": 70, "KARATE": 62,
            "NATATION": 75, "CYCLISME": 70, "VOLLEY": 60, "HANDBALL": 60,
            "PETANQUE": 75, "BOWLING": 60, "MARATHON": 55, "ESCRIME": 55,
            "PLONGEE": 45, "VOILE": 45, "PATINAGE": 45, "RALLYE": 45,
            "SNOWBOARD": 45
        ],
        "Musique": [
            "GUITARE": 100, "BATTERIE": 96, "CONCERT": 100, "PIANO": 100,
            "VIOLON": 94, "ALBUM": 95, "CHANSON": 100, "NOTE": 100,
            "RADIO": 100, "RAP": 100, "ROCK": 100, "POP": 100,
            "JAZZ": 94, "OPERA": 90, "HIT": 95, "TUBE": 94,
            "DANSER": 96, "GROUPE": 100, "SOLO": 90,
            "PIAF": 85, "AZNAVOUR": 80, "STROMAE": 80, "ANGELE": 70,
            "DAFTPUNK": 75, "JUSTICE": 60, "ACCORDEON": 65,
            "HARMONICA": 55, "SLAM": 55
        ],
        "Nourriture": [
            "PIZZA": 100, "GATEAU": 100, "FROMAGE": 100, "SALADE": 96,
            "POULET": 98, "CREPE": 98, "BURGER": 100, "CHOCOLAT": 100,
            "TOMATE": 100, "PATES": 100, "BANANE": 100, "GLACE": 100,
            "SEL": 100, "SUCRE": 100, "BEURRE": 98, "POMME": 100,
            "ORANGE": 98, "FRAISE": 98, "RIZ": 100, "STEAK": 96,
            "COOKIE": 96, "CHIPS": 98, "PAIN": 100, "CROISSANT": 100,
            "FONDUE": 85, "QUICHE": 80, "MACARON": 80, "CAFE": 100,
            "THE": 100, "VIN": 90, "CHAMPAGNE": 85, "CAMEMBERT": 80
        ],
        "Animaux": [
            "CHIEN": 100, "CHAT": 100, "LION": 100, "TIGRE": 100,
            "OURS": 100, "ELEPHANT": 100, "SINGE": 100, "CHEVAL": 100,
            "VACHE": 98, "POULE": 98, "COQ": 98,
            "PANDA": 100, "KOALA": 96, "PAPILLON": 98, "ABEILLE": 96,
            "FOURMI": 96, "DAUPHIN": 98, "BALEINE": 98, "REQUIN": 100,
            "GIRAFE": 100, "SERPENT": 100, "TORTUE": 100, "RENARD": 96,
            "LOUP": 98, "ESCARGOT": 85, "LIMACE": 65, "PIEUVRE": 80,
            "CALAMAR": 55, "CIGOGNE": 60, "HERON": 55,
            "MARMOTTE": 65
        ],
        "Voyage": [
            "VALISE": 100, "AVION": 100, "PLAGE": 100, "HOTEL": 100,
            "BILLET": 98, "PASSEPORT": 100, "TRAIN": 100, "CAMPING": 96,
            "AEROPORT": 100, "BAGAGE": 98, "CARTE": 100, "GPS": 100,
            "OCEAN": 98, "ILE": 100, "PORT": 94, "ROUTE": 100,
            "BUS": 100, "TAXI": 100, "VELO": 98, "BATEAU": 100,
            "MUSEE": 98, "CHATEAU": 98, "PHOTO": 100, "VISA": 96,
            "TENTE": 94, "PARIS": 100, "LYON": 85, "MARSEILLE": 80,
            "NICE": 80, "BRETAGNE": 75, "LOUVRE": 75, "CANNES": 70,
            "COLMAR": 55, "MONTBLANC": 70
        ],
        "Cinéma": [
            "ACTEUR": 100, "ACTRICE": 100, "CAMERA": 100, "ECRAN": 100,
            "COMEDIE": 96, "HORREUR": 100, "CINEMA": 100, "STUDIO": 94,
            "HEROS": 100, "VILAIN": 98, "DRAME": 98, "ACTION": 100,
            "ROMANCE": 98, "AVENTURE": 100, "SERIE": 100, "STAR": 100,
            "TICKET": 96, "OSCAR": 100, "NETFLIX": 100, "HOLLYWOOD": 100,
            "IMAGE": 100, "SON": 100, "DIALOGUE": 96, "MARVEL": 100,
            "DISNEY": 100, "STARWARS": 100, "PIXAR": 90, "ASTERIX": 85,
            "TINTIN": 85
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
            "VIDEO": 100, "AUDIO": 98, "VIRUS": 100, "ANDROID": 100,
            "GOOGLE": 100, "NETFLIX": 100, "SPOTIFY": 95, "DEEZER": 85,
            "DISCORD": 80, "TIKTOK": 90, "INSTAGRAM": 90, "UBER": 80,
            "VINTED": 75, "BLABLACAR": 75, "CHATGPT": 90
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
            "MAGGIE": 100,
            // Les références que l'on cite facilement en France.
            "FLANDERS": 90, "BURNS": 88, "SMITHERS": 86, "KRUSTY": 84,
            "MILHOUSE": 82, "MOE": 80, "APU": 78, "WIGGUM": 76,
            "RALPH": 74, "NELSON": 72, "SKINNER": 70, "EDNA": 68,
            "BARNEY": 66, "SIDESHOW": 64, "BOB": 64,
            "ABRAHAM": 62, "PATTY": 60, "SELMA": 58, "LOVEJOY": 56,
            "HIBBERT": 54, "OTTO": 52, "LENNY": 50, "CARL": 48,
            "WILLIE": 46, "KENT": 44,
            // Personnages vus plus rarement ou surtout connus des fans.
            "SEYMOUR": 40, "QUIMBY": 40, "CLETUS": 38, "ITCHY": 38,
            "SCRATCHY": 38, "BARTMAN": 36, "SANTA": 36, "SNOWBALL": 34,
            "KANG": 30, "KODOS": 30, "HERB": 30, "MAUDE": 30,
            "TODD": 28, "ROD": 28, "DOLPH": 28, "JIMBO": 28,
            "KIRK": 25, "MARVIN": 25, "CLANCY": 25, "HERMAN": 25,
            "MANJULA": 25, "LUANN": 20, "RUTH": 20, "AMBER": 20,
            "MINDY": 20, "GIL": 20, "LURLEEN": 20, "FINK": 15
        ],
        "South Park": [
            "STAN": 100, "KYLE": 100, "CARTMAN": 100, "KENNY": 100,
            "BUTTERS": 100,
            // Personnages récurrents, mais moins centraux que le quatuor.
            "WENDY": 78, "RANDY": 82, "SHARON": 62, "SHELLEY": 55,
            "TWEEK": 72, "JIMMY": 72, "CRAIG": 72, "CHEF": 78,
            "IKE": 68, "TIMMY": 68, "MRHANKY": 55,
            // Personnages ponctuels ou références de fans.
            "SATAN": 48, "SADDAM": 42, "PRINCIPAL": 55, "GARRISON": 55,
            "TOKEN": 52, "MANBEAR": 35, "DAMIEN": 35, "TOWELIE": 50
        ],
        "Apple": [
            // Produits que presque tout le monde identifie.
            "APPLE": 100, "IPHONE": 100, "MACBOOK": 100, "IPAD": 100,
            "IPOD": 100, "IMAC": 95, "AIRPODS": 95,
            // Produits Apple connus, mais moins systématiques.
            "VISIONPRO": 75, "WATCH": 75, "AIRTAG": 75, "HOMEPOD": 75,
            "APPLETV": 75, "PENCIL": 75,
            // Technologies et services très associés à Apple.
            "AIRPLAY": 55, "AIRDROP": 55, "FACETIME": 55, "SIRI": 55,
            "ICLOUD": 55, "SAFARI": 55, "IMESSAGE": 55, "MACOS": 55,
            "IOS": 55, "TOUCHID": 55, "MAGSAFE": 55, "APPLEPAY": 55,
            "APPSTORE": 55, "CARPLAY": 55,
            // Technologies plus pointues ou moins immédiatement associées.
            "HANDOFF": 35, "FACEID": 35, "HOMEKIT": 35, "APPLEID": 35,
            "APPLECARE": 35, "AIRPRINT": 35, "APPLEONE": 35, "WATCHOS": 35,
            "TVOS": 35,
            // Outils et technologies Apple plus spécialisés.
            "SWIFT": 15, "SWIFTUI": 15, "XCODE": 15, "ARKIT": 15,
            "COREML": 15, "METAL": 15, "DARWIN": 15, "QUICKTIME": 15,
            "ITUNES": 15, "KEYNOTE": 15, "NUMBERS": 15, "LOGICPRO": 15,
            "FINALCUT": 15, "MOTION": 15
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
            "CAFETIERE": 96, "RADIATEUR": 96
        ]
    ]

    /// Transforme des groupes éditoriaux en poids continus, sans confondre
    /// longueur et difficulté. Chaque groupe reste dans sa tranche de niveau
    /// et conserve son ordre de familiarité à l'intérieur de cette tranche.
    private static func poidsParGroupes(
        debutant: [String] = [],
        apprenti: [String] = [],
        confirme: [String] = [],
        expert: [String] = [],
        maitre: [String] = []
    ) -> [String: Int] {
        let groupes: [([String], ClosedRange<Int>)] = [
            (debutant, 80...100),
            (apprenti, 60...79),
            (confirme, 40...59),
            (expert, 20...39),
            (maitre, 1...19)
        ]

        return groupes.reduce(into: [String: Int]()) { resultats, groupe in
            let (mots, plage) = groupe
            let amplitude = plage.upperBound - plage.lowerBound
            let denominateur = max(mots.count - 1, 1)

            for (index, mot) in mots.enumerated() {
                let poids = plage.upperBound - Int(
                    (Double(index) / Double(denominateur) * Double(amplitude)).rounded()
                )
                resultats[mot.uppercased()] = poids
            }
        }
    }

    /// Calibration complète des banques générales. Les groupes sont écrits
    /// comme le ferait un joueur français : références immédiates, éléments
    /// courants du thème, puis termes plus spécialisés ou moins mémorables.
    static let calibrageParTheme: [String: [String: Int]] = [
        "Sport": poidsParGroupes(
            debutant: ["FOOTBALL", "BASKET", "TENNIS"],
            apprenti: [
                "RUGBY", "NATATION", "CYCLISME", "BOXE", "JUDO", "PETANQUE",
                "MAILLOT", "BALLON", "PANIER", "RAQUETTE", "MATCH", "BUT", "SCORE", "STADE",
                "EQUIPE", "JOUEUR", "SKI", "HANDBALL", "VOLLEY"
            ],
            confirme: [
                "KARATE", "BOWLING", "BALLE", "FILET", "CHAMPION", "VICTOIRE",
                "DEFAITE", "MEDAILLE", "TROPHEE", "PASSE", "TIR", "RANDONNEE",
                "ESCALADE", "MARATHON", "ESCRIME", "PLONGEE", "YOGA", "SURF",
                "GOLF", "VOILE", "PATINAGE", "RALLYE", "SNOWBOARD"
            ],
            expert: [
                "PILATES", "ARBITRE", "GARDIEN", "VESTIAIRE", "PODIUM", "TRIBUNE",
                "PENALTY", "DRIBBLE", "SPRINT", "COUREUR", "ATHLETE", "COACH",
                "TOURNOI", "RECORD", "ATTAQUE", "DEFENSE", "BATON", "LIGNE",
                "COULOIR", "CHRONO", "ENDURANCE", "VITESSE", "SPRINTER", "PISCINE",
                "PILOTE", "MUSCLE", "ARBITRAGE", "ECHANGE", "RELAIS", "CIRCUIT"
            ],
            maitre: ["HIROX"]
        ),
        "Musique": poidsParGroupes(
            debutant: [
                "GUITARE", "PIANO", "BATTERIE", "CONCERT", "CHANSON", "RADIO",
                "RAP", "ROCK", "POP", "ALBUM", "PIAF"
            ],
            apprenti: [
                "VIOLON", "CHANTEUR", "RYTHME", "PAROLES", "SCENE", "CASQUE",
                "MUSICIEN", "GROUPE", "DANSER", "FESTIVAL", "SPECTACLE", "TUBE",
                "HIT", "AZNAVOUR", "STROMAE", "DAFTPUNK", "OPERA", "SALLE"
            ],
            confirme: [
                "MELODIE", "REFRAIN", "COUPLET", "TROMPETTE", "ACCORD", "TAMBOUR",
                "HARMONIE", "BATTEUR", "PIANISTE", "SAXO", "FLUTE", "BASSE", "MICRO",
                "AMPLI", "ENCEINTE", "NOTE", "CHANT", "DANSEUR", "PUBLIC", "TOURNEE",
                "VINYLE", "DISQUE", "PLAYLIST", "ANGELE", "JUSTICE", "ACCORDEON",
                "SLAM", "JAZZ", "SOUL", "BLUES", "FOLK", "TECHNO", "ELECTRO", "METAL"
            ],
            expert: [
                "SILENCE", "ORCHESTRE", "HARPE", "ORGUE", "BASSISTE", "TEMPO", "GAMME",
                "PARTITION", "SOLFEGE", "CHORALE", "CASSETTE", "AUTEUR", "COMPOSER",
                "HARMONICA", "OUVERTURE", "SOLO"
            ],
            maitre: []
        ),
        "Nourriture": poidsParGroupes(
            debutant: [
                "PIZZA", "PAIN", "GATEAU", "FROMAGE", "CHOCOLAT", "PATES", "BURGER",
                "CREPE", "CROISSANT", "POMME", "BANANE", "GLACE", "SALADE"
            ],
            apprenti: [
                "POULET", "DESSERT", "TOMATE", "BAGUETTE", "SANDWICH", "YAOURT",
                "RACLETTE", "RIZ", "CAFE", "THE", "COOKIE", "CHIPS", "BEURRE", "SUCRE",
                "SEL", "ORANGE", "FRAISE", "GAUFRE", "TARTE", "JAMBON", "STEAK",
                "FONDUE", "QUICHE", "MACARON", "CAMEMBERT"
            ],
            confirme: [
                "POIVRON", "POIVRE", "FARINE", "HUILE", "VINAIGRE", "MIEL", "CONFITURE",
                "CEREALES", "BISCUIT", "TARTINE", "BRIOCHE", "BAGEL", "CERISE", "RAISIN",
                "MELON", "CAROTTE", "PATATE", "OIGNON", "POISSON", "VIANDE", "SAUCISSE",
                "OMELETTE", "CREME", "MOUSSE", "MUFFIN", "BROWNIE", "PANCAKE", "POPCORN",
                "NOUILLES", "COUSCOUS", "VIN", "CHAMPAGNE"
            ],
            expert: [
                "PASTEQUE", "AIL", "POIREAU", "EPINARD", "HARICOT", "SAUMON", "THON",
                "CREVETTE", "SORBET"
            ],
            maitre: []
        ),
        "Animaux": poidsParGroupes(
            debutant: [
                "CHAT", "CHIEN", "LION", "TIGRE", "CHEVAL", "ELEPHANT", "OURS", "SINGE",
                "DAUPHIN", "BALEINE", "PANDA", "LAPIN"
            ],
            apprenti: [
                "RENARD", "PANTHERE", "TORTUE", "PERROQUET", "GIRAFE", "SERPENT", "REQUIN",
                "ZEBRE", "GORILLE", "KOALA", "KANGOUROU", "LOUP", "VACHE", "MOUTON",
                "CANARD", "POULE", "COQ", "PAPILLON", "ABEILLE", "ESCARGOT", "PINGOUIN",
                "CROCODILE"
            ],
            confirme: [
                "ECUREUIL", "HIBOU", "LEZARD", "ARAIGNEE", "BLAIREAU", "BABOUIN", "LAMA",
                "CHAMEAU", "RAT", "SOURIS", "CASTOR", "HERISSON", "CERF", "CHEVRE", "COCHON",
                "ANE", "PONEY", "OIE", "AIGLE", "FAUCON", "CHOUETTE", "CORBEAU", "CYGNE",
                "FLAMANT", "MANCHOT", "ORQUE", "PHOQUE", "MOUSTIQUE", "CRAPAUD", "SCORPION",
                "FOURMI", "MARMOTTE", "CIGOGNE", "HERON", "PIEUVRE"
            ],
            expert: ["LIMACE", "TAUPE"],
            maitre: ["CALAMAR", "DAIM", "SANGLIER", "CHEVREUIL", "DINDON", "IGUANE"]
        ),
        "Voyage": poidsParGroupes(
            debutant: [
                "AVION", "TRAIN", "VALISE", "PLAGE", "HOTEL", "PASSEPORT", "AEROPORT",
                "BILLET", "PARIS"
            ],
            apprenti: [
                "DOUANE", "MONTAGNE", "CAMPING", "BAGAGE", "CARTE", "GPS", "ROUTE", "BUS",
                "TAXI", "VELO", "BATEAU", "PHOTO", "MUSEE", "CHATEAU", "OCEAN", "ILE",
                "CROISIERE", "TOURISTE", "TOURISME", "SEJOUR", "TICKET", "TENTE", "LYON",
                "MARSEILLE", "NICE", "BRETAGNE", "CANNES"
            ],
            confirme: [
                "DESERT", "ESCALE", "RANDONNEE", "BOUSSOLE", "VOYAGEUR", "DEPART", "ARRIVEE",
                "GUIDE", "ATLAS", "AUBERGE", "VILLAGE", "PAYSAGE", "LAC", "PLATEAU", "VALLEE",
                "RIVAGE", "PORT", "PHARE", "METRO", "FERRY", "CABINE", "MONUMENT", "VISA",
                "LOUVRE", "MONTBLANC"
            ],
            expert: [
                "DESTIN", "VACANCIER", "AUTOROUTE", "PONT", "TUNNEL", "NAVIRE", "TOUR", "TEMPLE",
                "PALAIS", "RANDO", "SOUVENIR", "FRONTIERE", "QUAI"
            ],
            maitre: ["RESORT", "YACHT", "PLAZA", "TREK", "COLMAR"]
        ),
        "Cinéma": poidsParGroupes(
            debutant: [
                "CINEMA", "ACTEUR", "ACTRICE", "CAMERA", "ECRAN", "STAR", "NETFLIX", "MARVEL",
                "DISNEY", "STARWARS", "SERIE", "HEROS"
            ],
            apprenti: [
                "COMEDIE", "HORREUR", "ACTION", "AVENTURE", "DRAME", "VILAIN", "ROMANCE", "THRILLER",
                "ANIMATION", "DESSIN", "SALLE", "TICKET", "OSCAR", "HOLLYWOOD", "PIXAR", "ASTERIX",
                "TINTIN", "SAISON", "EPISODE", "SAGA"
            ],
            confirme: [
                "SUSPENSE", "TOURNAGE", "REPLIQUE", "SCENARIO", "DECOR", "COSTUME", "MONTAGE", "SEANCE",
                "AFFICHE", "DOUBLAGE", "STUDIO", "INTRIGUE", "CAMEO", "HEROINE", "MONSTRE", "FICTION",
                "WESTERN", "MUSICAL", "VEDETTE", "ROLE", "TITRE", "IMAGE", "SON", "DIALOGUE", "GENRE",
                "RIRE", "LARME", "CESAR", "CANNES"
            ],
            expert: [
                "FANTASY", "BIOPIC", "PITCH", "PRISE", "PLAN", "ANGLE", "FOCUS", "LUMIERE", "EFFET",
                "BANDE", "BOBINE", "PELICULE", "PREMIERE", "PALME", "TEASER"
            ],
            maitre: []
        ),
        "École": poidsParGroupes(
            debutant: [
                "CAHIER", "STYLO", "DEVOIR", "EXAMEN", "CLASSE", "TABLEAU", "ELEVE", "COURS", "LIVRE",
                "COLLEGE", "LYCEE", "CARTABLE", "TROUSSE", "CRAYON", "GOMME"
            ],
            apprenti: [
                "CANTINE", "DIPLOME", "LECTURE", "CALCUL", "ETUDIANT", "RENTREE", "BULLETIN", "PUPITRE",
                "NOTE", "FRANCAIS", "ANGLAIS", "MATHS", "SPORT", "RECRE", "QUESTION", "REPONSE",
                "EXERCICE", "CONTROLE", "FEUILLE", "PAPIER"
            ],
            confirme: [
                "MANUEL", "ETUDE", "MATIERE", "LECON", "MOYENNE", "TRAVAIL", "SCIENCE", "HISTOIRE",
                "GEO", "ESPAGNOL", "PHYSIQUE", "CHIMIE", "BIOLOGIE", "ARTS", "SEMESTRE", "TRIMESTRE",
                "AGENDA", "PLANNING", "DOSSIER", "CLASSEUR", "REGLE", "COMPAS", "EQUERRE", "MARQUEUR",
                "ECRAN", "PROJET", "ROMAN", "RESULTAT", "CASIER", "SONNERIE"
            ],
            expert: ["POINTE", "TABLETTE", "POESIE", "CONCOURS", "CAMPUS", "COULOIR", "UNIFORME", "RECHERCHE"],
            maitre: []
        ),
        "Techno": poidsParGroupes(
            debutant: [
                "INTERNET", "CLAVIER", "SOURIS", "CONSOLE", "ROBOT", "DRONE", "MOBILE", "WIFI", "CODE",
                "EMAIL", "VIDEO", "ANDROID", "GOOGLE", "NETFLIX"
            ],
            apprenti: [
                "CHARGEUR", "CABLE", "FICHIER", "MANETTE", "ECOUTEUR", "MESSAGE", "TABLETTE", "PIXEL",
                "APP", "APPLI", "SITE", "CLOUD", "COMPTE", "DOSSIER", "MENU", "BOUTON", "VIRUS", "CHATGPT",
                "SPOTIFY", "TIKTOK", "INSTAGRAM", "DISCORD", "RESEAU", "IMAGE", "AUDIO"
            ],
            confirme: [
                "LOGICIEL", "MEMOIRE", "CAPTEUR", "PIRATE", "MOTEUR", "WEBCAM", "SERVEUR", "ROUTEUR", "MODEM",
                "BLUETOOTH", "PROGRAMME", "CODAGE", "DONNEE", "COURRIEL", "PAGE", "LIEN", "JOYSTICK", "DEEZER",
                "UBER", "VINTED", "BLABLACAR", "SECURITE", "DISQUE", "CARTE", "PUCE", "LASER", "LED"
            ],
            expert: [
                "LOGIN", "PROFIL", "ICONE", "TOUCHE", "STOCKAGE", "RECHARGE", "CHARGE", "RECHERCHE", "SERVICES"
            ],
            maitre: ["DATABASE", "BROWSER", "CRYPTO", "DATA", "IMPRIME", "SMART"]
        ),
        "Nature": poidsParGroupes(
            debutant: [
                "ARBRE", "FLEUR", "FORET", "MER", "SOLEIL", "PLUIE", "NEIGE", "MONTAGNE", "OCEAN",
                "PLAGE", "LUNE", "OISEAU", "ANIMAL"
            ],
            apprenti: [
                "RIVIERE", "NUAGE", "VOLCAN", "ORAGE", "FLEUVE", "PLANTE", "HERBE", "JUNGLE", "LAC", "ILE",
                "ETOILE", "VENT", "INSECTE"
            ],
            confirme: [
                "PRAIRIE", "CASCADE", "SENTIER", "FEUILLE", "SABLE", "TEMPETE", "HORIZON", "BRUME", "FALAISE",
                "BUISSON", "SAVANE", "OASIS", "COLLINE", "VALLEE", "CANYON", "LITTORAL", "ETANG", "RUISSEAU",
                "SOURCE", "DELTA", "ROCHER", "PIERRE", "LAVE", "ECLAIR", "TONNERRE", "GIVRE", "AUBE", "PRINTEMPS",
                "ETE", "AUTOMNE", "HIVER", "BOIS", "ROSEE", "BAIE", "ARCENCIEL"
            ],
            expert: ["GLACIER", "RACINE", "MARAIS"],
            maitre: ["MINERAL", "CRISTAL", "ESPECE", "GRAINE", "POLLEN", "SEVE", "MOUSSE", "ALGUE"]
        ),
        "Quotidien": poidsParGroupes(
            debutant: [
                "MAISON", "TELEPHONE", "VOITURE", "FAMILLE", "MATIN", "NUIT", "TRAVAIL", "ECOLE", "MANGER",
                "BOIRE", "LIRE", "LIVRE", "PHOTO", "APPEL", "EMAIL"
            ],
            apprenti: [
                "REVEIL", "SOIREE", "AMITIE", "SOURIRE", "CUISINE", "JARDIN", "MARCHE", "DIMANCHE", "FENETRE",
                "CANAPE", "MIROIR", "COURSES", "VACANCES", "JOURNEE", "SEMAINE", "MOIS", "ANNEE", "PARENT",
                "ENFANT", "RIRE", "CARTE", "PORTE", "CHAMBRE", "SALON", "ECRIRE", "JOUER", "FETE", "CADEAU"
            ],
            confirme: [
                "VOISIN", "QUARTIER", "AGENDA", "BUREAU", "AMOUR", "PLEUR", "BONHEUR", "PROBLEME", "SOLUTION",
                "COURRIER", "COLIS", "PAQUET", "ACHAT", "VENTE", "PRIX", "ARGENT", "CLE", "MUR", "SOL", "PLAFOND",
                "ESCALIER", "COULOIR", "DORMIR", "DANSER", "SORTIE", "PROMENADE", "RENCONTRE"
            ],
            expert: [],
            maitre: []
        ),
        "Simpsons": poidsParGroupes(
            debutant: ["HOMER", "MARGE", "BART", "LISA", "MAGGIE"],
            apprenti: [
                "FLANDERS", "BURNS", "SMITHERS", "KRUSTY", "MILHOUSE", "MOE", "APU", "WIGGUM", "RALPH", "NELSON",
                "SKINNER", "EDNA", "BARNEY", "SIDESHOW", "BOB", "ABRAHAM", "PATTY", "SELMA", "LOVEJOY", "HIBBERT",
                "OTTO", "LENNY", "CARL", "WILLIE", "KENT"
            ],
            confirme: [
                "SEYMOUR", "QUIMBY", "CLETUS", "ITCHY", "SCRATCHY", "BARTMAN", "SANTA", "SNOWBALL", "KANG", "KODOS",
                "HERB", "MAUDE", "TODD", "ROD", "DOLPH", "JIMBO", "KIRK", "MARVIN", "CLANCY", "HERMAN", "MANJULA",
                "MARTIN", "HELEN", "BRANDINE", "SHERRI", "TERRI", "JASPER", "NICK"
            ],
            expert: [
                "COOKIE", "MEL", "TROY", "AGNES", "MAYOR", "FRINK", "LURLEEN", "AMBER", "MINDY", "GIL", "RUTH", "LUANN"
            ],
            maitre: ["FINK"]
        ),
        "South Park": poidsParGroupes(
            debutant: ["STAN", "KYLE", "CARTMAN", "KENNY", "BUTTERS"],
            apprenti: [
                "WENDY", "RANDY", "TWEEK", "JIMMY", "CRAIG", "CHEF", "IKE", "TIMMY", "GARRISON", "TOKEN", "BEBE",
                "GERALD"
            ],
            confirme: [
                "SHARON", "SHELLEY", "STUART", "CLYDE", "MRHANKY", "PRINCIPAL", "SATAN", "SADDAM", "TERRANCE", "PHILLIP",
                "PIP", "DOUG", "SCOTT", "GREGORY", "HEIDI", "JESUS", "GOD", "MRSLAVE", "MRHAT", "MANBEAR", "DAMIEN",
                "TOWELIE"
            ],
            expert: [
                "MACKY", "MILLIE", "LEROY", "STEVEN", "LINDA", "RICHARD", "CAROL", "MARCY", "GARY", "MOSES", "MRMOUSE",
                "JONAS", "MATT", "DEVON", "BRADLEY", "ROMAN", "FOSSEY", "SKEETER", "RED", "TENORMAN", "BECKY", "BARBRADY",
                "HARRISON", "THOMAS", "KELLY", "KIM", "SHEILA"
            ],
            maitre: ["TANGINA", "HARRIET", "VICTORIA", "MELVIN"]
        ),
        "Apple": poidsParGroupes(
            debutant: ["APPLE", "IPHONE", "MACBOOK", "IPAD", "IPOD", "IMAC", "AIRPODS"],
            apprenti: ["VISIONPRO", "WATCH", "AIRTAG", "HOMEPOD", "APPLETV", "PENCIL"],
            confirme: [
                "AIRPLAY", "AIRDROP", "FACETIME", "SIRI", "ICLOUD", "SAFARI", "IMESSAGE", "MACOS", "IOS", "TOUCHID",
                "MAGSAFE", "APPLEPAY", "APPSTORE", "CARPLAY", "FACEID", "ITUNES"
            ],
            expert: [
                "QUICKTIME", "HANDOFF", "HOMEKIT", "APPLEID", "APPLECARE", "AIRPRINT", "APPLEONE", "WATCHOS", "TVOS",
                "KEYNOTE", "NUMBERS", "LOGICPRO", "FINALCUT", "MOTION"
            ],
            maitre: ["SWIFT", "SWIFTUI", "XCODE", "ARKIT", "COREML", "METAL", "DARWIN"]
        ),
        "Pays": poidsParGroupes(
            debutant: [
                "FRANCE", "ESPAGNE", "ITALIE", "ALLEMAGNE", "BELGIQUE", "SUISSE", "PORTUGAL", "CANADA", "JAPON", "CHINE",
                "BRESIL", "MEXIQUE", "INDE", "MAROC", "EGYPTE", "GRECE", "TURQUIE", "RUSSIE", "AUSTRALIE"
            ],
            apprenti: [
                "ALGERIE", "TUNISIE", "NORVEGE", "SUEDE", "FINLANDE", "ISLANDE", "IRLANDE", "UKRAINE", "ISRAEL", "VIETNAM",
                "THAILANDE", "CHILI", "PEROU", "COLOMBIE", "KENYA", "NIGERIA", "SENEGAL", "CAMEROUN", "NEPAL"
            ],
            confirme: [
                "GEORGIE", "ARMENIE", "BOLIVIE", "GUYANA", "URUGUAY", "EQUATEUR", "QATAR", "JORDANIE", "CAMBODGE",
                "MALAISIE", "SINGAPOUR", "INDONESIE", "ETHIOPIE", "MOLDAVIE", "SLOVAQUIE", "CROATIE", "SERBIE", "SLOVENIE",
                "FIDJI"
            ],
            expert: [
                "SOMALIE", "OUGANDA", "TANZANIE", "ZAMBIE", "ZIMBABWE", "ANGOLA", "MAURICE", "COMORES", "DJIBOUTI",
                "LITUANIE", "LETTONIE", "ESTONIE", "BULGARIE", "ROUMANIE", "SAMOA", "TONGA"
            ],
            maitre: []
        ),
        "Objets maison": poidsParGroupes(
            debutant: [
                "TABLE", "CHAISE", "CANAPE", "LAMPE", "MIROIR", "FRIGO", "PORTE", "FENETRE", "VERRE", "TASSE",
                "ASSIETTE", "CUILLERE", "COUTEAU", "BALAI", "POUBELLE"
            ],
            apprenti: [
                "FAUTEUIL", "RIDEAU", "TAPIS", "ARMOIRE", "COUSSIN", "OREILLER", "MATELAS", "POELE", "CASSEROLE", "MUG",
                "EPONGE", "SAVON", "BOUTEILLE", "HORLOGE", "REVEIL", "TELEPHONE", "BOITE", "TIROIR", "PRISE", "AMPOULE",
                "CAFETIERE"
            ],
            confirme: [
                "ETAGERE", "PLATEAU", "MIXEUR", "BROSSE", "SERVIETTE", "PAPIER", "PANIER", "CINTRE", "RADIATEUR", "RANGEMENT",
                "PLACARD", "VASE", "NAPPE", "MEUBLE", "BANC", "BUREAU", "VOLET", "POIGNEE", "CABLE", "CADRE", "TABLEAU",
                "PLANTE", "POT", "BOUGIE", "SEAU", "PELLE", "PINCE", "MARTEAU", "TOURNEVIS", "CLOU", "MACHINE", "SECHOIR",
                "LOUCHE", "PASSOIRE"
            ],
            expert: [
                "COMMODE", "BUFFET", "TABOURET", "ETENDOIR", "TRINGLE", "RALLONGE", "ABATJOUR", "ALLUMETTE", "PERCEUSE",
                "ECHELLE", "ESCABEAU", "OUTIL"
            ],
            maitre: []
        )
    ]

    /// Termes qui doivent être proposés en premier à un profil Débutant.
    /// Ce sas de découverte évite qu'un premier mot soit seulement fréquent
    /// dans la langue : il doit aussi être une référence évidente du thème.
    /// Les niveaux suivants utilisent ensuite le classement complet de la
    /// banque.
    static let premiersParTheme: [String: Set<String>] = [
        "Sport": ["FOOTBALL", "BASKET", "TENNIS"],
        "Musique": ["GUITARE", "PIANO", "BATTERIE", "CONCERT", "CHANSON", "PIAF"],
        "Nourriture": ["PIZZA", "PAIN", "GATEAU", "FROMAGE", "CHOCOLAT", "CREPE", "PATES", "CROISSANT"],
        "Animaux": ["CHAT", "CHIEN", "LION", "TIGRE", "DAUPHIN", "BALEINE", "ELEPHANT"],
        "Voyage": ["AVION", "TRAIN", "HOTEL", "VALISE", "PLAGE", "PASSEPORT", "PARIS"],
        "Cinéma": ["CINEMA", "ACTEUR", "ACTRICE", "CAMERA", "ECRAN", "STAR", "MARVEL", "DISNEY", "STARWARS"],
        "École": ["CAHIER", "STYLO", "CLASSE", "DEVOIR", "EXAMEN", "ELEVE"],
        "Techno": ["INTERNET", "CLAVIER", "SOURIS", "MOBILE", "WIFI", "CONSOLE", "ANDROID", "GOOGLE", "NETFLIX"],
        "Nature": ["ARBRE", "FLEUR", "FORET", "MONTAGNE", "MER", "SOLEIL"],
        "Quotidien": ["MAISON", "TELEPHONE", "VOITURE", "FAMILLE", "MATIN", "TRAVAIL"],
        "Simpsons": ["HOMER", "MARGE", "BART", "LISA", "MAGGIE"],
        "South Park": ["STAN", "KYLE", "CARTMAN", "KENNY", "BUTTERS"],
        "Apple": ["APPLE", "IPHONE", "MACBOOK", "IPAD", "IPOD", "AIRPODS"],
        "Pays": ["FRANCE", "ESPAGNE", "ITALIE", "ALLEMAGNE", "BELGIQUE", "SUISSE"],
        "Objets maison": ["TABLE", "CHAISE", "CANAPE", "LAMPE", "MIROIR", "FRIGO"]
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
        var surcharges = SurchargesNotoriete.calibrageParTheme[nom]
            ?? SurchargesNotoriete.parTheme[nom]
            ?? [:]
        for (mot, poids) in poidsParMot {
            surcharges[mot.uppercased()] = poids
        }
        let poidsCalcules = MoteurDifficulte.poidsParOrdreDeNotoriete(
            mots,
            surcharges: surcharges
        )
        self.poidsParMot = poidsCalcules
        self.mots = mots.sorted {
            let poidsGauche = poidsCalcules[$0.uppercased()] ?? 50
            let poidsDroit = poidsCalcules[$1.uppercased()] ?? 50
            if poidsGauche != poidsDroit {
                return poidsGauche > poidsDroit
            }
            return $0 < $1
        }
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

    private var premiersMots: Set<String> {
        if nom == "Mélange" {
            return SurchargesNotoriete.premiersParTheme.values.reduce(into: Set<String>()) {
                $0.formUnion($1)
            }
        }
        return SurchargesNotoriete.premiersParTheme[nom] ?? []
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

        // Au tout début, on reste dans les références emblématiques du thème.
        // Une fois ces mots découverts, le classement normal prend le relais.
        if niveau == .debutant {
            let premiersDisponibles = disponibles.filter { premiersMots.contains($0) }
            if let mot = premiersDisponibles.randomElement() {
                return mot
            }
        }

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
            // Sports qui viennent immédiatement à l'esprit en France.
            "FOOTBALL", "BASKET", "TENNIS", "RUGBY", "NATATION", "CYCLISME",
            "BOXE", "JUDO", "KARATE", "SKI", "VOLLEY", "HANDBALL", "PETANQUE", "BOWLING",
            // Équipement et repères sportifs connus.
            "BALLON", "RAQUETTE", "MAILLOT", "PANIER", "BUT", "BALLE", "FILET",
            "STADE", "SCORE", "MATCH", "JOUEUR", "EQUIPE", "CHAMPION", "PASSE",
            "TIR", "VICTOIRE", "DEFAITE", "MEDAILLE", "TROPHEE",
            // Sports auxquels on pense moins.
            "RANDONNEE", "ESCALADE", "YOGA", "PILATES", "HIROX", "MARATHON",
            "ESCRIME", "PLONGEE", "SURF", "GOLF", "VOILE", "PATINAGE", "RALLYE", "SNOWBOARD",
            // Techniques, rôles et accessoires plus spécifiques.
            "ARBITRE", "GARDIEN", "VESTIAIRE", "PODIUM", "TRIBUNE", "PENALTY",
            "DRIBBLE", "SPRINT", "COUREUR", "ATHLETE", "COACH",
            "TOURNOI", "RECORD", "ATTAQUE", "DEFENSE", "BATON", "LIGNE",
            "COULOIR", "CHRONO", "ENDURANCE", "VITESSE", "SPRINTER", "PISCINE",
            "PILOTE", "MUSCLE", "ARBITRAGE", "ECHANGE", "RELAIS", "CIRCUIT"
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
            "TECHNO", "POP", "ELECTRO", "GROUPE", "SALLE", "OUVERTURE", "SOLO",
            "PIAF", "AZNAVOUR", "STROMAE", "ANGELE", "DAFTPUNK", "JUSTICE",
            "ACCORDEON", "HARMONICA", "SLAM"
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
            "CHIPS", "NOUILLES", "RIZ", "COUSCOUS", "PAIN", "CROISSANT", "FONDUE",
            "QUICHE", "MACARON", "CAFE", "THE", "VIN", "CHAMPAGNE", "CAMEMBERT"
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
            "PAPILLON", "ABEILLE", "FOURMI", "ESCARGOT", "LIMACE", "PIEUVRE", "CALAMAR",
            "CIGOGNE", "HERON", "MARMOTTE"
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
            "SOUVENIR", "TICKET", "VISA", "FRONTIERE", "PARIS", "LYON", "MARSEILLE",
            "NICE", "BRETAGNE", "LOUVRE", "CANNES", "COLMAR", "MONTBLANC"
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
            "LARME", "SAGA", "TEASER", "MARVEL", "DISNEY", "STARWARS", "PIXAR",
            "ASTERIX", "TINTIN"
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
            "MOBILE", "CHARGEUR", "CABLE", "WEBCAM", "SERVEUR", "ROUTEUR",
            "MODEM", "WIFI", "BLUETOOTH", "PROGRAMME", "CODE", "CODAGE", "DONNEE",
            "DATABASE", "DOSSIER", "COURRIEL", "EMAIL", "SITE", "PAGE", "LIEN", "BROWSER",
            "JOYSTICK", "IMAGE", "VIDEO", "AUDIO", "APPLI", "APP", "SERVICES", "CLOUD",
            "CRYPTO", "SECURITE", "LOGIN", "COMPTE", "PROFIL", "ICONE", "MENU", "BOUTON",
            "TOUCHE", "STOCKAGE", "RECHARGE", "CHARGE", "DATA", "PUCE", "CARTE", "LED",
            "LASER", "DISQUE", "RECHERCHE", "IMPRIME", "SMART", "VIRUS", "ANDROID",
            "GOOGLE", "NETFLIX", "SPOTIFY", "DEEZER", "DISCORD", "TIKTOK", "INSTAGRAM",
            "UBER", "VINTED", "BLABLACAR", "CHATGPT"
        ]),
        Theme(nom: "Nature", emoji: "🌳", mots: [
            "FORET", "RIVIERE", "ORAGE", "NUAGE", "VOLCAN", "PRAIRIE",
            "CASCADE", "GLACIER", "SENTIER", "FEUILLE", "RACINE", "SABLE",
            "MARAIS", "ARBRE", "TEMPETE", "HORIZON", "BRUME", "FALAISE",
            "FLEUR", "PLANTE", "HERBE", "BUISSON", "JUNGLE", "SAVANE", "OASIS",
            "COLLINE", "MONTAGNE", "VALLEE", "CANYON", "LITTORAL", "OCEAN", "MER",
            "LAC", "ETANG", "RUISSEAU", "SOURCE", "DELTA", "ILE", "PLAGE", "ROCHER",
            "PIERRE", "MINERAL", "CRISTAL", "LAVE", "ECLAIR", "TONNERRE",
            "VENT", "PLUIE", "NEIGE", "GIVRE", "SOLEIL", "LUNE", "ETOILE",
            "AUBE", "PRINTEMPS", "ETE", "AUTOMNE", "HIVER", "BOIS", "ESPECE", "OISEAU",
            "ANIMAL", "INSECTE", "GRAINE", "POLLEN", "SEVE", "MOUSSE", "ALGUE",
            "FLEUVE", "ROSEE", "BAIE", "ARCENCIEL"
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
            "ABRAHAM", "CLANCY", "HERB", "HERMAN", "MANJULA", "MARVIN", "LENNY", "CARL", "HELEN",
            "MAUDE", "TODD", "ROD", "DOLPH", "JIMBO", "KIRK", "LUANN", "RUTH",
            "COOKIE", "MEL", "SIDESHOW", "BOB", "TROY", "SEYMOUR", "EDNA",
            "AGNES", "MAYOR", "QUIMBY", "CLETUS", "BRANDINE", "SHERRI", "TERRI", "JASPER",
            "FRINK", "KENT", "WILLIE", "NICK", "ITCHY", "SCRATCHY", "SNOWBALL", "BARTMAN", "SANTA",
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
            "DAMIEN", "SKEETER", "RED", "TENORMAN", "BECKY", "BARBRADY", "HARRISON",
            "THOMAS", "KELLY", "KIM", "TANGINA", "HARRIET", "VICTORIA", "MELVIN",
            "SHEILA", "TOWELIE"
        ]),
        Theme(nom: "Apple", emoji: "🍎", mots: [
            // Produits grand public.
            "APPLE", "IPHONE", "MACBOOK", "IPAD", "IPOD", "IMAC", "AIRPODS",
            // Produits moins connus.
            "VISIONPRO", "WATCH", "AIRTAG", "HOMEPOD", "APPLETV", "PENCIL",
            // Technologies connues.
            "AIRPLAY", "AIRDROP", "FACETIME", "SIRI", "ICLOUD", "SAFARI",
            "IMESSAGE", "MACOS", "IOS", "TOUCHID", "MAGSAFE", "APPLEPAY",
            "APPSTORE", "CARPLAY",
            // Technologies moins connues.
            "HANDOFF", "FACEID", "HOMEKIT", "APPLEID", "APPLECARE", "AIRPRINT",
            "APPLEONE", "WATCHOS", "TVOS",
            // Outils et innovations Apple.
            "SWIFT", "SWIFTUI", "XCODE", "ARKIT", "COREML", "METAL", "DARWIN",
            "QUICKTIME", "ITUNES", "KEYNOTE", "NUMBERS", "LOGICPRO", "FINALCUT",
            "MOTION"
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
            "ECHELLE", "ESCABEAU", "OUTIL", "MACHINE", "SECHOIR", "LOUCHE",
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
