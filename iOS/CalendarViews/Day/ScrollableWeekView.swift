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
        let targetDay = selection.dayInYear - daysPerPage
        
        if targetDay < 1 {
            // Would go before start of year
            let prevYear = selection.year - 1
            let prevDate = FrenchRepublicanDate(dayInYear: 1, year: prevYear)
            let lastPage = lastPage(item: prevDate)
            let targetDay = (lastPage * daysPerPage) + 1 + currentIndex
            let maxDay = prevDate.dayCountThisYear
            return FrenchRepublicanDate(dayInYear: min(targetDay, maxDay), year: prevYear)
        }
        
        return FrenchRepublicanDate(dayInYear: targetDay, year: selection.year)
    }
    
    var next: FrenchRepublicanDate {
        let targetDay = selection.dayInYear + daysPerPage
        let maxDay = selection.dayCountThisYear
        
        if targetDay > maxDay {
            // Would go past end of year
            let currentPage = page(item: selection)
            let lastPage = lastPage(item: selection)
            if currentPage == lastPage {
                // Already on last page, go to next year
                let nextYear = selection.year + 1
                return FrenchRepublicanDate(dayInYear: 1 + currentIndex, year: nextYear)
            } else {
                // Not on last page, go to last page of current year
                let firstDayOfLastPage = (lastPage * daysPerPage) + 1
                let targetDay = firstDayOfLastPage + currentIndex
                return FrenchRepublicanDate(dayInYear: min(targetDay, maxDay), year: selection.year)
            }
        }
        
        return FrenchRepublicanDate(dayInYear: targetDay, year: selection.year)
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
    
    var currentIndex: Int {
        (selection.dayInYear - 1) % daysPerPage
    }
    
    func page(item: FrenchRepublicanDate) -> Int {
        (item.dayInYear - 1) / daysPerPage
    }
    
    func lastPage(item: FrenchRepublicanDate) -> Int {
        (item.dayCountThisYear - 1) / daysPerPage
    }
}
