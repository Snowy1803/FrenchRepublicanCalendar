//
//  DecimalTimeDetails.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 29/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeDetails: View {
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DecimalTimeWidget(link: false)
                Text("Le temps décimal fut officialisé le 4 frimaire An \(FrenchRepublicanDate(dayInYear: 1, year: 2).formattedYear), puis aboli le 18 germinal An \(FrenchRepublicanDate(dayInYear: 1, year: 3).formattedYear).\nUn jour est divisé en 10 heures décimale. Une heure décimale contient 100 minutes décimales, et chaque minute décimale contient 100 secondes décimales. Les dixièmes de seconde décimale sont également affichés ci-dessus.")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding()
//                ConverterWidget()
                .padding(.bottom)
            }.notTooWide()
        }.navigationBarTitle("Temps décimal")
    }
}

struct DecimalTimeDetails_Previews: PreviewProvider {
    static var previews: some View {
        DecimalTimeDetails()
    }
}
