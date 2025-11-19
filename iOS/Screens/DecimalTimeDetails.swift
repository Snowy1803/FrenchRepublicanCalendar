//
//  DecimalTimeDetails.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 29/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeDetails: View {
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DecimalTimeWidget(link: false)
                Text("Le temps décimal fut officialisé le 4 frimaire An \(FrenchRepublicanDate(dayInYear: 1, year: 2).formattedYear), puis aboli le 18 germinal An \(FrenchRepublicanDate(dayInYear: 1, year: 3).formattedYear).\nUn jour est divisé en 10 heures décimales. Une heure décimale contient 100 minutes décimales, et chaque minute décimale contient 100 secondes décimales. Les dixièmes de seconde décimale sont également affichés ci-dessus.")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding([.top, .leading, .trailing])
                DecimalTimeConverterWidget()
                    .padding(.bottom)
                LinkWidget(
                    destination: SettingsView(),
                    imageSystemName: "globe.europe.africa",
                    title: Text("Fuseau horaire"),
                    data: Text(TimeZonePicker().timeZoneName(tz: FrenchRepublicanDateOptions.current.currentTimeZone))
                )
            }.notTooWide()
        }.navigationBarTitle("Temps décimal")
    }
}

struct DecimalTimeDetails_Previews: PreviewProvider {
    static var previews: some View {
        DecimalTimeDetails()
    }
}
