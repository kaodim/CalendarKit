import UIKit
import CalendarKit
import DateToolsSwift

enum SelectedStyle {
  case dark
  case light
}

class ExampleController: DayViewController, DatePickerControllerDelegate {

  var data = [
    ["Breakfast at Tiffany's", "New York, 5th avenue"],
    ["Workout", "Tufteparken"],
    ["Meeting with Alex", "Home", "Oslo, Tjuvholmen"],
    ["Beach Volleyball", "Ipanema Beach", "Rio De Janeiro"],
    ["WWDC", "Moscone West Convention Center", "747 Howard St"],
    ["Google I/O", "Shoreline Amphitheatre", "One Amphitheatre Parkway"],
    ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️", "Oslo Gardermoen"],
    ["💻📲 Developing CalendarKit", "🌍 Worldwide"],
    ["Software Development Lecture", "Mikpoli MB310", "Craig Federighi"]
  ]

  var colors = [UIColor.blue, UIColor.yellow, UIColor.green, UIColor.red]

  var currentStyle = SelectedStyle.light

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Demo"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Dark",
      style: .plain,
      target: self,
      action: #selector(changeStyle)
    )
    let changeDateItem = UIBarButtonItem(
      title: "Change",
      style: .plain,
      target: self,
      action: #selector(presentDatePicker)
    )
    let todayItem = UIBarButtonItem(
      title: "Today",
      style: .done,
      target: self,
      action: #selector(changeToCurrentDate)
    )
    navigationItem.rightBarButtonItems = [todayItem, changeDateItem]
    navigationController?.navigationBar.isTranslucent = false

    let calendarStyle = CalendarStyle()
    calendarStyle.header.backgroundColor = .white
    calendarStyle.header.daySymbols.todayColor = .red
    calendarStyle.header.daySymbols.font = UIFont.systemFont(ofSize: 13.0)
    calendarStyle.header.daySelector.todayTextColor = .red
    calendarStyle.header.daySelector.textColor = .gray
    calendarStyle.header.daySelector.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
    calendarStyle.header.stripeIndicator.color = .red
    calendarStyle.timeline.timeIndicator.color = .red
    calendarStyle.timeline.lineColor = .lightGray
    calendarStyle.timeline.font = UIFont.boldSystemFont(ofSize: 11.0)
    
    updateStyle(calendarStyle)
    reloadData()
  }

  @objc func changeStyle() {
    var title: String!
    var style: CalendarStyle!

    if currentStyle == .dark {
      currentStyle = .light
      title = "Dark"
      style = StyleGenerator.defaultStyle()
    } else {
      title = "Light"
      style = StyleGenerator.darkStyle()
      currentStyle = .dark
    }
    updateStyle(style)
    navigationItem.leftBarButtonItem!.title = title
    navigationController?.navigationBar.barTintColor = style.header.backgroundColor
    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedStringKey.foregroundColor:style.header.swipeLabel.textColor
    ]
    reloadData()
  }

  @objc func changeToCurrentDate() {
    let today = Date()
    dayView.state?.move(to: today)
    dayView.scrollToCenterCurrentTimeIfNeeded()
  }

  @objc func presentDatePicker() {
    let picker = DatePickerController()
    picker.date = dayView.state!.selectedDate
    picker.delegate = self
    let navC = UINavigationController(rootViewController: picker)
    navigationController?.present(navC, animated: true, completion: nil)
  }

  func datePicker(controller: DatePickerController, didSelect date: Date?) {
    if let date = date {
      dayView.state?.move(to: date)
    }
    controller.dismiss(animated: true, completion: nil)
  }

  // MARK: - EventDataSource

  override func eventsForDate(_ date: Date) -> [EventDescriptor] {
    var date = date.add(TimeChunk.dateComponents(hours: Int(arc4random_uniform(10) + 5)))
    var events = [Event]()

    for _ in 0...5 {
      let event = Event()
      let duration = Int(arc4random_uniform(160) + 60)
      let datePeriod = TimePeriod(
        beginning: date,
        chunk: TimeChunk.dateComponents(minutes: duration)
      )
      event.datePeriod = datePeriod
      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      info.append("\(datePeriod.beginning!.format(with: "dd MMM"))")
      info.append("\(datePeriod.beginning!.format(with: "HH:mm")) - \(datePeriod.end!.format(with: "HH:mm"))")
      event.text = info.reduce("", {$0 + $1 + "\n"})
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      event.userInfo = info

      // Event styles are updated independently from CalendarStyle
      // hence the need to specify exact colors in case of Dark style
      if currentStyle == .dark {
        event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
        event.backgroundColor = event.color.withAlphaComponent(0.6)
      }

      events.append(event)

      let nextOffset = Int(arc4random_uniform(250) + 40)
      date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
    }

    return events
  }
  
  private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
  }

  // MARK: - DatePickerControllerDelegate

  override func dayViewDidSelectEventView(_ eventView: EventView) {
    guard let event = eventView.descriptor as? Event, let info = event.userInfo else { return }
    print("Event has been selected: \(info)")
  }

  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    guard let event = eventView.descriptor as? Event, let info = event.userInfo else { return }
    print("Event has been selected: \(info)")
  }
}
