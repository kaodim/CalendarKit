//
//  DaySymbolLabel.swift
//  CalendarKit
//
//  Created by Luqman Fauzi on 08/01/2018.
//

import UIKit

class DaySymbolLabel: UILabel {

  var date: Date! {
    didSet {
      text = date.format(with: "EEEEE")
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  var style = DaySymbolsStyle()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    isUserInteractionEnabled = true
    textAlignment = .center
    clipsToBounds = true
  }

  func updateStyle(_ newStyle: DaySymbolsStyle) {
    style = newStyle
    updateState()
  }

  func updateState() {
    textColor = date.isToday ? style.todayColor : style.notTodayColor
    font = style.font
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
