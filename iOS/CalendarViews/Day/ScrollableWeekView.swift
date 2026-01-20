import Eventually
import SwiftUI
import FrenchRepublicanCalendarCore
import EventKit

struct ScrollableWeekView: View {
    @Binding var selection: FrenchRepublicanDate
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var halfWeek: Bool {
        sizeClass == .compact
    }
    
    var daysPerPage: Int {
        halfWeek ? 5 : 10
    }
    
    var previous: FrenchRepublicanDate {
        FrenchRepublicanDate(dayInYear: selection.dayInYear - daysPerPage, year: selection.year)
    }
    
    var next: FrenchRepublicanDate {
        FrenchRepublicanDate(dayInYear: selection.dayInYear + daysPerPage, year: selection.year)
    }

    var body: some View {
        SwipeableView(current: $selection, previousItem: previous, nextItem: next, previousValid: FrenchRepublicanDate.safeRange.contains(previous.date), nextValid: FrenchRepublicanDate.safeRange.contains(next.date)) { week in
            CalendarMonthRow(month: week, row: row(item: week), halfWeek: halfWeek) {
                CalendarMonthItem(date: $0, selection: $selection, hardSelection: true)
            }
        }
    }
    
    func row(item: FrenchRepublicanDate) -> Int {
        let number = item.components.day! - 1
        return number / daysPerPage
    }
}
