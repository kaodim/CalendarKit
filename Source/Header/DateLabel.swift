import UIKit
import DateToolsSwift

class DateLabel: UILabel {
    
  var date: Date! {
    didSet {
      text = String(date.day)
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  var style = DaySelectorStyle()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  override func layoutSubviews() {
    layer.cornerRadius = bounds.height / 2
  }

  func configure() {
    isUserInteractionEnabled = true
    textAlignment = .center
    clipsToBounds = true
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    updateState()
  }

  func updateState() {
    let isPreviousDay: Bool = date.isEarlier(than: Date()) && (text != Date().format(with: "dd"))
    if isPreviousDay {
      textColor = style.previousDayTextColor
      font = style.inactiveFont
    } else {
      textColor = date.isToday ? style.todayTextColor : style.textColor
      font = selected ? style.activeFont : style.inactiveFont
    }
    backgroundColor = style.backgroundColor
  }

  func animate(){
    UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve, animations: {
      self.updateState()
    })
  }

  override func tintColorDidChange() {
    updateState()
  }
}
