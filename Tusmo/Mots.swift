//
//  Mots.swift
//  Tusmo
//
//  Banques de mots du mode solo. La difficulté est éditoriale : elle mesure
//  la probabilité qu'un joueur français pense spontanément au mot, pas sa
//  longueur.
//

import Foundation

fileprivate enum BanquesCalibrees {
    /// Convertit les cinq groupes éditoriaux en poids continus.
    /// 100 = très évident, 1 = très spécialisé.
    private static func poidsParGroupes(_ groupes: [[String]]) -> [String: Int] {
        let plages: [ClosedRange<Int>] = [80...100, 60...79, 40...59, 20...39, 1...19]
        var resultats: [String: Int] = [:]

        for (index, groupe) in groupes.enumerated() {
            let plage = plages[index]
            let denominateur = max(groupe.count - 1, 1)
            let amplitude = plage.upperBound - plage.lowerBound

            for (position, mot) in groupe.enumerated() {
                let poids = plage.upperBound - Int(
                    (Double(position) / Double(denominateur) * Double(amplitude)).rounded()
                )
                resultats[mot] = poids
            }
        }

        return resultats
    }

    /// Chaque banque peut avoir une taille différente dans chaque niveau.
    /// Les niveaux vides sont donc conservés volontairement.
    static let groupesParTheme: [String: [[String]]] = [
        "Sport": [
            [
                "FOOTBALL", "BASKET", "TENNIS", "RUGBY", "BOXE", "NATATION",
                "SKI", "GOLF", "VOLLEY", "JUDO", "BALLON", "STADE"
            ],
            [
                "HANDBALL", "CYCLISME", "KARATE", "PETANQUE", "SURF", "BOWLING",
                "MATCH", "SCORE", "EQUIPE", "JOUEUR", "MAILLOT", "RAQUETTE",
                "PANIER", "ARBITRE", "GARDIEN", "MEDAILLE", "TROPHEE", "COURSE", "PISCINE"
            ],
            [
                "ESCALADE", "ESCRIME", "PLONGEE", "MARATHON", "SNOWBOARD", "PATINAGE",
                "VOILE", "RALLYE", "YOGA", "PILATES", "FILET", "PASSE", "PENALTY",
                "DRIBBLE", "SPRINT", "PODIUM", "TRIBUNE", "TOURNOI", "RECORD",
                "RELAIS", "CIRCUIT", "ENDURANCE", "COUREUR", "ATHLETE"
            ],
            [
                "SPRINTER", "ARBITRAGE", "VESTIAIRE", "CHRONO", "COULOIR", "ATTAQUE",
                "DEFENSE", "BATON", "PILOTE", "RANDONNEE", "CHAMPION", "VICTOIRE", "DEFAITE", "HYROX"
            ],
            ["HEPTATHLON", "DECATHLON", "BIATHLON"]
        ],
        "Musique": [
            [
                "MUSIQUE", "CHANSON", "GUITARE", "PIANO", "BATTERIE", "CONCERT",
                "CHANTEUR", "RADIO", "RAP", "ROCK", "POP", "ALBUM", "DANSE", "MICRO", "FESTIVAL"
            ],
            [
                "VIOLON", "RYTHME", "PAROLES", "REFRAIN", "SCENE", "CASQUE", "MUSICIEN",
                "GROUPE", "SPECTACLE", "TUBE", "HIT", "ORCHESTRE", "OPERA", "MELODIE",
                "CHANT", "VINYLE", "JAZZ", "TECHNO", "METAL"
            ],
            [
                "COUPLET", "TROMPETTE", "ACCORD", "HARMONIE", "BATTEUR", "PIANISTE",
                "SAXO", "FLUTE", "BASSE", "AMPLI", "ENCEINTE", "NOTE", "TOURNEE",
                "DISQUE", "PLAYLIST", "ACCORDEON", "SLAM", "SOUL", "BLUES", "FOLK",
                "ELECTRO", "TEMPO", "SOLO", "CHORALE"
            ],
            [
                "HARPE", "ORGUE", "BASSISTE", "GAMME", "PARTITION", "SOLFEGE", "CASSETTE",
                "COMPOSITEUR", "HARMONICA", "OUVERTURE", "TAMBOUR", "PERCUSSION",
                "SYMPHONIE", "SONATE", "OCTAVE", "METRONOME"
            ],
            ["ARPEGE", "CADENCE", "LEGATO", "STACCATO", "TREMOLO", "VIBRATO", "SOPRANO", "CONTRALTO"]
        ],
        "Artistes": [
            [
                "PIAF", "STROMAE", "ANGELE", "GIMS", "JUL", "ORELSAN", "SOPRANO",
                "ADELE", "BEYONCE", "RIHANNA", "EMINEM", "SHAKIRA", "MADONNA", "DRAKE", "BRITNEY"
            ],
            [
                "AZNAVOUR", "DAFTPUNK", "JUSTICE", "VITAA", "SLIMANE", "VIANNEY", "ZAZ", "MIKA",
                "INDOCHINE", "PNL", "NINHO", "DAMSO", "NEKFEU", "BIGFLO", "OLI", "LADYGAGA",
                "TAYLORSWIFT", "BRUNOMARS", "ARIANAGRANDE"
            ],
            [
                "CALOGERO", "LOUANE", "BENABAR", "HOSHI", "POMME", "LOMEPAL", "SCH", "HAMZA",
                "KENDRICKLAMAR", "DUALIPA", "KATYPERRY", "MILEYCYRUS", "SELENAGOMEZ", "BILLIEEILISH",
                "JUSTINBIEBER", "EDSHEERAN", "THEWEEKND", "COLDPLAY", "IMAGINEDRAGONS", "LINKINPARK"
            ],
            [
                "BARBARA", "BRASSENS", "BREL", "GAINSBOURG", "FERRE", "MCSOLAAR", "OXMO",
                "LAVILLIERS", "BASHUNG", "OBISPO", "YSEULT", "PATRICKBRUEL", "RAPHAEL", "ARTHURH", "CLAUDIOCAPEO"
            ],
            ["BJORK", "RADIOHEAD", "PORTISHEAD", "SIGURROS", "APHEXTWIN", "FKATWIGS", "PJHARVEY", "MASSIVEATTACK"]
        ],
        "Nourriture": [
            [
                "PIZZA", "PAIN", "GATEAU", "FROMAGE", "CHOCOLAT", "PATES", "BURGER",
                "CREPE", "CROISSANT", "POMME", "BANANE", "GLACE", "SALADE", "POULET", "RIZ", "FRITE"
            ],
            [
                "DESSERT", "TOMATE", "BAGUETTE", "SANDWICH", "YAOURT", "RACLETTE",
                "CAFE", "THE", "COOKIE", "CHIPS", "BEURRE", "SUCRE", "SEL", "ORANGE",
                "FRAISE", "GAUFRE", "TARTE", "JAMBON", "STEAK", "FONDUE", "QUICHE", "OMELETTE"
            ],
            [
                "MACARON", "CAMEMBERT", "POIVRON", "POIVRE", "FARINE", "HUILE", "VINAIGRE",
                "MIEL", "CONFITURE", "CEREALES", "BISCUIT", "TARTINE", "BRIOCHE", "BAGEL",
                "CERISE", "RAISIN", "MELON", "CAROTTE", "PATATE", "OIGNON", "POISSON",
                "VIANDE", "SAUCISSE", "CREME", "MUFFIN", "BROWNIE", "PANCAKE"
            ],
            [
                "POPCORN", "NOUILLES", "COUSCOUS", "PASTEQUE", "POIREAU", "EPINARD",
                "HARICOT", "SAUMON", "CREVETTE", "SORBET", "MOUSSE", "NAVET", "AUBERGINE",
                "COURGETTE", "LENTILLE", "ARTICHAUT"
            ],
            ["TOPINAMBOUR", "PANAIS", "FENOUIL", "ECHALOTE", "POLENTA", "GASPACHO", "TAPENADE", "RISOTTO"]
        ],
        "Animaux": [
            [
                "CHAT", "CHIEN", "LION", "TIGRE", "CHEVAL", "ELEPHANT", "OURS", "SINGE",
                "DAUPHIN", "BALEINE", "PANDA", "LAPIN", "VACHE", "LOUP", "REQUIN", "GIRAFE"
            ],
            [
                "RENARD", "PANTHERE", "TORTUE", "PERROQUET", "SERPENT", "ZEBRE", "GORILLE",
                "KOALA", "KANGOUROU", "MOUTON", "CANARD", "POULE", "COQ", "PAPILLON",
                "ABEILLE", "ESCARGOT", "CROCODILE", "AIGLE", "SOURIS", "COCHON", "CHEVRE"
            ],
            [
                "ECUREUIL", "HIBOU", "LEZARD", "ARAIGNEE", "BLAIREAU", "LAMA", "CHAMEAU",
                "RAT", "CASTOR", "HERISSON", "CERF", "ANE", "PONEY", "OIE", "FAUCON",
                "CHOUETTE", "CORBEAU", "CYGNE", "FLAMANT", "MANCHOT", "ORQUE", "PHOQUE",
                "MOUSTIQUE", "CRAPAUD", "SCORPION", "FOURMI", "PIEUVRE"
            ],
            [
                "BABOUIN", "MARMOTTE", "CIGOGNE", "HERON", "LIMACE", "TAUPE", "CALAMAR",
                "DAIM", "SANGLIER", "CHEVREUIL", "DINDON", "IGUANE", "LOUTRE", "BELETTE",
                "FURET", "CHACAL", "BISON"
            ],
            ["OKAPI", "CARACAL", "TAPIR", "WOMBAT", "NARVAL", "AXOLOTL", "PANGOLIN", "ORNITHORYNQUE", "GLOUTON"]
        ],
        "Voyage": [
            [
                "AVION", "TRAIN", "VALISE", "PLAGE", "HOTEL", "PASSEPORT", "AEROPORT",
                "BILLET", "VACANCES", "VOYAGE", "BATEAU", "TAXI", "BUS", "CARTE"
            ],
            [
                "DOUANE", "MONTAGNE", "CAMPING", "BAGAGE", "GPS", "ROUTE", "VELO", "PHOTO",
                "MUSEE", "CHATEAU", "OCEAN", "ILE", "CROISIERE", "TOURISTE", "SEJOUR",
                "TICKET", "TENTE", "METRO", "PORT", "DEPART", "ARRIVEE", "GUIDE"
            ],
            [
                "DESERT", "ESCALE", "RANDONNEE", "BOUSSOLE", "VOYAGEUR", "ATLAS", "AUBERGE",
                "VILLAGE", "PAYSAGE", "LAC", "VALLEE", "RIVAGE", "PHARE", "FERRY", "CABINE",
                "MONUMENT", "VISA", "AUTOROUTE", "FRONTIERE", "QUAI", "NAVIRE"
            ],
            [
                "PLATEAU", "LITTORAL", "RESORT", "YACHT", "TREK", "TERMINAL", "EMBARQUEMENT",
                "ITINERAIRE", "EXCURSION", "TRANSFERT", "DOUANIER", "CROISIERISTE"
            ],
            ["BIVOUAC", "FUNICULAIRE", "CATAMARAN", "TRANSATLANTIQUE", "TELEPHERIQUE", "CARAVANSERAIL", "AEROGARE"]
        ],
        "Villes": [
            [
                "PARIS", "LYON", "MARSEILLE", "NICE", "BORDEAUX", "TOULOUSE", "NANTES", "LILLE",
                "LONDRES", "NEWYORK", "TOKYO", "ROME", "MADRID", "BERLIN", "BRUXELLES"
            ],
            [
                "STRASBOURG", "RENNES", "MONTPELLIER", "GRENOBLE", "CANNES", "MONACO", "BARCELONE",
                "LISBONNE", "AMSTERDAM", "ATHENES", "ISTANBUL", "PRAGUE", "VIENNE", "DUBLIN",
                "MARRAKECH", "GENEVE", "MONTREAL", "SYDNEY", "DUBAI", "LOSANGELES"
            ],
            [
                "DIJON", "REIMS", "ANGERS", "AVIGNON", "BIARRITZ", "COLMAR", "ANNECY", "CALVI",
                "ROUEN", "CAEN", "BREST", "PERPIGNAN", "NAPLES", "FLORENCE", "MILAN", "VENISE",
                "OSLO", "STOCKHOLM", "HELSINKI", "SEOUL", "PEKIN"
            ],
            [
                "CLERMONTFERRAND", "LIMOGES", "BESANCON", "AJACCIO", "DUNKERQUE", "LEHAVRE", "POITIERS",
                "TALLINN", "RIGA", "SOFIA", "ZAGREB", "LJUBLJANA", "MOSCOU", "LECAIRE", "SANFRANCISCO"
            ],
            ["OULANBATOR", "ASHGABAT", "BISCHKEK", "DOUCHANBE", "PARAMARIBO", "MASERU", "MBABANE", "NUUK"]
        ],
        "Cinéma": [
            [
                "CINEMA", "FILM", "ACTEUR", "ACTRICE", "CAMERA", "ECRAN", "STAR", "SERIE",
                "HEROS", "COMEDIE", "HORREUR", "ACTION", "DRAME", "DESSIN", "ANIMATION"
            ],
            [
                "AVENTURE", "VILAIN", "ROMANCE", "THRILLER", "SALLE", "OSCAR", "HOLLYWOOD",
                "SAISON", "EPISODE", "SAGA", "TOURNAGE", "SCENARIO", "COSTUME", "DECOR",
                "ROLE", "TITRE", "IMAGE", "SON", "DIALOGUE"
            ],
            [
                "SUSPENSE", "REPLIQUE", "MONTAGE", "SEANCE", "AFFICHE", "DOUBLAGE", "STUDIO",
                "INTRIGUE", "CAMEO", "HEROINE", "MONSTRE", "FICTION", "WESTERN", "MUSICAL",
                "VEDETTE", "GENRE", "CESAR", "PREMIERE", "TEASER", "EFFET", "PRISE", "PLAN", "LUMIERE"
            ],
            [
                "FANTASY", "BIOPIC", "PITCH", "ANGLE", "FOCUS", "BOBINE", "PELICULE", "PALME",
                "FIGURANT", "CASCADEUR", "PRODUCTEUR", "REALISATEUR", "SCENARISTE", "GENERIQUE", "VOIXOFF"
            ],
            ["TRAVELLING", "STORYBOARD", "RACCORD", "CHROMAKEY", "STEADICAM", "DIAGETIQUE", "DOLLY", "ETALONNAGE"]
        ],
        "École": [
            [
                "CAHIER", "STYLO", "DEVOIR", "EXAMEN", "CLASSE", "TABLEAU", "ELEVE", "COURS",
                "LIVRE", "COLLEGE", "LYCEE", "CARTABLE", "TROUSSE", "CRAYON", "GOMME", "NOTE"
            ],
            [
                "CANTINE", "DIPLOME", "LECTURE", "CALCUL", "ETUDIANT", "RENTREE", "BULLETIN",
                "MATHS", "SPORT", "RECRE", "QUESTION", "REPONSE", "EXERCICE", "CONTROLE",
                "FEUILLE", "PAPIER", "MATIERE", "LECON", "CLASSEUR", "REGLE", "COMPAS"
            ],
            [
                "PUPITRE", "FRANCAIS", "ANGLAIS", "ETUDE", "MOYENNE", "TRAVAIL", "SCIENCE",
                "HISTOIRE", "ESPAGNOL", "PHYSIQUE", "CHIMIE", "BIOLOGIE", "SEMESTRE", "TRIMESTRE",
                "AGENDA", "PLANNING", "DOSSIER", "EQUERRE", "MARQUEUR", "PROJET", "CASIER", "SONNERIE"
            ],
            [
                "GEOGRAPHIE", "LITTERATURE", "PHILOSOPHIE", "CONCOURS", "CAMPUS", "RECHERCHE",
                "LABORATOIRE", "AMPHITHEATRE", "BIBLIOTHEQUE", "INTERNAT", "PROVISEUR", "PRINCIPAL", "SURVEILLANT"
            ],
            ["BACCALAUREAT", "DISSERTATION", "BIBLIOGRAPHIE", "PEDAGOGIE", "DIDACTIQUE", "DOCTORAT", "SOUTENANCE"]
        ],
        "Techno": [
            [
                "INTERNET", "CLAVIER", "SOURIS", "TELEPHONE", "CONSOLE", "ROBOT", "WIFI", "CODE",
                "EMAIL", "VIDEO", "GOOGLE", "ANDROID", "ECRAN", "APPLI", "SITE", "TABLETTE"
            ],
            [
                "CHARGEUR", "CABLE", "FICHIER", "MANETTE", "ECOUTEUR", "MESSAGE", "PIXEL", "CLOUD",
                "COMPTE", "DOSSIER", "MENU", "BOUTON", "VIRUS", "RESEAU", "IMAGE", "AUDIO",
                "BLUETOOTH", "LOGICIEL", "MEMOIRE", "WEBCAM", "SERVEUR", "DONNEE"
            ],
            [
                "CAPTEUR", "PIRATE", "ROUTEUR", "MODEM", "PROGRAMME", "CODAGE", "COURRIEL", "LIEN",
                "JOYSTICK", "SECURITE", "DISQUE", "CARTE", "PUCE", "LASER", "LED", "LOGIN",
                "PROFIL", "ICONE", "STOCKAGE", "DATABASE", "BROWSER", "CRYPTO", "DATA"
            ],
            [
                "PROCESSEUR", "TERMINAL", "FIREWALL", "PROTOCOLE", "ALGORITHME", "COMPILATEUR",
                "FRAMEWORK", "BACKEND", "FRONTEND", "KERNEL", "CACHE", "SOCKET", "LATENCE",
                "BANDEPASSANTE", "FIRMWARE", "CHIFFREMENT"
            ],
            ["HYPERVISEUR", "CONTENEUR", "VIRTUALISATION", "ASSEMBLEUR", "SERIALISATION", "ORCHESTRATION", "CRYPTOGRAPHIE", "MICROCODE"]
        ],
        "Apps / Internet": [
            [
                "GOOGLE", "YOUTUBE", "WHATSAPP", "INSTAGRAM", "TIKTOK", "SNAPCHAT", "FACEBOOK",
                "NETFLIX", "SPOTIFY", "DISCORD", "UBER", "AMAZON", "WAZE", "CHATGPT", "TWITTER"
            ],
            [
                "TELEGRAM", "VINTED", "BLABLACAR", "DOCTOLIB", "LEBONCOIN", "AIRBNB", "PAYPAL",
                "LINKEDIN", "PINTEREST", "REDDIT", "TWITCH", "DEEZER", "TINDER", "DELIVEROO",
                "DUOLINGO", "SHAZAM", "WIKIPEDIA", "PRONOTE", "CANVA", "NOTION"
            ],
            [
                "NAVIGATEUR", "COMPTE", "PROFIL", "MESSAGE", "RESEAU", "CLOUD", "STREAMING",
                "PODCAST", "FORUM", "BLOG", "HASHTAG", "ALGORITHME", "PLATEFORME", "ABONNEMENT",
                "NOTIFICATION", "MOTDEPASSE", "IDENTIFIANT", "SERVEUR", "DOMAINE", "LIEN"
            ],
            [
                "VPN", "FIREWALL", "PHISHING", "COOKIE", "CAPTCHA", "DNS", "HTTP", "URL",
                "API", "CACHE", "CYBERSECURITE", "MODERATION", "DEEPFAKE", "RANSOMWARE", "BOTNET", "SPAM"
            ],
            ["DNSSEC", "REVERSEPROXY", "CDN", "OAUTH", "WEBSOCKET", "TOR", "FEDIVERSE"]
        ],
        "Nature": [
            [
                "ARBRE", "FLEUR", "FORET", "MER", "SOLEIL", "PLUIE", "NEIGE", "MONTAGNE",
                "OCEAN", "PLAGE", "LUNE", "OISEAU", "ANIMAL", "RIVIERE", "NUAGE"
            ],
            [
                "VOLCAN", "ORAGE", "FLEUVE", "PLANTE", "HERBE", "JUNGLE", "LAC", "ILE", "ETOILE",
                "VENT", "INSECTE", "PRAIRIE", "CASCADE", "SABLE", "TEMPETE", "FEUILLE", "ROCHER", "PIERRE"
            ],
            [
                "SENTIER", "HORIZON", "BRUME", "FALAISE", "BUISSON", "SAVANE", "OASIS", "COLLINE",
                "VALLEE", "CANYON", "LITTORAL", "ETANG", "RUISSEAU", "SOURCE", "DELTA", "LAVE",
                "ECLAIR", "TONNERRE", "GIVRE", "AUBE", "PRINTEMPS", "AUTOMNE", "HIVER", "ROSEE", "ARCENCIEL"
            ],
            [
                "GLACIER", "RACINE", "MARAIS", "MINERAL", "CRISTAL", "ESPECE", "GRAINE", "POLLEN",
                "SEVE", "MOUSSE", "ALGUE", "ESTUAIRE", "DUNE", "RECIF", "MANGROVE"
            ],
            ["PERMAFROST", "TOURBIERE", "TAIGA", "TUNDRA", "BIOSPHERE", "PHYTOPLANCTON", "CONIFERE"]
        ],
        "Quotidien": [
            [
                "MAISON", "TELEPHONE", "VOITURE", "FAMILLE", "MATIN", "NUIT", "TRAVAIL", "ECOLE",
                "MANGER", "BOIRE", "LIRE", "LIVRE", "PHOTO", "APPEL", "EMAIL", "PORTE", "CHAMBRE", "CUISINE"
            ],
            [
                "REVEIL", "SOIREE", "AMITIE", "SOURIRE", "JARDIN", "MARCHE", "DIMANCHE", "FENETRE",
                "CANAPE", "MIROIR", "COURSES", "VACANCES", "JOURNEE", "SEMAINE", "MOIS", "ANNEE",
                "PARENT", "ENFANT", "RIRE", "CARTE", "SALON", "ECRIRE", "JOUER", "FETE", "CADEAU"
            ],
            [
                "VOISIN", "QUARTIER", "AGENDA", "BUREAU", "AMOUR", "BONHEUR", "PROBLEME", "SOLUTION",
                "COURRIER", "COLIS", "PAQUET", "ACHAT", "VENTE", "PRIX", "ARGENT", "CLE", "PLAFOND",
                "ESCALIER", "COULOIR", "DORMIR", "SORTIE", "RENCONTRE"
            ],
            ["PROMENADE", "RENDEZVOUS", "HABITUDE", "ROUTINE", "DEMARCHE", "LIVRAISON", "ABONNEMENT", "FACTURE"],
            []
        ],
        "Simpsons": [
            ["HOMER", "MARGE", "BART", "LISA", "MAGGIE", "KRUSTY", "FLANDERS", "MOE", "BURNS", "MILHOUSE"],
            ["SKINNER", "RALPH", "NELSON", "WIGGUM", "SMITHERS", "BARNEY", "APU", "ABRAHAM", "PATTY", "SELMA", "WILLIE", "LENNY", "CARL", "OTTO", "HIBBERT"],
            ["QUIMBY", "CLETUS", "FRINK", "KENT", "LOVEJOY", "EDNA", "MAUDE", "MARTIN", "JIMBO", "DOLPH", "ITCHY", "SCRATCHY", "KANG", "KODOS", "JASPER", "AGNES", "MANJULA", "SHERRI", "TERRI", "HERMAN"],
            ["BRANDINE", "LUANN", "KIRK", "TODD", "ROD", "HELEN", "MINDY", "RUTH", "GIL", "CHALMERS", "LARGO", "AKIRA", "EDDIE", "LOUIE"],
            ["LURLEEN", "KUMIKO", "CARGILL", "CARVALLO", "BRODKA", "BARLOW"]
        ],
        "South Park": [
            ["CARTMAN", "KENNY", "STAN", "KYLE", "BUTTERS", "RANDY", "WENDY", "GARRISON", "CHEF", "TWEEK"],
            ["CRAIG", "JIMMY", "TIMMY", "IKE", "TOLKIEN", "MACKEY", "BEBE", "CLYDE", "SHARON", "SHEILA", "GERALD", "SHELLEY", "TOWELIE"],
            ["MRHANKY", "SATAN", "SADDAM", "TERRANCE", "PHILLIP", "PIP", "HEIDI", "JESUS", "MRSLAVE", "MRHAT", "DAMIEN", "BARBRADY", "VICTORIA", "SCOTT", "TENORMAN"],
            ["MANBEARPIG", "GREGORY", "MOSES", "SKEETER", "RED", "BRADLEY", "PRINCIPAL", "STRONGWOMAN", "HARRISON"],
            ["TANGINA", "MELVIN"]
        ],
        "Apple": [
            ["APPLE", "IPHONE", "MACBOOK", "IPAD", "IMAC", "AIRPODS", "APPLEWATCH", "SIRI", "ICLOUD", "SAFARI"],
            ["AIRTAG", "HOMEPOD", "APPLETV", "APPLEPENCIL", "AIRDROP", "AIRPLAY", "FACETIME", "IMESSAGE", "MAGSAFE", "APPLEPAY", "APPSTORE", "CARPLAY", "FACEID", "TOUCHID", "MACOS"],
            ["VISIONPRO", "IOS", "IPADOS", "WATCHOS", "TVOS", "VISIONOS", "ITUNES", "APPLECARE", "APPLEID", "KEYNOTE", "NUMBERS", "FINALCUT", "LOGICPRO", "QUICKTIME"],
            ["HANDOFF", "HOMEKIT", "AIRPRINT", "APPLEONE", "MOTION", "GARAGEBAND", "TESTFLIGHT", "FINDMY", "ICLOUDPLUS", "APPLEINTELLIGENCE", "SHORTCUTS", "XCODE"],
            ["SWIFT", "SWIFTUI", "ARKIT", "COREML", "METAL", "DARWIN", "WEBKIT", "CLOUDKIT"]
        ],
        "Pays": [
            ["FRANCE", "ESPAGNE", "ITALIE", "ALLEMAGNE", "BELGIQUE", "SUISSE", "PORTUGAL", "CANADA", "JAPON", "CHINE", "BRESIL", "MEXIQUE", "INDE", "MAROC", "EGYPTE", "GRECE", "TURQUIE", "RUSSIE", "AUSTRALIE", "ALGERIE"],
            ["TUNISIE", "NORVEGE", "SUEDE", "FINLANDE", "ISLANDE", "IRLANDE", "UKRAINE", "ISRAEL", "VIETNAM", "THAILANDE", "CHILI", "PEROU", "COLOMBIE", "KENYA", "NIGERIA", "SENEGAL", "CAMEROUN", "NEPAL", "CROATIE"],
            ["GEORGIE", "ARMENIE", "BOLIVIE", "GUYANA", "URUGUAY", "EQUATEUR", "QATAR", "JORDANIE", "CAMBODGE", "MALAISIE", "SINGAPOUR", "INDONESIE", "ETHIOPIE", "MOLDAVIE", "SLOVAQUIE", "SERBIE", "SLOVENIE", "BULGARIE", "ROUMANIE"],
            ["SOMALIE", "OUGANDA", "TANZANIE", "ZAMBIE", "ZIMBABWE", "ANGOLA", "MAURICE", "COMORES", "DJIBOUTI", "LITUANIE", "LETTONIE", "ESTONIE", "FIDJI", "SAMOA", "TONGA", "BOTSWANA"],
            ["KIRIBATI", "TUVALU", "VANUATU", "NAURU", "PALAU", "LESOTHO", "ESWATINI", "SURINAME", "BURUNDI", "MALAWI"]
        ],
        "Objets maison": [
            ["TABLE", "CHAISE", "CANAPE", "LAMPE", "MIROIR", "FRIGO", "PORTE", "FENETRE", "VERRE", "TASSE", "ASSIETTE", "CUILLERE", "COUTEAU", "BALAI", "POUBELLE", "LIT", "FOUR", "SAVON"],
            ["FAUTEUIL", "RIDEAU", "TAPIS", "ARMOIRE", "COUSSIN", "OREILLER", "MATELAS", "POELE", "CASSEROLE", "MUG", "EPONGE", "BOUTEILLE", "HORLOGE", "REVEIL", "BOITE", "TIROIR", "PRISE", "AMPOULE", "CAFETIERE", "ETAGERE", "SERVIETTE", "PANIER", "CINTRE"],
            ["PLATEAU", "MIXEUR", "BROSSE", "RADIATEUR", "PLACARD", "VASE", "NAPPE", "MEUBLE", "BANC", "BUREAU", "VOLET", "POIGNEE", "CABLE", "CADRE", "TABLEAU", "POT", "BOUGIE", "SEAU", "PELLE", "PINCE", "MARTEAU", "TOURNEVIS", "CLOU", "SECHOIR", "PASSOIRE"],
            ["COMMODE", "BUFFET", "TABOURET", "ETENDOIR", "TRINGLE", "RALLONGE", "ABATJOUR", "ALLUMETTE", "PERCEUSE", "ECHELLE", "ESCABEAU", "LOUCHE", "MANDOLINE", "DECAPSULEUR", "ESSOREUSE"],
            ["ECUMOIRE", "VIDEPOCHE", "PATERE", "DESSOUSPLAT", "CHAUSSEPIED", "SERREJOINT"]
        ]
    ]

    static func poidsParTheme(_ nom: String) -> [String: Int] {
        guard let groupes = groupesParTheme[nom] else { return [:] }
        return poidsParGroupes(groupes)
    }

    static func motsCalibres(_ nom: String) -> [String] {
        let poids = poidsParTheme(nom)
        return poids.keys.sorted {
            let poidsGauche = poids[$0] ?? 0
            let poidsDroit = poids[$1] ?? 0
            if poidsGauche != poidsDroit {
                return poidsGauche > poidsDroit
            }
            return $0 < $1
        }
    }

    static func premiersMots(_ nom: String) -> Set<String> {
        Set(groupesParTheme[nom]?.first ?? [])
    }
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

        var surcharges = BanquesCalibrees.poidsParTheme(nom)
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
            return BanquesCalibrees.groupesParTheme.values.reduce(into: Set<String>()) { resultat, groupes in
                resultat.formUnion(groupes.first ?? [])
            }
        }
        return BanquesCalibrees.premiersMots(nom)
    }

    func motAleatoire(sauf: String? = nil) -> String {
        let choix = mots.filter { $0 != sauf }
        return (choix.isEmpty ? mots : choix).randomElement() ?? "MOTUS"
    }

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
    /// Banques générales actives. Les listes sont construites depuis les
    /// groupes éditoriaux pour que contenu, ordre et difficulté restent liés.
    static let themes: [Theme] = [
        Theme(nom: "Sport", emoji: "🏀", mots: BanquesCalibrees.motsCalibres("Sport")),
        Theme(nom: "Musique", emoji: "🎵", mots: BanquesCalibrees.motsCalibres("Musique")),
        Theme(nom: "Artistes", emoji: "🎤", mots: BanquesCalibrees.motsCalibres("Artistes")),
        Theme(nom: "Nourriture", emoji: "🍕", mots: BanquesCalibrees.motsCalibres("Nourriture")),
        Theme(nom: "Animaux", emoji: "🐾", mots: BanquesCalibrees.motsCalibres("Animaux")),
        Theme(nom: "Voyage", emoji: "✈️", mots: BanquesCalibrees.motsCalibres("Voyage")),
        Theme(nom: "Villes", emoji: "🏙️", mots: BanquesCalibrees.motsCalibres("Villes")),
        Theme(nom: "Cinéma", emoji: "🎬", mots: BanquesCalibrees.motsCalibres("Cinéma")),
        Theme(nom: "École", emoji: "🎓", mots: BanquesCalibrees.motsCalibres("École")),
        Theme(nom: "Techno", emoji: "💻", mots: BanquesCalibrees.motsCalibres("Techno")),
        Theme(nom: "Apps / Internet", emoji: "📱", mots: BanquesCalibrees.motsCalibres("Apps / Internet")),
        Theme(nom: "Nature", emoji: "🌳", mots: BanquesCalibrees.motsCalibres("Nature")),
        Theme(nom: "Quotidien", emoji: "🏠", mots: BanquesCalibrees.motsCalibres("Quotidien")),
        Theme(nom: "Simpsons", emoji: "🍩", mots: BanquesCalibrees.motsCalibres("Simpsons")),
        Theme(nom: "South Park", emoji: "🏔️", mots: BanquesCalibrees.motsCalibres("South Park")),
        Theme(nom: "Apple", emoji: "🍎", mots: BanquesCalibrees.motsCalibres("Apple")),
        Theme(nom: "Pays", emoji: "🌍", mots: BanquesCalibrees.motsCalibres("Pays")),
        Theme(nom: "Objets maison", emoji: "🛋️", mots: BanquesCalibrees.motsCalibres("Objets maison"))
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
