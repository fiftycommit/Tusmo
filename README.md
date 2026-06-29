# Tusmo

Tusmo est un petit jeu de mots en SwiftUI, dans l'esprit de Motus.

Un premier joueur choisit un mot secret. Le second tente de le retrouver en six essais. Après chaque proposition, les lettres changent de couleur : rouge quand la lettre est au bon endroit, jaune quand elle existe ailleurs dans le mot, sombre quand elle n'est pas présente.

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

## Lancer le projet

Ouvre `Tusmo.xcodeproj` avec Xcode, puis lance la cible `Tusmo` sur un simulateur iPhone ou un appareil iOS.

Le projet ne dépend pas d'un paquet externe. Toute la logique actuelle est dans `Tusmo/ContentView.swift`.

## Règles de couleur

Rouge : bonne lettre, bon endroit.

Jaune : bonne lettre, mauvais endroit.

Sombre : lettre absente du mot secret.

## Structure

`Tusmo/TusmoApp.swift` contient le point d'entrée de l'app.

`Tusmo/ContentView.swift` contient le menu, l'écran de jeu, le calcul des indices et les fenêtres de fin de partie.

`docs/screenshots` contient les captures utilisées dans ce README.
