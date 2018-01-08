import UIKit
import Neon
import DateToolsSwift

protocol DaySelectorDelegate: class {
  func dateSelectorDidSelectDate(_ date: Date)
}

class DaySelector: UIView, ReusableView {

  weak var delegate: DaySelectorDelegate?

  var calendar = Calendar.autoupdatingCurrent

  var style = DaySelectorStyle()

  var daysInWeek = 7
  var startDate: Date! {
    didSet {
      configure()
    }
  }

  var selectedIndex = -1 {
    didSet {
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      if selectedIndex < dateLabels.count && selectedIndex > -1 {
        let label = dateLabels[selectedIndex]
        label.selected = true
      }
    }
  }

  var selectedDate: Date? {
    get {
      return dateLabels.filter{$0.selected == true}.first?.date as Date?
    }
    set(newDate) {
      if let newDate = newDate {
        selectedIndex = newDate.days(from: startDate, calendar: calendar)
      }
    }
  }

  var dateLabelWidth: CGFloat = 35

  var dateLabels = [DateLabel]()
  var symbolLabels = [DaySymbolLabel]()

  init(startDate: Date = Date(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly()
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews()
    configure()
  }

  override init(frame: CGRect) {
    startDate = Date().dateOnly()
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly()
    super.init(coder: aDecoder)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let symbolLabel = DaySymbolLabel()
      let label = DateLabel()
      symbolLabels.append(symbolLabel)
      dateLabels.append(label)
      addSubview(symbolLabel)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self, action: #selector(dateLabelDidTap(_:)))
      label.addGestureRecognizer(recognizer)
    }
  }

  func configure() {
    for (increment, label) in zip(symbolLabels, dateLabels).enumerated() {
      label.0.date = startDate.add(TimeChunk.dateComponents(days: increment))
      label.1.date = startDate.add(TimeChunk.dateComponents(days: increment))
    }
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle.copy() as! DaySelectorStyle
    dateLabels.forEach{ label in
      label.updateStyle(style)
    }
  }

  func prepareForReuse() {
    symbolLabels.forEach { $0.selected = false }
    dateLabels.forEach { $0.selected = false }
  }

  override func layoutSubviews() {
    let dateLabelsCount = CGFloat(dateLabels.count)
    var per = frame.size.width - dateLabelWidth * dateLabelsCount
    per /= dateLabelsCount
    let minX = per / 2

    for (i, label) in zip(symbolLabels, dateLabels).enumerated() {
      let symbolFrame = CGRect(x: minX + (dateLabelWidth + per) * CGFloat(i), y: 0, width: dateLabelWidth, height: 15.0)
      let dateFrame = CGRect(x: minX + (dateLabelWidth + per) * CGFloat(i), y: 15, width: dateLabelWidth, height: 20.0)
      label.0.frame = symbolFrame
      label.1.frame = dateFrame
    }
  }

  @objc func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let label = sender.view as? DateLabel {
      delegate?.dateSelectorDidSelectDate(label.date)
    } 
  }
}
