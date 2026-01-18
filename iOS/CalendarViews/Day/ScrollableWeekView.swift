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
    
    var row: Int {
        let number = selection.components.day! - 1
        let count = halfWeek ? 5 : 10
        return number / count
    }

    var body: some View {
        CalendarMonthRow(month: selection, row: row, halfWeek: halfWeek) {
            CalendarMonthItem(date: $0, selection: $selection)
        }
    }
}
