import Foundation

extension Date {
    func getDayIndex() -> Int? {
        let calendar = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return calendar.day
    }
    func getWeekday() -> Int? {
        let calendar = Calendar.current.dateComponents([.weekday], from: self)
        return calendar.weekday
    }
    func getHour() -> Int? {
        let calendar = Calendar.current.dateComponents([.hour], from: self)
        return calendar.hour
    }
    func getMinutes() -> Int? {
        let calendar = Calendar.current.dateComponents([.minute], from: self)
        return calendar.minute
    }
}
