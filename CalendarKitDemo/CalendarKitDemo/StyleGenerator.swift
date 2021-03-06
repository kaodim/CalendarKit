import CalendarKit

struct StyleGenerator {
  static func defaultStyle() -> CalendarStyle {
    return CalendarStyle()
  }

  static func darkStyle() -> CalendarStyle {
    let orange = UIColor.orange
    let dark = UIColor(white: 0.1, alpha: 1)
    let light = UIColor.lightGray
    let white = UIColor.white

    let selector = DaySelectorStyle()
    selector.textColor = white

    let daySymbols = DaySymbolsStyle()
    daySymbols.notTodayColor = white

    let swipeLabel = SwipeLabelStyle()
    swipeLabel.textColor = white

    let header = DayHeaderStyle()
    header.daySelector = selector
    header.daySymbols = daySymbols
    header.swipeLabel = swipeLabel
    header.backgroundColor = dark

    let timeline = TimelineStyle()
    timeline.timeIndicator.color = orange
    timeline.lineColor = light
    timeline.timeColor = light
    timeline.backgroundColor = dark

    let style = CalendarStyle()
    style.header = header
    style.timeline = timeline

    return style
  }
}
