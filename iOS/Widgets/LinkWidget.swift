//
//  TodayWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct LinkWidget<Destination: View>: View {
    var destination: Destination
    var imageSystemName: String
    var title: Text
    var data: Text?
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image.decorative(systemName: imageSystemName)
                    .frame(width: 25)
                title
                Spacer()
                data
                    .foregroundColor(.secondary)
                Image.decorative(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(.secondary)
            }.foregroundColor(.primary)
        }.shadowBox(interactive: true)
    }
}
