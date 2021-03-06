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

  func scrollToParticularPosition() {
    if let yToScroll = timeline.currentTimeAtTheTop, (timeline.date.dateOnly() == timeline.currentTime.dateOnly()) {
      /// Scroll to current time
      setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll), animated: true)
    } else {
      /// Scroll to the top of content
      setContentOffset(.zero, animated: true)
    }
    animateNowRedLine()
  }
 
  func animateNowRedLine() {
    UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
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
