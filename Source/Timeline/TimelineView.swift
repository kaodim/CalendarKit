import UIKit
import Neon
import DateToolsSwift


protocol TimelineViewDelegate: class {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int)
}

public class TimelineView: UIView, ReusableView {

  weak var delegate: TimelineViewDelegate?

  weak var eventViewDelegate: EventViewDelegate?

  var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
    return Date()
  }

  var eventViews = [EventView]()
  var eventDescriptors = [EventDescriptor]() {
    didSet {
      recalculateEventLayout()
      prepareEventViews()
      setNeedsLayout()
    }
  }
  var pool = ReusePool<EventView>()

  var firstEventYPosition: CGFloat? {
    return eventDescriptors.sorted{$0.frame.origin.y < $1.frame.origin.y}
      .first?.frame.origin.y
  }

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

  var style = TimelineStyle()

  var verticalDiff: CGFloat = 50
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 45.0

  var horizontalEventInset: CGFloat = 3

  var fullHeight: CGFloat {
    return verticalInset * 2 + verticalDiff * CGFloat(times.count)
  }

  var calendarWidth: CGFloat {
    return bounds.width - leftInset
  }
    
  var dateStyle: DateStyle = .sixteenHour {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [DateTime] {
    return Generator.timeStrings16H()
  }

  fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

  var isToday: Bool {
    return date.isToday
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    addSubview(nowLine)
    
    // Add long press gesture recognizer
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if (gestureRecognizer.state == .began) {
      // Get timeslot of gesture location
      let pressedLocation = gestureRecognizer.location(in: self)
      let percentOfHeight = (pressedLocation.y - verticalInset) / (bounds.height - (verticalInset * 2))
      let pressedAtHour: Int = Int(CGFloat(times.count) * percentOfHeight)
      delegate?.timelineView(self, didLongPressAt: pressedAtHour)
    }
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    nowLine.updateStyle(style.timeIndicator)
    dateStyle = style.dateStyle
    
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    let mutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    mutableParagraphStyle.lineBreakMode = .byWordWrapping
    mutableParagraphStyle.alignment = .center
    let paragraphStyle = mutableParagraphStyle.copy() as! NSParagraphStyle

    let attributes: [NSAttributedStringKey : Any] = [
      NSAttributedStringKey.paragraphStyle: paragraphStyle,
      NSAttributedStringKey.foregroundColor: style.timeColor,
      NSAttributedStringKey.font: style.font
    ]

    for (i, time) in times.map({ $0.respresation }).enumerated() {
      let iFloat = CGFloat(i)
      let lineContext = UIGraphicsGetCurrentContext()
      lineContext?.interpolationQuality = .none
      lineContext?.saveGState()
      lineContext?.setStrokeColor(self.style.lineColor.cgColor)
      lineContext?.setLineWidth(onePixel)
      lineContext?.translateBy(x: 0, y: 0.5)

      /// Draw horizontal line
      let targetY = verticalInset + iFloat * verticalDiff
      lineContext?.beginPath()
      lineContext?.move(to: CGPoint(x: 0, y: targetY))
      lineContext?.addLine(to: CGPoint(x: (bounds).width, y: targetY))
      lineContext?.strokePath()
      lineContext?.restoreGState()

      let fontSize = style.font.pointSize
      let timeRect = CGRect(
        x: 0,
        y: iFloat * verticalDiff + verticalInset + 5.0,
        width: leftInset,
        height: fontSize + 2
      )
      let timeString = NSString(string: time)
      timeString.draw(in: timeRect, withAttributes: attributes)
    }

    /// Draw closure horizontal line
    let closureHorizontalContext = UIGraphicsGetCurrentContext()
    let targetY = fullHeight - verticalInset
    closureHorizontalContext?.interpolationQuality = .none
    closureHorizontalContext?.saveGState()
    closureHorizontalContext?.setStrokeColor(self.style.lineColor.cgColor)
    closureHorizontalContext?.setLineWidth(onePixel)
    closureHorizontalContext?.translateBy(x: 0, y: 0.5)
    closureHorizontalContext?.beginPath()
    closureHorizontalContext?.move(to: CGPoint(x: 0, y: targetY))
    closureHorizontalContext?.addLine(to: CGPoint(x: (bounds).width, y: targetY))
    closureHorizontalContext?.strokePath()
    closureHorizontalContext?.restoreGState()

    /// Draw vertical line
    let verticalLineContext = UIGraphicsGetCurrentContext()
    verticalLineContext?.interpolationQuality = .none
    verticalLineContext?.saveGState()
    verticalLineContext?.setStrokeColor(self.style.lineColor.cgColor)
    verticalLineContext?.setLineWidth(onePixel)
    verticalLineContext?.translateBy(x: 0, y: 0.5)
    verticalLineContext?.beginPath()
    verticalLineContext?.move(to: CGPoint(x: leftInset, y: verticalInset))
    verticalLineContext?.addLine(to: CGPoint(x: leftInset, y: bounds.height - verticalInset))
    verticalLineContext?.strokePath()
    verticalLineContext?.restoreGState()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    recalculateEventLayout()
    layoutEvents()
    layoutNowLine()
  }

  func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
    } else {
      // Initialize date components with date values
      guard 7...23 ~= currentTime.hour else {
        /// If current time is not on the 7AM to 11PM range.
        nowLine.alpha = 0
        return
      }
      nowLine.alpha = 1
      bringSubview(toFront: nowLine)
      let size = CGSize(width: bounds.size.width, height: 20)
      let rect = CGRect(origin: .zero, size: size)
      nowLine.date = currentTime
      nowLine.frame = rect
      nowLine.frame.origin.y = dateToY(currentTime, isNowLine: true)
    }
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}

    for (idx, descriptor) in eventDescriptors.enumerated() {
      let eventView = eventViews[idx]
      eventView.frame = descriptor.frame
      eventView.updateWithDescriptor(event: descriptor)
    }
  }

  func recalculateEventLayout() {
    let sortedEvents = eventDescriptors.sorted {$0.datePeriod.beginning!.isEarlier(than: $1.datePeriod.beginning!)}

    var groupsOfEvents = [[EventDescriptor]]()
    var overlappingEvents = [EventDescriptor]()

    for event in sortedEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }

      let longestEvent = overlappingEvents.sorted{$0.datePeriod.seconds > $1.datePeriod.seconds}.first!
      let lastEvent = overlappingEvents.last!
      if longestEvent.datePeriod.overlaps(with: event.datePeriod) ||
        lastEvent.datePeriod.overlaps(with: event.datePeriod) {
        overlappingEvents.append(event)
        continue
      } else {
        groupsOfEvents.append(overlappingEvents)
        overlappingEvents.removeAll()
        overlappingEvents.append(event)
      }
    }

    groupsOfEvents.append(overlappingEvents)
    overlappingEvents.removeAll()

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)
      for (index, event) in overlappingEvents.enumerated() {
        let startY = dateToY(event.datePeriod.beginning!)
        let endY = dateToY(event.datePeriod.end!)
        let floatIndex = CGFloat(index)
        let x = leftInset + floatIndex / totalCount * calendarWidth
        let equalWidth = calendarWidth / totalCount
        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
      }
    }
  }

  func prepareEventViews() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    for _ in 0...eventDescriptors.endIndex {
      let newView = pool.dequeue()
      newView.delegate = eventViewDelegate
      if newView.superview == nil {
        addSubview(newView)
      }
      eventViews.append(newView)
    }
  }

  func prepareForReuse() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    setNeedsDisplay()
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date, isNowLine: Bool = false) -> CGFloat {
    if date.dateOnly() > self.date.dateOnly() {
      // Event ending the next day
      return CGFloat(times.count) * verticalDiff + verticalInset
    } else if date.dateOnly() < self.date.dateOnly() {
      // Event starting the previous day
      return verticalInset
    } else {
      guard let index = times.map({ $0.hour }).enumerated().filter({ $0.element == date.hour }).first?.offset else {
        return 0
      }
      let hourY = CGFloat(index) * verticalDiff + (isNowLine ? 0 : verticalInset)
      let minuteY = CGFloat(date.minute) * verticalDiff / 60
      return hourY + minuteY
    }
  }
}
