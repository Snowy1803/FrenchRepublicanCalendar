//
//  FastGrid.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 07/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

@available(iOS 16.0, *)
struct FastGrid: Layout {
    var rowCount: Int
    var colCount: Int

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let lastSubview = subviews.last else {
            return .zero
        }
        let preferred = lastSubview.sizeThatFits(ProposedViewSize(
            width: proposal.width.map { $0 / CGFloat(colCount) },
            height: proposal.height.map { $0 / CGFloat(rowCount) }
        ))
        return CGSize(width: preferred.width * CGFloat(colCount), height: preferred.height * CGFloat(rowCount))
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let size = CGSize(width: bounds.width / CGFloat(colCount), height: bounds.height / CGFloat(rowCount))
        for row in 0..<rowCount {
            for col in 0..<colCount {
                let index = row * colCount + col
                if subviews.indices.contains(index) {
                    let view = subviews[index]
                    view.place(at: CGPoint(x: bounds.minX + size.width * CGFloat(col), y: bounds.minY + size.height * CGFloat(row)), proposal: .init(size))
                }
            }
        }
    }
}
