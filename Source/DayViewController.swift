import UIKit
import DateToolsSwift

open class DayViewController: UIViewController, EventDataSource, DayViewDelegate {

  public lazy var dayView: DayView = DayView()
  public var autoScrollToFirstEvent: Bool = true

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    view.tintColor = UIColor.red
    view.addSubview(dayView)
    dayView.dataSource = self
    dayView.delegate = self
    dayView.reloadData()
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dayView.autoScrollToFirstEvent = false
    dayView.scrollToFirstEventIfNeeded()
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    dayView.scrollToCenterCurrentTimeIfNeeded()
  }

  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if #available(iOS 11.0, *) {
      NSLayoutConstraint.activate([
        dayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        dayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        dayView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        dayView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    } else {
      NSLayoutConstraint.activate([
        dayView.topAnchor.constraint(equalTo: view.topAnchor),
        dayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        dayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        dayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      ])
    }
  }
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

  }

  open func reloadData() {
    dayView.reloadData()
  }

  open func updateStyle(_ newStyle: CalendarStyle) {
    dayView.updateStyle(newStyle)
  }

  open func eventsForDate(_ date: Date) -> [EventDescriptor] {
    return [Event]()
  }

  // MARK: DayViewDelegate

  open func dayViewDidSelectEventView(_ eventView: EventView) {

  }

  open func dayViewDidLongPressEventView(_ eventView: EventView) {

  }

  open func dayViewDidLongPressTimelineAtHour(_ hour: Int) {

  }

  open func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }

  open func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }
}
