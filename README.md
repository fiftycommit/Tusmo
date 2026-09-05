# Tusmo

Tusmo est un petit jeu de mots en SwiftUI, dans l'esprit de Motus, avec une
progression automatique et plusieurs façons de jouer.

En solo, le joueur choisit un thème puis tente de retrouver le mot secret. En
2 joueurs, un premier joueur écrit le mot et le second tente de le retrouver.
Après chaque proposition, les lettres changent de couleur : rouge quand la
lettre est au bon endroit, jaune quand elle existe ailleurs dans le mot,
sombre quand elle n'est pas présente.

J'ai aussi fait une version en Python, jouable dans le terminal, et une autre en p5.js.

## Aperçu

<p>
  <img src="docs/screenshots/menu.png" alt="Écran d'accueil de Tusmo" width="130">
  <img src="docs/screenshots/longueur-invalide.png" alt="Message quand le mot proposé n'a pas la bonne longueur" width="130">
  <img src="docs/screenshots/premier-essai.png" alt="Premier essai avec lettres absentes et mal placées" width="130">
  <img src="docs/screenshots/saisie.png" alt="Saisie d'une proposition pendant une partie" width="130">
  <img src="docs/screenshots/victoire.png" alt="Fenêtre de victoire avec score" width="130">
</p>

## Ce qu'on peut faire

- saisir un mot secret sans l'afficher à l'autre joueur ;
- deviner un mot de 1 à 9 lettres ;
- voir les indices lettre par lettre après chaque essai ;
- toucher une case pour revoir sa signification ;
- rejouer directement après une victoire ou une défaite.
- jouer avec les personnages des Simpsons ou de South Park ;
- retrouver des produits et technologies Apple, des pays ou des objets de la maison ;
- jouer avec des banques séparées pour les artistes, les villes et les apps / services internet ;
- profiter de banques généralement riches, sans remplir artificiellement un niveau
  quand le thème ne possède pas assez de références justes ;
- classer les termes par familiarité, du niveau Débutant aux références de
  niveau Maître, indépendamment du nombre de lettres ;
- calibrer chaque thème avec une progression éditoriale complète : références
  évidentes en France, termes courants, puis références spécialisées ;
- afficher la difficulté éditoriale du mot dans une pastille dédiée pendant
  la partie ;
- commencer chaque thème par quelques références emblématiques, puis ouvrir
  progressivement les termes moins connus ; les mots sont classés selon leur
  association spontanée au thème dans un contexte français ;
- voir une progression de 0 à 100 % par thème et retrouver uniquement des mots
  qui n'ont pas encore été devinés ;
- progresser automatiquement du niveau Débutant au niveau Maître, séparément
  pour chaque thème ;
- adapter cette progression à la partie : une victoire rapide accélère les
  gains d'expérience, tandis qu'une défaite baisse immédiatement le niveau du
  thème concerné ;
- conditionner aussi le déblocage des niveaux à la découverte du thème :
  Apprenti à 10 %, Confirmé à 25 %, Expert à 45 % et Maître à 65 % ;
- augmenter progressivement l'effort nécessaire entre les niveaux : 3, 6,
  10 puis 15 victoires d'expérience, avec recalibrage des anciennes sauvegardes ;
- créer plusieurs profils, chacun avec sa propre progression et ses records ;
- choisir le thème Pokémon puis une génération de la I à la IX ;
- jouer un tournoi de cinq manches et conserver le score final ;
- jouer en mode « Le plus loin possible », en choisissant entre encaisser ses
  points ou continuer avec un multiplicateur plus élevé — une défaite fait
  perdre tous les points en jeu.

## Lancer le projet

Ouvre `Tusmo.xcodeproj` avec Xcode, puis lance la cible `Tusmo` sur un simulateur iPhone ou un appareil iOS.

Le projet ne dépend pas d'un paquet externe. La logique d'interface est dans
`Tusmo/ContentView.swift`, les profils et niveaux dans
`Tusmo/Progression.swift`, et la banque de mots dans `Tusmo/Mots.swift`.

## Règles de couleur

Rouge : bonne lettre, bon endroit.

Jaune : bonne lettre, mauvais endroit.

Sombre : lettre absente du mot secret.

## Structure

`Tusmo/TusmoApp.swift` contient le point d'entrée de l'app.

`Tusmo/ContentView.swift` contient le menu, les profils, les sélecteurs de
mode, l'écran de jeu, le calcul des indices et les fenêtres de fin de partie.

`Tusmo/Progression.swift` contient les cinq niveaux de difficulté, les modes
de jeu, le modèle de profil, la progression par thème et la sauvegarde locale
des profils.

`Tusmo/Mots.swift` contient les thèmes, leurs groupes éditoriaux et le tirage
d'un mot adapté au niveau du profil actif. Chaque thème possède sa propre
progression : une banque peut avoir des niveaux Maître courts ou vides, et
chaque terme reçoit un poids de notoriété indépendant de sa longueur.

`Tusmo/Pokemon.swift` contient les banques de Pokémon des générations I à IX
et leur tirage par niveau.

`docs/screenshots` contient les captures utilisées dans ce README.

## Version web

Une version web jouable se trouve dans `web/`. Elle reprend les banques Swift,
les profils, la progression par thème, le tournoi, la survie et le duo local.
Les comptes email permettent de synchroniser les profils entre navigateurs ;
la sauvegarde est versionnée pour détecter les modifications concurrentes.

Pour la lancer localement avec Node.js 24 et PostgreSQL :

```sh
cd web
npm install
npm run banks
DATABASE_URL=postgres://tusmo:mot-de-passe@localhost:5432/tusmo npm start
```

Le déploiement serveur utilise `web/compose.yaml` : PostgreSQL reste privé,
l’application écoute sur le réseau Docker et Nginx expose le port 80. Le
fichier `web/.env` ne doit jamais être commité. HTTPS et `COOKIE_SECURE=true`
seront activés dès qu’un domaine sera associé au serveur.
