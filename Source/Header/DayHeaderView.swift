import UIKit
import DateToolsSwift

public class DayHeaderView: UIView {

  public var daysInWeek = 7

  public var calendar = Calendar.autoupdatingCurrent

  var style = DayHeaderStyle()

  weak var state: DayViewState? {
    willSet(newValue) {
      state?.unsubscribe(client: self)
    }
    didSet {
      state?.subscribe(client: self)
    }
  }

  var currentWeekdayIndex = -1

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 30

  lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
  lazy var indicator: DateStripeIndicator = DateStripeIndicator()
  let pagingScrollView = PagingScrollView<DaySelector>()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configurePages()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
    configurePages()
  }

  func configure() {
    [daySymbolsView, pagingScrollView].forEach {
      addSubview($0)
    }
    pagingScrollView.viewDelegate = self
    backgroundColor = style.backgroundColor
    layer.shadowColor = UIColor.lightGray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 1.5)
    layer.shadowOpacity = 0.5
    layer.shadowRadius = 1.0
  }

  func configurePages(_ selectedDate: Date = Date()) {
    for i in -1...1 {
      let daySelector = DaySelector(daysInWeek: daysInWeek)
      let date = selectedDate.add(TimeChunk.dateComponents(weeks: i))
      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      daySelector.delegate = self
    }
    let centerDaySelector = pagingScrollView.reusableViews[1]
    centerDaySelector.selectedDate = selectedDate
    currentWeekdayIndex = centerDaySelector.selectedIndex
  }

  func beginningOfWeek(_ date: Date) -> Date {
    let component = DateComponents(calendar: calendar, year: date.year, weekday: calendar.firstWeekday, weekOfYear: date.weekOfYear)
    return calendar.date(from: component)!
  }

  public func updateStyle(_ newStyle: DayHeaderStyle) {
    style = newStyle.copy() as! DayHeaderStyle
    daySymbolsView.updateStyle(style.daySymbols)
    pagingScrollView.reusableViews.forEach { daySelector in
      daySelector.updateStyle(style.daySelector)
    }
    backgroundColor = style.backgroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    pagingScrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
    pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)
    daySymbolsView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .underCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    updateIndicatorPosition(selectedIndex: 0)
    addSubview(indicator)
  }

  private func updateIndicatorPosition(selectedIndex: Int) {
    let itemWidth = bounds.width / CGFloat(daysInWeek)
    let itemOriginX = itemWidth * CGFloat(selectedIndex)
    indicator.frame = CGRect(x: itemOriginX, y: bounds.height - 2.5, width: itemWidth, height: 2.5)
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(_ date: Date) {
    state?.move(to: date)
  }
}

extension DayHeaderView: DayViewStateUpdating {
  public func move(from oldDate: Date, to newDate: Date) {
    let newDate = newDate.dateOnly()
    let centerDaySelector = pagingScrollView.reusableViews[1]
    let startDate = centerDaySelector.startDate.dateOnly()

    let daysFrom = newDate.days(from: startDate, calendar: calendar)
    let newStartDate = beginningOfWeek(newDate)

    if daysFrom < 0 {
      /// Swipe main content to the previous 7 days.
      /// Move 1 day backward before today on previous 7 days.
      pagingScrollView.reusableViews[0].startDate = newStartDate
      currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek) % daysInWeek
      pagingScrollView.scrollBackward()
    } else if daysFrom > daysInWeek - 1 {
      /// Swipe main content to the next 7 days.
      /// Move 1 day forward after last day in current 7 days.
      pagingScrollView.reusableViews[2].startDate = newStartDate
      currentWeekdayIndex = daysFrom % daysInWeek
      pagingScrollView.scrollForward()
    } else {
      /// Move to particulary date within current 7 days,
      /// by scrolling main content or select the date in header.
      /// or scroll directly the header to any week.
      centerDaySelector.selectedDate = newDate
      currentWeekdayIndex = daysFrom
    }
    /// Update current indicator stripe, for any date changes.
    updateIndicatorPosition(selectedIndex: currentWeekdayIndex)
  }
}

extension DayHeaderView: PagingScrollViewDelegate {

  func scrollviewWillChangeIndex() {
    /// Prepare changes for day symbol style
    daySymbolsView.prepareForReuse()
    /// Transformation change to stripe indicator position
    indicator.alpha = 0
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0.2, animations: { [weak self] in
        self?.indicator.alpha = 1.0
      })
    }
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let activeView = pagingScrollView.reusableViews[index]
    activeView.selectedIndex = currentWeekdayIndex

    let leftView = pagingScrollView.reusableViews[0]
    let rightView = pagingScrollView.reusableViews[2]

    leftView.startDate = activeView.startDate.add(TimeChunk.dateComponents(weeks: -1))
    rightView.startDate = activeView.startDate.add(TimeChunk.dateComponents(weeks: 1))

    state?.client(client: self, didMoveTo: activeView.selectedDate!)

    /// Update date symbols for weekly content changing.
    /// check if the 1st day of content is today.
    let firstDayCurrentWeek = beginningOfWeek(Date())
    let isOnCurrentWeek = firstDayCurrentWeek.compare(activeView.startDate) == .orderedSame
    daySymbolsView.configure(isOnCurrentWeek: isOnCurrentWeek)
  }
}
