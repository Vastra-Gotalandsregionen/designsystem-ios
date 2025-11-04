import XCTest
@testable import DesignSystem

final class RecurrenceTests: XCTestCase {

    // MARK: - Helper Methods

    private func createDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)!
    }

    private func createDateTime(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)!
    }

    // MARK: - Daily Recurrence Tests

    func testDailyRecurrenceEveryDay() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-07")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        XCTAssertEqual(dates.count, 7, "Should return 7 days")
        // Verify first and last dates
        XCTAssertTrue(Calendar.current.isDate(dates.first!, inSameDayAs: start))
        XCTAssertTrue(Calendar.current.isDate(dates.last!, inSameDayAs: end))
    }

    func testDailyRecurrenceEverySecondDay() throws {
        let recurrence = Recurrence(frequency: 2, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 1, 3, 5, 7, 9 = 5 dates
        XCTAssertEqual(dates.count, 5, "Should return 5 dates (every 2nd day)")
    }

    func testDailyRecurrenceEveryThirdDay() throws {
        let recurrence = Recurrence(frequency: 3, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 1, 4, 7, 10 = 4 dates
        XCTAssertEqual(dates.count, 4, "Should return 4 dates (every 3rd day)")
    }

    func testDailyRecurrenceEveryWeek() throws {
        let recurrence = Recurrence(frequency: 7, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 1, 8, 15, 22, 29 = 5 dates
        XCTAssertEqual(dates.count, 5, "Should return 5 dates (every 7 days)")
    }

    func testDailyRecurrenceSingleDay() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-01")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        XCTAssertEqual(dates.count, 1, "Should return 1 date for single day interval")
    }

    // MARK: - Weekly Recurrence Tests

    func testWeeklyRecurrenceSingleWeekday() throws {
        let recurrence = Recurrence(frequency: 1, period: .week, weekdays: [.monday])
        let start = createDate("2025-01-01") // Wednesday
        let end = createDate("2025-01-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Mondays in January 2025: 6, 13, 20, 27 = 4 dates
        XCTAssertEqual(dates.count, 4, "Should return 4 Mondays")

        // Verify all returned dates are Mondays
        let calendar = Calendar.current
        for date in dates {
            XCTAssertEqual(calendar.component(.weekday, from: date), 2, "All dates should be Mondays")
        }
    }

    func testWeeklyRecurrenceMultipleWeekdays() throws {
        let recurrence = Recurrence(frequency: 1, period: .week, weekdays: [.monday, .wednesday, .friday])
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-07")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 1-7 2025: Wed 1, Fri 3, Mon 6 = 3 dates
        XCTAssertEqual(dates.count, 3, "Should return 3 dates (Mon, Wed, Fri)")
    }

    func testWeeklyRecurrenceEverySecondWeek() throws {
        let recurrence = Recurrence(frequency: 2, period: .week, weekdays: [.tuesday])
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // First week with Tuesday: Jan 7
        // Third week with Tuesday: Jan 21
        // = 2 dates (every 2nd week)
        XCTAssertEqual(dates.count, 2, "Should return 2 Tuesdays (every 2nd week)")
    }

    func testWeeklyRecurrenceAllWeekdays() throws {
        let recurrence = Recurrence(
            frequency: 1,
            period: .week,
            weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        )
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-07")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        XCTAssertEqual(dates.count, 7, "Should return all 7 days of the week")
    }

    func testWeeklyRecurrenceWeekendOnly() throws {
        let recurrence = Recurrence(frequency: 1, period: .week, weekdays: [.saturday, .sunday])
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // January 2025 has 4 Saturdays and 4 Sundays = 8 weekend days
        XCTAssertEqual(dates.count, 8, "Should return all weekend days")
    }

    func testWeeklyRecurrenceNoWeekdaysSpecified() throws {
        let recurrence = Recurrence(frequency: 1, period: .week, weekdays: nil)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-07")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Should return empty array when no weekdays specified
        XCTAssertEqual(dates.count, 0, "Should return empty array when weekdays is nil")
    }

    func testWeeklyRecurrenceEmptyWeekdaysArray() throws {
        let recurrence = Recurrence(frequency: 1, period: .week, weekdays: [])
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-07")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        XCTAssertEqual(dates.count, 0, "Should return empty array when weekdays array is empty")
    }

    // MARK: - Bug Fix Verification Test

    func testWeeklyRecurrenceBugMayToNovember2025() throws {
        let calendar = Calendar.current

        // Create a recurrence: Every week on Tuesday, Wednesday, Friday starting May 1st
        let recurrence = Recurrence(
            frequency: 1,
            period: .week,
            weekdays: [.tuesday, .wednesday, .friday]
        )

        // Create dates using ISO8601DateFormatter for precise timestamps
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let intervalStart = isoFormatter.date(from: "2025-04-30T22:00:00Z"),
              let intervalEnd = isoFormatter.date(from: "2025-11-04T22:59:59Z") else {
            XCTFail("Failed to create test dates")
            return
        }

        let interval = DateInterval(start: intervalStart, end: intervalEnd)
        let dates = recurrence.getRecurringDates(for: interval)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Check for Nov 4 (Tuesday) - should be included since interval ends at Nov 4 22:59:59
        let nov4 = dateFormatter.date(from: "2025-11-04")!
        let hasNov4 = dates.contains { calendar.isDate($0, inSameDayAs: nov4) }
        XCTAssertTrue(hasNov4, "Should include Tuesday Nov 4th")

        // The actual bug was: algorithm stops too early and misses the final week
        XCTAssertGreaterThan(dates.count, 79, "Should return more than 79 dates (bug returned exactly 79)")
    }

    // MARK: - Monthly Recurrence Tests

    func testMonthlyRecurrenceEveryMonth() throws {
        let recurrence = Recurrence(frequency: 1, period: .month, index: 15)
        let start = createDate("2025-01-01")
        let end = createDate("2025-12-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // 15th of each month for 12 months = 12 dates
        XCTAssertEqual(dates.count, 12, "Should return 12 dates (15th of each month)")

        let calendar = Calendar.current
        for date in dates {
            XCTAssertEqual(calendar.component(.day, from: date), 15, "All dates should be on the 15th")
        }
    }

    func testMonthlyRecurrenceEverySecondMonth() throws {
        let recurrence = Recurrence(frequency: 2, period: .month, index: 1)
        let start = createDate("2025-01-01")
        let end = createDate("2025-12-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // 1st of Jan, Mar, May, Jul, Sep, Nov = 6 dates
        XCTAssertEqual(dates.count, 6, "Should return 6 dates (every 2nd month)")
    }

    func testMonthlyRecurrenceEveryThirdMonth() throws {
        let recurrence = Recurrence(frequency: 3, period: .month, index: 10)
        let start = createDate("2025-01-01")
        let end = createDate("2025-12-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // 10th of Jan, Apr, Jul, Oct = 4 dates
        XCTAssertEqual(dates.count, 4, "Should return 4 dates (every 3rd month)")
    }

    func testMonthlyRecurrenceFirstDayOfMonth() throws {
        let recurrence = Recurrence(frequency: 1, period: .month, index: 1)
        let start = createDate("2025-01-01")
        let end = createDate("2025-06-30")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // 1st of Jan, Feb, Mar, Apr, May, Jun = 6 dates
        XCTAssertEqual(dates.count, 6, "Should return 6 dates (1st of each month)")

        let calendar = Calendar.current
        for date in dates {
            XCTAssertEqual(calendar.component(.day, from: date), 1, "All dates should be on the 1st")
        }
    }

    func testMonthlyRecurrenceLastDayOfMonth() throws {
        let recurrence = Recurrence(frequency: 1, period: .month, index: 31)
        let start = createDate("2025-01-01")
        let end = createDate("2025-03-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 31, Feb 28 (or skipped), Mar 31
        // This tests how the implementation handles months with fewer than 31 days
        XCTAssertGreaterThan(dates.count, 0, "Should return dates for months that have day 31")
    }

    func testMonthlyRecurrenceNoIndexSpecified() throws {
        // When index is nil, should use the day from the interval start
        let recurrence = Recurrence(frequency: 1, period: .month, index: nil)
        let start = createDate("2025-01-15") // 15th of the month
        let end = createDate("2025-03-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        let calendar = Calendar.current
        for date in dates {
            XCTAssertEqual(calendar.component(.day, from: date), 15, "Should use the 15th from start date")
        }
    }

    func testMonthlyRecurrenceStartMidMonth() throws {
        let recurrence = Recurrence(frequency: 1, period: .month, index: 10)
        let start = createDate("2025-01-15") // Start after the 10th
        let end = createDate("2025-03-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Should include Feb 10 and Mar 10 (Jan 10 is before start)
        XCTAssertEqual(dates.count, 2, "Should skip Jan 10 since it's before the start date")
    }

    // MARK: - Filter Parameter Tests

    func testRecurrenceWithFilter() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        // Filter to only include Jan 3-7
        // Note: filter needs to span the full day range since interval is normalized to endOfDay
        let filterStart = createDate("2025-01-03").startOfDay
        let filterEnd = createDate("2025-01-07").endOfDay
        let filter = DateInterval(start: filterStart, end: filterEnd)

        let dates = recurrence.getRecurringDates(for: interval, filter: filter)

        // The filter might exclude boundary dates depending on DateInterval.contains behavior
        // Should return dates from Jan 3 through Jan 7 (likely 4-5 dates)
        XCTAssertEqual(dates.count, 5, "Should return 5 dates within filter")

        // Verify all returned dates are within the expected range
        let calendar = Calendar.current
        for date in dates {
            let day = calendar.component(.day, from: date)
            XCTAssertGreaterThanOrEqual(day, 3, "All dates should be on or after Jan 3")
            XCTAssertLessThanOrEqual(day, 7, "All dates should be on or before Jan 7")
        }
    }

    func testRecurrenceWithNonOverlappingFilter() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        // Filter that doesn't overlap
        let filterStart = createDate("2025-02-01")
        let filterEnd = createDate("2025-02-10")
        let filter = DateInterval(start: filterStart, end: filterEnd)

        let dates = recurrence.getRecurringDates(for: interval, filter: filter)

        XCTAssertEqual(dates.count, 0, "Should return empty array when filter doesn't overlap")
    }

    // MARK: - RecurrenceDeviation Tests

    func testDeviationHideOccurrence() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-05")
        let interval = DateInterval(start: start, end: end)

        // Hide Jan 3
        let hideDate = createDate("2025-01-03")
        let deviation = RecurrenceDeviation(original: hideDate, isHidden: true)

        let dates = recurrence.getRecurringDates(for: interval, deviations: [deviation])

        // Should return Jan 1, 2, 4, 5 (4 dates, skipping Jan 3)
        XCTAssertEqual(dates.count, 4, "Should skip hidden date")

        let calendar = Calendar.current
        let hasHiddenDate = dates.contains { calendar.isDate($0, inSameDayAs: hideDate) }
        XCTAssertFalse(hasHiddenDate, "Hidden date should not be in results")
    }

    func testDeviationAdjustOccurrence() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-05")
        let interval = DateInterval(start: start, end: end)

        // Move Jan 3 to Jan 10
        let originalDate = createDate("2025-01-03")
        let adjustedDate = createDate("2025-01-10")
        let deviation = RecurrenceDeviation(original: originalDate, adjusted: adjustedDate)

        let dates = recurrence.getRecurringDates(for: interval, deviations: [deviation])

        let calendar = Calendar.current
        let hasOriginalDate = dates.contains { calendar.isDate($0, inSameDayAs: originalDate) }
        let hasAdjustedDate = dates.contains { calendar.isDate($0, inSameDayAs: adjustedDate) }

        XCTAssertFalse(hasOriginalDate, "Original date should be removed")
        XCTAssertTrue(hasAdjustedDate, "Adjusted date should be added")
    }

    func testDeviationMultipleDeviations() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        let deviations = [
            RecurrenceDeviation(original: createDate("2025-01-03"), isHidden: true),
            RecurrenceDeviation(original: createDate("2025-01-05"), adjusted: createDate("2025-01-15")),
            RecurrenceDeviation(original: createDate("2025-01-07"), isHidden: true)
        ]

        let dates = recurrence.getRecurringDates(for: interval, deviations: deviations)

        // Original: 10 dates (Jan 1-10)
        // Hidden: Jan 3, Jan 7 = -2
        // Moved: Jan 5 removed, Jan 15 added = 0 (net)
        // Total: 8 dates (Jan 1, 2, 4, 6, 8, 9, 10, 15)
        XCTAssertEqual(dates.count, 8, "Should handle multiple deviations correctly")
    }

    func testDeviationHiddenWithAdjustedDate() throws {
        // When isHidden is true, adjustedDate should be ignored
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-01-05")
        let interval = DateInterval(start: start, end: end)

        let deviation = RecurrenceDeviation(
            original: createDate("2025-01-03"),
            adjusted: createDate("2025-01-10"),
            isHidden: true
        )

        let dates = recurrence.getRecurringDates(for: interval, deviations: [deviation])

        let calendar = Calendar.current
        let hasAdjustedDate = dates.contains { calendar.isDate($0, inSameDayAs: createDate("2025-01-10")) }

        XCTAssertFalse(hasAdjustedDate, "Adjusted date should not be added when isHidden is true")
        XCTAssertEqual(dates.count, 4, "Should only remove the original date")
    }

    // MARK: - Codable Tests

    func testCodableEncoding() throws {
        let recurrence = Recurrence(
            frequency: 2,
            period: .week,
            index: 15,
            weekdays: [.monday, .friday]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(recurrence)

        XCTAssertNotNil(data, "Should encode successfully")

        // Verify it can be decoded back
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Recurrence.self, from: data)

        XCTAssertEqual(decoded, recurrence, "Decoded object should equal original")
    }

    func testCodableDecoding() throws {
        let json = """
        {
            "frequency": 3,
            "period": 1,
            "index": 10,
            "weekdays": [2, 4, 6]
        }
        """

        let decoder = JSONDecoder()
        let data = Data(json.utf8)
        let recurrence = try decoder.decode(Recurrence.self, from: data)

        XCTAssertEqual(recurrence.frequency, 3)
        XCTAssertEqual(recurrence.period, .week)
        XCTAssertEqual(recurrence.index, 10)
        XCTAssertEqual(recurrence.weekdays, [.monday, .wednesday, .friday])
    }

    func testDecodeFromStringValid() throws {
        let json = """
        {
            "frequency": 1,
            "period": 0,
            "index": null,
            "weekdays": null
        }
        """

        let recurrence = Recurrence.decodeFromString(json)

        XCTAssertNotNil(recurrence, "Should decode valid JSON")
        XCTAssertEqual(recurrence?.frequency, 1)
        XCTAssertEqual(recurrence?.period, .day)
        XCTAssertNil(recurrence?.index)
        XCTAssertNil(recurrence?.weekdays)
    }

    func testDecodeFromStringInvalid() throws {
        let invalidJSON = "{ invalid json }"

        let recurrence = Recurrence.decodeFromString(invalidJSON)

        XCTAssertNil(recurrence, "Should return nil for invalid JSON")
    }

    func testDecodeFromStringNil() throws {
        let recurrence = Recurrence.decodeFromString(nil)

        XCTAssertNil(recurrence, "Should return nil when input is nil")
    }

    func testDecodeFromStringEmpty() throws {
        let recurrence = Recurrence.decodeFromString("")

        XCTAssertNil(recurrence, "Should return nil for empty string")
    }

    // MARK: - Equatable Tests

    func testEqualityIdentical() throws {
        let r1 = Recurrence(frequency: 1, period: .day)
        let r2 = Recurrence(frequency: 1, period: .day)

        XCTAssertEqual(r1, r2, "Identical recurrences should be equal")
    }

    func testEqualityDifferentFrequency() throws {
        let r1 = Recurrence(frequency: 1, period: .day)
        let r2 = Recurrence(frequency: 2, period: .day)

        XCTAssertNotEqual(r1, r2, "Different frequencies should not be equal")
    }

    func testEqualityDifferentPeriod() throws {
        let r1 = Recurrence(frequency: 1, period: .day)
        let r2 = Recurrence(frequency: 1, period: .week, weekdays: [.monday])

        XCTAssertNotEqual(r1, r2, "Different periods should not be equal")
    }

    func testEqualityDifferentIndex() throws {
        let r1 = Recurrence(frequency: 1, period: .month, index: 10)
        let r2 = Recurrence(frequency: 1, period: .month, index: 15)

        XCTAssertNotEqual(r1, r2, "Different indices should not be equal")
    }

    func testEqualityDifferentWeekdays() throws {
        let r1 = Recurrence(frequency: 1, period: .week, weekdays: [.monday])
        let r2 = Recurrence(frequency: 1, period: .week, weekdays: [.tuesday])

        XCTAssertNotEqual(r1, r2, "Different weekdays should not be equal")
    }

    // MARK: - Hashable Tests

    func testHashable() throws {
        let r1 = Recurrence(frequency: 1, period: .week, weekdays: [.monday])
        let r2 = Recurrence(frequency: 1, period: .week, weekdays: [.monday])
        let r3 = Recurrence(frequency: 2, period: .week, weekdays: [.monday])

        var set = Set<Recurrence>()
        set.insert(r1)
        set.insert(r2) // Should not add (equal to r1)
        set.insert(r3)

        XCTAssertEqual(set.count, 2, "Set should contain 2 unique recurrences")
    }

    // MARK: - RecurrencePeriod Tests

    func testRecurrencePeriodCaseIterable() throws {
        let allCases = RecurrencePeriod.allCases

        XCTAssertEqual(allCases.count, 3, "Should have 3 period types")
        XCTAssertTrue(allCases.contains(.day))
        XCTAssertTrue(allCases.contains(.week))
        XCTAssertTrue(allCases.contains(.month))
    }

    func testRecurrencePeriodDescription() throws {
        XCTAssertEqual(RecurrencePeriod.day.description, "day")
        XCTAssertEqual(RecurrencePeriod.week.description, "week")
        XCTAssertEqual(RecurrencePeriod.month.description, "month")
    }

    func testRecurrencePeriodRawValue() throws {
        XCTAssertEqual(RecurrencePeriod.day.rawValue, 0)
        XCTAssertEqual(RecurrencePeriod.week.rawValue, 1)
        XCTAssertEqual(RecurrencePeriod.month.rawValue, 2)
    }

    // MARK: - RecurrenceWeekday Tests

    func testRecurrenceWeekdayCaseIterable() throws {
        let allCases = RecurrenceWeekday.allCases

        XCTAssertEqual(allCases.count, 7, "Should have 7 weekdays")
    }

    func testRecurrenceWeekdayDescription() throws {
        XCTAssertEqual(RecurrenceWeekday.monday.description, "mon")
        XCTAssertEqual(RecurrenceWeekday.tuesday.description, "tue")
        XCTAssertEqual(RecurrenceWeekday.wednesday.description, "wed")
        XCTAssertEqual(RecurrenceWeekday.thursday.description, "thu")
        XCTAssertEqual(RecurrenceWeekday.friday.description, "fri")
        XCTAssertEqual(RecurrenceWeekday.saturday.description, "sat")
        XCTAssertEqual(RecurrenceWeekday.sunday.description, "sun")
    }

    func testRecurrenceWeekdayRawValues() throws {
        // Raw values should match Calendar.Component.weekday values
        XCTAssertEqual(RecurrenceWeekday.sunday.rawValue, 1)
        XCTAssertEqual(RecurrenceWeekday.monday.rawValue, 2)
        XCTAssertEqual(RecurrenceWeekday.tuesday.rawValue, 3)
        XCTAssertEqual(RecurrenceWeekday.wednesday.rawValue, 4)
        XCTAssertEqual(RecurrenceWeekday.thursday.rawValue, 5)
        XCTAssertEqual(RecurrenceWeekday.friday.rawValue, 6)
        XCTAssertEqual(RecurrenceWeekday.saturday.rawValue, 7)
    }

    func testRecurrenceWeekdayComparable() throws {
        // Monday should come before Friday
        XCTAssertTrue(RecurrenceWeekday.monday < RecurrenceWeekday.friday)

        // Sunday should be treated as last (after Saturday)
        XCTAssertTrue(RecurrenceWeekday.saturday < RecurrenceWeekday.sunday)
        XCTAssertTrue(RecurrenceWeekday.friday < RecurrenceWeekday.sunday)

        // Sorting test
        let unsorted: [RecurrenceWeekday] = [.friday, .monday, .sunday, .wednesday]
        let sorted = unsorted.sorted()

        XCTAssertEqual(sorted, [.monday, .wednesday, .friday, .sunday])
    }

    // MARK: - RecurrenceDeviation Tests

    func testRecurrenceDeviationInit() throws {
        let original = createDate("2025-01-15")
        let adjusted = createDate("2025-01-16")

        let deviation = RecurrenceDeviation(original: original, adjusted: adjusted, isHidden: false)

        XCTAssertEqual(deviation.originalDate, original)
        XCTAssertEqual(deviation.adjustedDate, adjusted)
        XCTAssertFalse(deviation.isHidden)
    }

    func testRecurrenceDeviationDefaultValues() throws {
        let original = createDate("2025-01-15")
        let deviation = RecurrenceDeviation(original: original)

        XCTAssertEqual(deviation.originalDate, original)
        XCTAssertNil(deviation.adjustedDate)
        XCTAssertFalse(deviation.isHidden)
    }

    func testRecurrenceDeviationEquality() throws {
        let original = createDate("2025-01-15")
        let adjusted = createDate("2025-01-16")

        let d1 = RecurrenceDeviation(original: original, adjusted: adjusted)
        let d2 = RecurrenceDeviation(original: original, adjusted: adjusted)

        XCTAssertEqual(d1, d2)
    }

    func testRecurrenceDeviationHashable() throws {
        let original = createDate("2025-01-15")
        let d1 = RecurrenceDeviation(original: original)
        let d2 = RecurrenceDeviation(original: original)

        var set = Set<RecurrenceDeviation>()
        set.insert(d1)
        set.insert(d2)

        XCTAssertEqual(set.count, 1, "Identical deviations should hash to the same value")
    }

    func testRecurrenceDeviationCodable() throws {
        let original = createDate("2025-01-15")
        let adjusted = createDate("2025-01-16")
        let deviation = RecurrenceDeviation(original: original, adjusted: adjusted, isHidden: false)

        let encoder = JSONEncoder()
        let data = try encoder.encode(deviation)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RecurrenceDeviation.self, from: data)

        XCTAssertEqual(decoded, deviation)
    }

    // MARK: - Edge Cases and Boundary Tests

    func testRecurrenceWithVeryLargeFrequency() throws {
        let recurrence = Recurrence(frequency: 100, period: .day)
        let start = createDate("2025-01-01")
        let end = createDate("2025-12-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 1, Apr 11, Jul 20, Oct 28 = 4 dates
        XCTAssertGreaterThan(dates.count, 0, "Should handle large frequency values")
        XCTAssertLessThan(dates.count, 10, "Large frequency should result in fewer dates")
    }

    func testRecurrenceAcrossYearBoundary() throws {
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDate("2024-12-30")
        let end = createDate("2025-01-02")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Dec 30, 31, Jan 1, 2 = 4 dates
        XCTAssertEqual(dates.count, 4, "Should handle year boundary correctly")
    }

    func testRecurrenceLeapYear() throws {
        // 2024 is a leap year
        let recurrence = Recurrence(frequency: 1, period: .month, index: 29)
        let start = createDate("2024-01-01")
        let end = createDate("2024-03-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Jan 29, Feb 29 (leap year!), Mar 29 = 3 dates
        XCTAssertGreaterThanOrEqual(dates.count, 2, "Should handle leap year")

        let calendar = Calendar.current
        let hasFeb29 = dates.contains {
            calendar.component(.month, from: $0) == 2 && calendar.component(.day, from: $0) == 29
        }
        XCTAssertTrue(hasFeb29, "Should include Feb 29 in leap year")
    }

    func testRecurrenceNonLeapYear() throws {
        // 2025 is not a leap year
        let recurrence = Recurrence(frequency: 1, period: .month, index: 29)
        let start = createDate("2025-01-01")
        let end = createDate("2025-03-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        let calendar = Calendar.current
        let hasFeb29 = dates.contains {
            calendar.component(.month, from: $0) == 2 && calendar.component(.day, from: $0) == 29
        }
        XCTAssertFalse(hasFeb29, "Should not include Feb 29 in non-leap year")
    }

    func testRecurrenceEmptyInterval() throws {
        // Start date after end date
        let recurrence = Recurrence(frequency: 1, period: .month, index: 31)
        let start = createDate("2025-01-10")
        let end = createDate("2025-01-10")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Should handle gracefully (likely return empty or minimal results)
        XCTAssertEqual(dates.count, 0, "Should handle invalid interval gracefully")
    }

    func testRecurrenceVeryLongInterval() throws {
        // Test over multiple years
        let recurrence = Recurrence(frequency: 1, period: .month, index: 1)
        let start = createDate("2020-01-01")
        let end = createDate("2025-12-31")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // 6 years * 12 months = 72 dates
        XCTAssertEqual(dates.count, 72, "Should handle long intervals correctly")
    }

    func testRecurrenceWithTimestamps() throws {
        // Test that times are normalized to start/end of day
        let recurrence = Recurrence(frequency: 1, period: .day)
        let start = createDateTime("2025-01-01T14:30:00Z")
        let end = createDateTime("2025-01-03T09:15:00Z")
        let interval = DateInterval(start: start, end: end)

        let dates = recurrence.getRecurringDates(for: interval)

        // Should include Jan 1, 2, 3 despite the specific times
        XCTAssertEqual(dates.count, 3, "Should normalize to full days")
    }
}
