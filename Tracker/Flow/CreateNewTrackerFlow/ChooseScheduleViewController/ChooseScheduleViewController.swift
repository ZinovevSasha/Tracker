//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit

protocol ChooseScheduleViewControllerDelegate: AnyObject {
    var weekDaysToShow: (([Int: WeekDay]) -> Void)? { get }
}

final class ChooseScheduleViewController: FrameViewController {
    // MARK: - Call Back
    var weekDaysToShow: (([Int: WeekDay]) -> Void)?
    // MARK: - Private properties
        
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.allowsSelection = false
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
    private let weekDays = WeekDay.array
    private var selectedWeekDays: [Int: WeekDay]
    
    init(weekDays: [Int: WeekDay] = [:]) {
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
        weekDaysToShow?(selectedWeekDays)
        dismiss(animated: true)
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
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInsetInset),
        ])
    }
}

// MARK: - UITableViewDataSource
extension ChooseScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScheduleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        cell.setCellCorners(in: tableView, at: indexPath)
        cell.configure(with: weekDays[indexPath.row].fullDayName, number: selectedWeekDays[indexPath.row])
        return cell
    }
    
//    private func roundCornersIn(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
//        if indexPath.row == .zero {
//            setCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], for: cell)
//        }
//        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//            setCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], for: cell)
//        }
//    }
//
//    private func setCorners(_ corners: CACornerMask, for cell: UITableViewCell) {
//        cell.contentView.layer.cornerRadius = .cornerRadius
//        cell.contentView.layer.maskedCorners = [corners]
//    }
}

// MARK: - UITableViewDelegate
extension ChooseScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = .noCellSeparator
        } else {
            cell.separatorInset = .visibleCellSeparator
        }
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension ChooseScheduleViewController: ScheduleTableViewCellDelegate {
    func weekDaySelected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let selectedWeekDay = weekDays[indexPath.row]
        selectedWeekDays.updateValue(selectedWeekDay, forKey: indexPath.row)
    }
    
    func weekDayUnselected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        selectedWeekDays.removeValue(forKey: indexPath.row)
    }
}
