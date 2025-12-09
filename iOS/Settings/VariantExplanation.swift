//
//  VariantExplanation.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 04/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import FrenchRepublicanCalendarCore
import SwiftUI

struct VariantExplanation: View {
    var variant: FrenchRepublicanDateOptions.Variant

    var body: some View {
        ScrollView {
            Group {
                switch variant {
                case .original:
                    OriginalVariantExplanation()
                case .romme:
                    RommeVariantExplanation()
                case .delambre:
                    DelambreVariantExplanation()
                }
            }.padding().notTooWide()
        }.navigationTitle(variant.name)
    }
}

struct DelambreVariantExplanation: View {
    var origin: FrenchRepublicanDate {
        FrenchRepublicanDate(date: FrenchRepublicanDate.origin)
    }
    var creation: FrenchRepublicanDate {
        FrenchRepublicanDate(date: Date(timeIntervalSince1970: -5561532000))
    }
    var limit: FrenchRepublicanDate {
        FrenchRepublicanDate(date: FrenchRepublicanDateOptions.Variant.delambre.maxSafeDate)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ce modèle incarne l'idéal révolutionnaire : un calendrier détaché de la religion et des règles mathématiques fixes, pour se baser uniquement sur l'observation de la **Nature**.")
            Text("C'est cette variante qui a été utilisée par l'administration française jusqu'à ce qu'il soit aboli par Napoléon Ier, environ 12 ans plus tard. C'est également cette variante qui a été privilégiée pendant la Commune de Paris.")

            Text("Basé sur le Soleil")
                .font(.headline)

            Text("Contrairement au calendrier Grégorien, ou à d'autres variantes républicaines, le Modèle Delambre ne prédéfinit pas les années bissextiles selon une règle mathématique (comme \"tous les 4 ans\").")
            Text("Il respecte à la lettre l'**article III** du 5 octobre 1793 (\(creation, format: .republicanDate.day().year())), publié par la Convention Nationale :")
            Text("\"Le commencement de chaque année est fixé à minuit, commençant le jour où tombe l’équinoxe vrai d’automne pour l’observatoire de Paris\"")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.leading, 16)
            Text("Le calendrier commence ainsi à l'**équinoxe d'automne** (moment où la durée du jour égale celle de la nuit). Le \(origin, format: .republicanDate.day().year()), symboliquement, est aussi le premier jour après l'abolition de la monarchie.")

            Text("Comment nous calculons la date")
                .font(.headline)

            Text("Cette application utilise des données astronomiques, tout comme l'astronome **Jean-Baptiste Delambre** le faisait à l'époque.")
            Text("Le calcul est basé sur le temps solaire vrai au **méridien de Paris** (à l'Observatoire de Paris), soit 9min et 21s après l'heure de Greenwich (GMT).")
            Text("Le 1er Vendémiaire est déterminé par l'instant précis où le soleil traverse l'équateur céleste en automne. Si cet événement a lieu à 23h58 à Paris, l'année commence ce jour-là. S'il a lieu à 00h02, elle commence le lendemain.")
            Text("Ainsi, **les années sextiles** (les années à 366 jours, l'équivalent des années bissextiles dans le calendrier républicain) ne sont **pas régulières**. Elles interviennent tous les 4 à 5 ans, afin de toujours s'aligner parfaitement avec le Soleil.")

            Text("Limites")
                .font(.headline)

            Text("Pour garantir une exactitude scientifique absolue, nous utilisons les éphémérides fournies par l'IMCCE (Institut de mécanique céleste et de calcul des éphémérides).")
            Text("**Période couverte** : De l'\(origin, format: .republicanDate.year()) à l'\(limit, format: .republicanDate.year()) (soit en grégorien, de 1792 à 2999).")
            Text("**Source** : [Équinoxe d'automne de 1583 à 2999](https://www.imcce.fr/newsletter/docs/Equinoxe_automne_1583_2999.pdf) (P. ROCHER, IMCCE, Observatoire de Paris)")
            Text("Au-delà du millénaire actuel, les incertitudes sur la rotation de la Terre et les perturbations gravitationnelles rendent les prédictions à la seconde près (nécessaires pour les cas limites proches de minuit) moins fiables. C'est aussi une des raisons pour laquelle le Calendrier Républicain n'a pas tenu dans le temps : il était difficile pour l'époque de prédire avec certitude, quelles années allaient être sextiles.")
        }
    }
}

