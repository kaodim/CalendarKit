import UIKit
import Neon

class CurrentTimeIndicator: UIView {
    
  let padding : CGFloat = 5
  var leftInset: CGFloat = 45.0

  /// Determines if times should be displayed in a 24 hour format. Defaults to the current locale's setting
  var is24hClock : Bool = true {
    didSet {
      updateDate()
    }
  }

  var date = Date() {
    didSet {
      updateDate()
    }
  }

  var circle = UIView()
  fileprivate var timeLabel = UILabel()
  fileprivate var line = UIView()

  var style = CurrentTimeIndicatorStyle()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    [timeLabel, line, circle].forEach {
      addSubview($0)
    }
    
    //Allow label to adjust so that am/pm can be displayed if format is changed.
    timeLabel.numberOfLines = 1
    timeLabel.adjustsFontSizeToFitWidth = true
    timeLabel.minimumScaleFactor = 0.5
    
    //The width of the label is determined by leftInset and padding. 
    //The y position is determined by the line's middle.
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.widthAnchor.constraint(equalToConstant: leftInset - (3 * padding)).isActive = true
    timeLabel.rightAnchor.constraint(equalTo: line.leftAnchor, constant: -padding).isActive = true
    timeLabel.centerYAnchor.constraint(equalTo: line.centerYAnchor).isActive = true
    timeLabel.baselineAdjustment = .alignCenters
    
    updateStyle(style)
  }
    
  func updateDate() {
    timeLabel.text = nil
    timeLabel.sizeToFit()
    setNeedsLayout()
  }

  override func layoutSubviews() {
    line.frame = CGRect(x: leftInset, y: bounds.height / 2, width: bounds.width, height: 2.5)

    circle.frame = CGRect(x: leftInset, y: 0, width: 8.0, height: 8.0)
    circle.center = CGPoint(x: leftInset, y: line.center.y)
    circle.layer.cornerRadius = circle.bounds.height / 2
  }

  func updateStyle(_ newStyle: CurrentTimeIndicatorStyle) {
    style = newStyle.copy() as! CurrentTimeIndicatorStyle
    timeLabel.textColor = style.color
    timeLabel.font = style.font
    circle.backgroundColor = style.color
    line.backgroundColor = style.color
    
    switch style.dateStyle {
    case .twelveHour:
        is24hClock = false
        break
    case .twentyFourHour:
        is24hClock = true
        break
    default:
        is24hClock = Locale.autoupdatingCurrent.uses24hClock()
        break
    }
  }
}
