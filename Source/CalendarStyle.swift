

public enum DateStyle {
    ///Times should be shown in the 12 hour format
    case twelveHour
    
    ///Times should be shown in the 24 hour format
    case twentyFourHour

    /// Times should be shown in the 17 hour format, from 07.00 to 23.00.
    case sixteenHour
    
    ///Times should be shown according to the user's system preference.
    case system
}

public class CalendarStyle: NSCopying {
  public var header = DayHeaderStyle()
  public var timeline = TimelineStyle()
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = CalendarStyle()
    copy.header = header.copy() as! DayHeaderStyle
    copy.timeline = timeline.copy() as! TimelineStyle
    return copy
  }
}

public class DayHeaderStyle: NSCopying {
  public var daySymbols = DaySymbolsStyle()
  public var daySelector = DaySelectorStyle()
  public var swipeLabel = SwipeLabelStyle()
  public var stripeIndicator = DayStripeStyle()
  public var backgroundColor = UIColor(white: 247/255, alpha: 1)
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DayHeaderStyle()
    copy.daySymbols = daySymbols.copy() as! DaySymbolsStyle
    copy.daySelector = daySelector.copy() as! DaySelectorStyle
    copy.swipeLabel = swipeLabel.copy() as! SwipeLabelStyle
    copy.stripeIndicator = stripeIndicator
    copy.backgroundColor = backgroundColor
    return copy
  }
}

public class DayStripeStyle: NSCopying {
  public var color: UIColor = UIColor.red
  public var height: CGFloat = 2.5
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DayStripeStyle()
    copy.color = color
    copy.height = height
    return copy
  }
}

public class DaySelectorStyle: NSCopying {
  public var textColor = UIColor.darkGray
  public var backgroundColor = UIColor.clear

  public var todayTextColor = UIColor.red
  public var todayBackgroundColor = UIColor.clear

  public var previousDayTextColor = UIColor.lightGray
  
  public var font = UIFont.systemFont(ofSize: 17.0, weight: .medium)

  public init() {}

  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DaySelectorStyle()
    copy.textColor = textColor
    copy.backgroundColor = backgroundColor
    copy.todayTextColor = todayTextColor
    copy.todayBackgroundColor = todayBackgroundColor
    copy.previousDayTextColor = previousDayTextColor
    copy.font = font
    return copy
  }
}

public class DaySymbolsStyle: NSCopying {
  public var todayColor = UIColor.red
  public var notTodayColor = UIColor.lightGray
  public var font = UIFont.systemFont(ofSize: 13.0)
  public var locale = Locale.autoupdatingCurrent
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DaySymbolsStyle()
    copy.todayColor = todayColor
    copy.notTodayColor = notTodayColor
    copy.font = font
    copy.locale = locale
    return copy
  }
}

public class SwipeLabelStyle: NSCopying {
  public var textColor = UIColor.black
  public var font = UIFont.systemFont(ofSize: 15)
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = SwipeLabelStyle()
    copy.textColor = textColor
    copy.font = font
    return copy
  }
}

public class TimelineStyle: NSCopying {
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = UIColor.lightGray
  public var lineColor = UIColor.lightGray
  public var backgroundColor = UIColor.white
  public var font = UIFont.boldSystemFont(ofSize: 11)
  public var dateStyle : DateStyle = .sixteenHour
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = TimelineStyle()
    copy.timeIndicator = timeIndicator.copy() as! CurrentTimeIndicatorStyle
    copy.timeColor = timeColor
    copy.lineColor = lineColor
    copy.backgroundColor = backgroundColor
    copy.font = font
    copy.dateStyle = dateStyle
    return copy
  }
}

public class CurrentTimeIndicatorStyle: NSCopying {
  public var color = UIColor.red
  public var font = UIFont.systemFont(ofSize: 11)
  public var dateStyle : DateStyle = .twelveHour
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = CurrentTimeIndicatorStyle()
    copy.color = color
    copy.font = font
    copy.dateStyle = dateStyle
    return copy
  }
}
