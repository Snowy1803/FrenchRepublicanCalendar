//
//  OrbisecUI.swift
//  FrenchRepublicanCalendar & Pronote
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Orbisec. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct ShadowBox: ViewModifier {
    @Environment(\.colorScheme) var scheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(scheme == .dark ? Color(white: 0.1) : Color.white)
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.33), radius: scheme == .dark ? 0 : 5)
            .padding([.leading, .trailing, .top])
    }
}

extension View {
    func shadowBox() -> some View {
        self.modifier(ShadowBox())
    }
}

struct HomeWidget<Title: View, Content: View>: View {
    var title: Title
    var content: Content
    
    init(@ViewBuilder title: () -> Title, @ViewBuilder content: () -> Content) {
        self.title = title()
        self.content = content()
    }
    
    var body: some View {
        VStack {
            HStack {
                title.font(.headline)
            }
            Divider()
            content
        }.shadowBox()
        .fixedSize(horizontal: false, vertical: true)
    }
}


extension Image {
    @ViewBuilder static func decorative(systemName name: String) -> some View {
        Image(systemName: name).accessibility(hidden: true)
    }
}
