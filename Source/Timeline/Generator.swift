import Foundation

public typealias DateTime = (hour: Int, respresation: String)

struct Generator {
  static func timeStrings24H() -> [String] {
    var numbers = [String]()
    numbers.append("00:00")

    for i in 1...24 {
      let i = i % 24
      var string = i < 10 ? "0" + String(i) : String(i)
      string.append(":00")
      numbers.append(string)
    }

    return numbers
  }

  static func timeStrings12H() -> [String] {
    var numbers = [String]()
    numbers.append("12")

    for i in 1...11 {
      let string = String(i)
      numbers.append(string)
    }

    var am = numbers.map { $0 + "AM" }
    var pm = numbers.map { $0 + "PM" }
    am.append("12PM")
    pm.removeFirst()
    pm.append("")
    return am + pm
  }

  static func timeStrings16H() -> [DateTime] {
    return [
      (7, "7AM"), (8, "8AM"), (9, "9AM"), (10, "10AM"), (11, "11AM"), (12, "12PM"),
      (13, "1PM"), (14, "2PM"), (15, "3PM"), (16, "4PM"), (17, "5PM"), (18, "6PM"),
      (19, "7PM"), (20, "8PM"), (21, "9PM"), (22, "10PM"), (23, "11PM")
    ]
  }
}
