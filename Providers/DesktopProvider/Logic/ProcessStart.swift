/// A process start instant: whole microseconds since the Unix epoch, which is
/// exactly what the kernel records (`proc_bsdinfo.pbi_start_tvsec` and
/// `pbi_start_tvusec`). Its one text form is the contract's canonical
/// `DesktopProcessStart`: UTC, `YYYY-MM-DDTHH:MM:SS.ffffffZ`.
struct ProcessStart: Equatable, Sendable {
    let microsecondsSinceEpoch: Int64

    init(microsecondsSinceEpoch: Int64) { self.microsecondsSinceEpoch = microsecondsSinceEpoch }

    init(seconds: Int64, microseconds: Int64) {
        self.init(microsecondsSinceEpoch: seconds * 1_000_000 + microseconds)
    }

    /// Nil unless `text` is the canonical form of a real instant from 1970 to
    /// 9999. Anything else is an input error; nothing is read leniently.
    init?(canonical text: String) {
        let bytes = Array(text.utf8)
        let shape = Array("dddd-dd-ddTdd:dd:dd.ddddddZ".utf8)
        guard bytes.count == shape.count else { return nil }
        var digits: [Int64] = []
        for (byte, expected) in zip(bytes, shape) {
            if expected == UInt8(ascii: "d") {
                guard (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte) else { return nil }
                digits.append(Int64(byte - UInt8(ascii: "0")))
            } else if byte != expected {
                return nil
            }
        }
        func number(_ range: Range<Int>) -> Int64 { digits[range].reduce(0) { $0 * 10 + $1 } }
        let (year, month, day) = (number(0..<4), number(4..<6), number(6..<8))
        let (hour, minute, second) = (number(8..<10), number(10..<12), number(12..<14))
        guard year >= 1970, (1...12).contains(month), (1...31).contains(day), hour < 24,
            minute < 60, second < 60
        else { return nil }
        let seconds = Self.days(year: year, month: month, day: day) * 86_400
            + hour * 3_600 + minute * 60 + second
        self.init(seconds: seconds, microseconds: number(14..<20))
        // A day its month does not have (02-30) would come back as another date.
        guard canonical == text else { return nil }
    }

    var canonical: String {
        let (seconds, micros) = microsecondsSinceEpoch.quotientAndRemainder(dividingBy: 1_000_000)
        let (days, inDay) = seconds.quotientAndRemainder(dividingBy: 86_400)
        let (year, month, day) = Self.civil(days: days)
        func pad(_ value: Int64, _ width: Int) -> String {
            let text = String(value)
            return String(repeating: "0", count: max(0, width - text.count)) + text
        }
        return "\(pad(year, 4))-\(pad(month, 2))-\(pad(day, 2))T\(pad(inDay / 3_600, 2)):"
            + "\(pad(inDay / 60 % 60, 2)):\(pad(inDay % 60, 2)).\(pad(micros, 6))Z"
    }

    // Proleptic Gregorian day arithmetic, for dates from 1970 on:
    // https://howardhinnant.github.io/date_algorithms.html
    private static func days(year: Int64, month: Int64, day: Int64) -> Int64 {
        let y = month <= 2 ? year - 1 : year
        let era = y / 400
        let yearOfEra = y - era * 400
        let dayOfYear = (153 * (month > 2 ? month - 3 : month + 9) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    private static func civil(days: Int64) -> (Int64, Int64, Int64) {
        let z = days + 719_468
        let era = z / 146_097
        let dayOfEra = z - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let mp = (5 * dayOfYear + 2) / 153
        let month = mp < 10 ? mp + 3 : mp - 9
        return (yearOfEra + era * 400 + (month <= 2 ? 1 : 0), month, dayOfYear - (153 * mp + 2) / 5 + 1)
    }
}
