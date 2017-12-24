//
//  DateStripeIndicator.swift
//  CalendarKit
//
//  Created by Luqman Fauzi on 22/12/2017.
//

import UIKit

internal class DateStripeIndicator: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    backgroundColor = UIColor.red
    isUserInteractionEnabled = true
  }
}
