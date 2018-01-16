import UIKit

class TimelineContainer: UIScrollView, ReusableView {

  var timeline: TimelineView!

  override func layoutSubviews() {
    timeline.frame = CGRect(x: 0, y: 0, width: frame.width, height: timeline.fullHeight)
  }

  func prepareForReuse() {
    timeline.prepareForReuse()
  }

  func scrollToFirstEvent() {
    if let yToScroll = timeline.firstEventYPosition {
      setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll - 15), animated: true)
    }
  }

  func scrollToCenterCurrentTimeIfNeeded() {
    if let yNowLine = timeline.centerNowLineYPosition {
      if yNowLine > bounds.height {
        /// Scroll to bottom content, if red line offset screen.
        let yTarget = contentSize.height - bounds.size.height
        setContentOffset(CGPoint(x: contentOffset.x, y: yTarget), animated: true)
      } else {
        /// Scroll to top content, if red line inset screen.
        setContentOffset(.zero, animated: true)
      }
      animateNowRedLine()
    }
  }

  func animateNowRedLine() {
    UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.autoreverse], animations: {
      self.timeline.nowLine.circle.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
    }) { (isFinished) in
      if isFinished {
        self.timeline.nowLine.circle.transform = .identity
      }
    }
  }

  func scrollTo(hour24: Float) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    let padding: CGFloat = 8
    setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: true)
  }
}
