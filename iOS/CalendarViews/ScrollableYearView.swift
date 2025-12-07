//
//  ScrollableCalendarView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
@_spi(Advanced) import SwiftUIIntrospect

@available(iOS 16.0, *)
struct ScrollableYearView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var scrollToToday = false

    var body: some View {
        ScrollableYearUIView(scrollToToday: $scrollToToday)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        scrollToToday = true
                    } label: {
                        Text("Aujourd'hui")
                    }
                }
            }
            .navigationBarBackButtonHidden()
    }
}

@available(iOS 16.0, *)
struct ScrollableYearUIView: UIViewControllerRepresentable {
    @Binding var scrollToToday: Bool

    func makeUIViewController(context: Context) -> ScrollableYearController {
        ScrollableYearController()
    }
    func updateUIViewController(_ vc: ScrollableYearController, context: Context) {
        if scrollToToday {
            vc.scrollToToday(animate: true)
            DispatchQueue.main.async {
                scrollToToday = false
            }
        }
    }
}

@available(iOS 16.0, *)
struct ScrollableYearMonthView: View {
    var month: FrenchRepublicanDate

    var body: some View {
        NavigationLink {
            ScrollableCalendarView2()
        } label: {
            VStack {
                HStack {
                    Text(month, format: .republicanDate.day(.monthOnly))
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundStyle(FrenchRepublicanDate(date: .now).monthIndex == month.monthIndex ? Color.accentColor : .primary)
                    Spacer(minLength: 0)
                }
                .padding(.top)
                CalendarMonthView(month: month, halfWeek: month.components.month != 13, constantHeight: false, scale: 0) { date in
                    var isWeekend: Bool {
                        if let date {
                            date.isSansculottides || date.components.day! % 10 == 0
                        } else {
                            false
                        }
                    }
                    
                    var isToday: Bool {
                        if let date {
                            Calendar.gregorian.isDateInToday(date.date)
                        } else {
                            false
                        }
                    }
                    
                    var isValid: Bool {
                        date != nil
                    }
                    Text(isValid ? "\(date!.components.day!)" : "0")
                        .font(.system(size: 20 / 3, weight: .semibold))
                        .foregroundStyle(
                            !isValid ? .clear
                            : isToday ? .white
                            : isWeekend ? .secondary
                            : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .minimumScaleFactor(0.5)
                        .aspectRatio(1, contentMode: .fill)
                        .background(Circle().fill(
                            Color.accentColor.opacity(
                                isToday ? 1 : 0
                            )
                        ))
                }
            }
            .padding(.horizontal, 4)
            .foregroundStyle(.foreground)
        }
    }
}

@available(iOS 16.0, *)
struct ScrollableYearCell: View {
    var year: FrenchRepublicanDate

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(year, format: .republicanDate.year())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(FrenchRepublicanDate(date: .now).year == year.year ? Color.accentColor : .primary)
            Divider()
            ForEach(0..<4, id: \.self) { j in
                HStack {
                    ForEach(0..<3, id: \.self) { i in
                        ScrollableYearMonthView(month: FrenchRepublicanDate(day: 1, month: j * 3 + i + 1, year: year.year))
                    }
                }
            }
            HStack {
                ScrollableYearMonthView(month: FrenchRepublicanDate(day: 1, month: 13, year: year.year))
                Spacer()
            }
        }.padding()
    }
}

@available(iOS 16.0, *)
class ScrollableYearController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ScrollableToToday {
    var collectionView: UICollectionView!
    var registration: UICollectionView.CellRegistration<UICollectionViewCell, FrenchRepublicanDate>!
    var initialScroll = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let collectionView = CustomScrollToTopCollectionView(frame: .zero, collectionViewLayout: setupLayout())
        collectionView.delegate = self
        registration = UICollectionView.CellRegistration { cell, indexPath, year in
            cell.contentConfiguration = UIHostingConfiguration {
                ScrollableYearCell(year: year)
            }
        }
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        self.collectionView = collectionView
        self.view = collectionView
    }
    
    func setupLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(800))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        FrenchRepublicanDate(date: FrenchRepublicanDate.maxSafeDate).year - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: FrenchRepublicanDate(day: 1, month: 1, year: indexPath.item + 1))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialScroll {
            initialScroll = true
            scrollToToday(animate: false)
        }
    }
    
    func scrollToToday(animate: Bool) {
        let today = FrenchRepublicanDate(date: .now).year - 1
        collectionView.scrollToItem(at: IndexPath(item: today, section: 0), at: .top, animated: animate)
    }
}