struct RommeVariantExplanation: View {
    var creation: FrenchRepublicanDate {
        FrenchRepublicanDate(day: 19, month: 8, year: 3)
    }
    var death: FrenchRepublicanDate {
        FrenchRepublicanDate(day: 29, month: 9, year: 3)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cette variante représente l'évolution rationnelle du calendrier : une tentative de remplacer une définition ambigüe du calendrier, par une **règle arithmétique** prévisible et perpétuelle. En effet, l'article X du décret du 5 octobre 1793, prévoyait qu'une Franciade, période entre deux années sextiles, dure 4 ans. Or, cela contredit directement l'article III de ce même décret, qui est suivi par le modèle Delambre.")
            Text("Conçue par **Gilbert Romme**, le mathématicien et principal concepteur du calendrier républicain, cette réforme fut proposée le \(creation, format: .republicanDate.day().year()) (\(creation.date, format: .dateTime.day().month().year())). Elle ne fut **jamais appliquée**. Condamné à mort le \(death, format: .republicanDate.day().year()) (\(death.date, format: .dateTime.day().month().year())) à la suite des émeutes de Prairial, Romme se suicida juste avant son exécution, laissant sa réforme inachevée et l'administration rester sur une définition ambigüe.")
            
            Text("Comment nous calculons la date")
                .font(.headline)
            
            Text("Ce modèle définit les années sextiles selon un algorithme fixe, assurant une régularité absolue. Une année est sextile si elle est divisible par 4, sauf si elle est divisible par 100 (non sextile), sauf si elle est divisible par 400 (sextile), sauf si elle est divisible par **4000** (non sextile).")
            Text("Cette dernière exception rend cette variante théoriquement plus précise que notre calendrier Grégorien actuel, si le calendrier républicain avait survécu pendant plusieurs millénaires (ce qui était optimiste de sa part). En effet, une année dure 365,242 **50** jours d'après le calendrier grégorien, 365,242 **25** jours d'après la Réforme de Romme, mais dans la réalité, la Terre met en moyenne 365,242 **19** jours entre deux équinoxes.")
            Text("Contrairement au modèle Delambre qui place le Jour de la Révolution (le jour ajouté au calendrier les années sextiles) tous les 4 à 5 ans, le modèle Romme les a tous les 4 ou 8 ans.")
            
            Text("Limites")
                .font(.headline)
            
            Text("Ce modèle est idéal pour ceux qui cherchent une projection facile dans le futur, sans dépendre de calculs astronomiques, et ce à l'infini. Cependant, comme cette réforme applique une logique mathématique stricte rétroactivement, elle peut créer des **décalages avec la réalité** historique. En effet, la première année sextile telle qu'appliquée par l'administration fut l'\(frcYear: 3), or, si on applique la Réforme de Romme, la première année sextile est l'\(frcYear: 4).")
            Text("Les dates calculées par ce modèle pour la période historique vont donc parfois différer d'un jour par rapport aux dates réellement vécues par les citoyens de la Révolution.")
        }
    }
}

struct OriginalVariantExplanation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cette variante tranche le conflit juridique dans le décret originel en favorisant la simplicité arithmétique sur l'astronomie. En effet, si l'article III du décret du 5 octobre 1793 demandait de suivre l'équinoxe, l'**Article X** disposait simplement qu'une période de quatre ans, appelée une Franciade, devait avoir un jour supplémentaire :")
            Text("En mémoire de la révolution qui, après quatre ans, a conduit la France au Gouvernement républicain, la période bissextile de quatre ans est appelée « la Franciade ».\nLe jour intercalaire qui doit terminer cette période est appelé le jour de « la Révolution ». Ce jour est placé après les cinq jours complémentaires.")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.leading, 16)
                
            Text("C'est cette méthode simplifiée qui fut utilisée *de facto* par l'administration et les tribunaux jusqu'à l'\(frcYear: 14) (1805), car elle permettait de prévoir les dates futures sans avoir besoin de consulter des astronomes chaque année. Le premier décalage entre cette variante et le modèle de Delambre, étant à partir de la fin de l'\(frcYear: 19), ce ne fut pas un problème.")
            Text("Pendant la Commune de Paris, par contre, c'est le Modèle Delambre (l'article III) qui fut privilégié par rapport à l'article X, afin de garder un modèle basé sur l'astronomie.")

            Text("Comment nous calculons la date")
                .font(.headline)

            Text("Ce modèle fonctionne exactement comme le calendrier Julien (celui de Jules César). Il définit une année sextile **tous les 4 ans**, sans exception. La première année sextile est fixée à l'an \(frcYear: 3), puis l'an \(frcYear: 7), l'an \(frcYear: 11), et ainsi de suite indéfiniment.")
            Text("C'est mathématiquement la variante la moins précise. En ajoutant un jour tous les 4 ans systématiquement, une année dure en moyenne **365,25** jours. Or, comme la Terre met en réalité 365,242 19 jours pour faire le tour du Soleil, ce calendrier prend un retard d'environ 3 jours tous les 400 ans.")
            Text("Ainsi, par rapport au calendrier Grégorien, ce modèle **se décale durablement** d'un jour à partir de 1800, 1900, 2100, etc.")

            Text("Limites")
                .font(.headline)

            Text("Ce modèle est un choix tout aussi **authentique** pour consulter des documents de la période 1792-1806 que le modèle Delambre, car il correspond aux dates utilisées officiellement à l'époque. Cependant, à cause de sa dérive temporelle à partir de 1800, il est **incompatible** avec la période de la Commune de Paris en l'\(frcYear: 79) (1871).")
            Text("Ce modèle n'est pas vraiment adapté pour la postérité, car elle est actuellement décalée d'environ 2 jours par rapport au Soleil.")
        }
    }
}

extension FrenchRepublicanDateOptions.Variant {
    var name: String {
        switch self {
        case .romme:
            return "Réforme de Romme"
        case .delambre:
            return "Modèle Delambre"
        case .original:
            return "Article X original"
        }
    }
}

extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(frcYear: Int) {
        self.appendInterpolation(FrenchRepublicanDate(dayInYear: 1, year: frcYear), format: .republicanDate.year())
    }
}
