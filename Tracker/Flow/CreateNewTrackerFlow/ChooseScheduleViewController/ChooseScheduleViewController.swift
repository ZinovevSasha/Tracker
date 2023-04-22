import UIKit

protocol ChooseScheduleViewControllerDelegate: AnyObject {
    var weekDaysToShow: (([WeekDay]) -> Void)? { get }
}

final class ChooseScheduleViewController: FrameViewController {
    // MARK: - Call Back
    var weekDaysToShow: (([WeekDay]) -> Void)?
    // MARK: - Private properties
        
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.allowsSelection = true
        view.separatorStyle = .singleLine
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellClass: ScheduleTableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInsetInset: CGFloat = -16
        static let cellHeight: CGFloat = 75
    }
    
    // MARK: - DataToChangeStatesOfSwitchesAndGiveTextToLabels
    private var selectedWeekDays: [WeekDay]
    
    init(weekDays: [WeekDay]) {
        self.selectedWeekDays = weekDays
        super.init(
            title: "Расписание",
            buttonCenter: ActionButton(colorType: .black, title: "Готово")
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Private @objc target action methods
    override func handleButtonCenterTap() {
        weekDaysToShow?(selectedWeekDays.sorted())
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private Methods
private extension ChooseScheduleViewController {
    func initialise() {
        // Table in container:
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add all to container and constraint to it
        container.addSubview(tableView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInsetInset)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ChooseScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScheduleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let weekDays = WeekDay.array[indexPath.row].fullDayName
        let isSwitchOn = selectedWeekDays.map { $0.rawValue }.contains(indexPath.row)
        
        cell.setCorners(in: tableView, at: indexPath)
        cell.configure(with: weekDays, isSwitchOn: isSwitchOn)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ChooseScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIConstants.cellHeight
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension ChooseScheduleViewController: ScheduleTableViewCellDelegate {
    func weekDaySelected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let selectedWeekDay = WeekDay.array[indexPath.row]
        selectedWeekDays.append(selectedWeekDay)
    }
    
    func weekDayUnselected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        selectedWeekDays.removeAll { $0.rawValue == indexPath.row }
    }
}
