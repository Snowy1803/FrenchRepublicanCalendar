# Calendrier Républicain Moderne
## (ou French Republican Calendar)

[English version](README.md)

Convertisseur Swift entre le Calendrier Grégorien et le Calendrier Républicain. Complètement testé et conforme à la version originale.

[Téléchargez sur l'App Store](https://apps.apple.com/fr/app/calendrier-républicain-moderne/id1509106182)

Fonctionnalités :
 - App iOS pour convertir entre les deux calendriers
 - App watchOS avec une complication pour toujours voir la date du jour sur le cadran de montre
 - Widget pour voir la date du jour sur l'écran d'accueil d'iOS 14
 - Tests pour que vous pouvez voir par vous même que mon implémentation est correcte 😤

Souvent, les convertisseurs en ligne renvoient des valeurs fausses : Soit ils oublient que 1800 et 1900 étaient sextiles mais non bissextiles, soit ils oublient que 2000 était lui bissextile. Vous pouvez souvent constater cela en convertissant aux environs du premier mars de ces années... Mon implémentation est complèrement testée et n'a pas ces problèmes.

Toutes les valeurs retournées sont correctes, jusqu'aux années 15 300 (grégoriennes), où la conversion Républicain vers Grégorien devient fausse, car c'est le moment où le 1er Vendémiaire et le 1er Janvier coincident.

L'interface graphique est 100% faite en SwiftUI, avec le cycle de vie classique UIKit pour la compatibilité iOS 13.
