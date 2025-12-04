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
                    Text("TODO")
                case .romme:
                    Text("TODO")
                case .delambre:
                    DelambreVariantExplanation()
                }
            }.notTooWide()
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
            Text("Ce modèle représente l'essence la plus pure du projet révolutionnaire : un calendrier fondé non pas sur la tradition religieuse ou des cycles arithmétiques fixes, mais directement sur l'observation de la **Nature** et de la **Science**.")
            Text("C'est cette variante qui a été utilisée par l'administration Française jusqu'à ce qu'il soit aboli par Napoléon Ier, environ 12 ans plus tard. C'est également cette variante qui a été privilégiée pendant la Commune de Paris.")
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
            Text("Cette application utilise des données astronomiques, tout comme **Jean-Baptiste Delambre** le faisait à l'époque.")
            Text("Le calcul est basé sur le temps solaire vrai au **méridien de Paris** (à l'Observatoire de Paris), soit 9min et 21s après l'heure de Greenwich (GMT).")
            Text("Le 1er Vendémiaire est déterminé par l'instant précis où le soleil traverse l'équateur céleste en automne. Si cet événement a lieu à 23h58 à Paris, l'année commence ce jour-là. S'il a lieu à 00h02, elle commence le lendemain.")
            Text("Ainsi, **les années sextiles** (les années à 366 jours, l'équivalent des années bissextiles dans le calendrier républicain) ne sont **pas régulières**. Elles interviennent généralement tous les 4 ans (une Franciade), mais peuvent parfois attendre une année de plus pour s'aligner parfaitement avec le Soleil.")
            Text("Sources")
                .font(.headline)
            Text("Pour garantir une exactitude scientifique absolue, nous utilisons les éphémérides fournies par l'IMCCE (Institut de mécanique céleste et de calcul des éphémérides).")
            Text("**Période couverte** : De l'\(origin, format: .republicanDate.year()) à l'\(limit, format: .republicanDate.year()) (soit en grégorien, de 1792 à 2999).")
            Text("**Source** : [Équinoxe d'automne de 1583 à 2999](https://www.imcce.fr/newsletter/docs/Equinoxe_automne_1583_2999.pdf) (P. ROCHER, IMCCE, Observatoire de Paris)")
            Text("Au-delà du millénaire actuel, les incertitudes sur la rotation de la Terre et les perturbations gravitationnelles rendent les prédictions à la seconde près (nécessaires pour les cas limites proches de minuit) moins fiables. C'est aussi une des raisons pour laquelle le Calendrier Républicain n'a pas tenu dans le temps : il était difficile pour l'époque de prédire avec certitude, quelles années allaient être sextiles.")
        }
        .padding()
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
