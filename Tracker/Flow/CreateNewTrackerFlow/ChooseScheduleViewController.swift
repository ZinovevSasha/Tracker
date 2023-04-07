//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit
import SnapKit

protocol ChooseScheduleViewControllerDelegate: AnyObject {
    var weekDaysToShow: (([WeekDay]) -> Void)? { get }
}

final class ChooseScheduleViewController: UIViewController {
    // MARK: - Call Back
    var weekDaysToShow: (([WeekDay]) -> Void)?
    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .myWhite
        view.allowsSelection = false
        view.separatorColor = .myGray
        return view
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.myWhite, for: .normal)
        button.backgroundColor = .myBlack
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let nameOfScreenLabelToTop: CGFloat = 27
        static let tableViewSidesInset: CGFloat = 4
        static let tableViewToNameOfScreenLabelOffset: CGFloat = 14
        static let tableViewToReadyButtonOffset: CGFloat = -39
        static let readyButtonSideInsets: CGFloat = 20
        static let readyButtonHeight: CGFloat = 60
        static let readyButtonToBottomInset: CGFloat = 24
    }
    
    // MARK: - Data
    private var weekDays: [WeekDay] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
    private var selectedWeekDays: [Int: WeekDay] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Private @objc target action methods
    @objc private func handleReadyButton() {
        let orderedDays = selectedWeekDays
            .compactMap { $0.value }
            .sorted { $0.sortValue < $1.sortValue }
        weekDaysToShow?(orderedDays)
        dismiss(animated: true)
    }
}

// MARK: - Private Methods
private extension ChooseScheduleViewController {
    func initialise() {
        view.backgroundColor = .myWhite
        view.addSubviews(nameOfScreenLabel, tableView, readyButton)
        tableView.dataSource = self
        tableView.delegate = self
        readyButton.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.nameOfScreenLabelToTop),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -UIConstants.tableViewSidesInset),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.tableViewSidesInset),
            tableView.topAnchor.constraint(
                equalTo: nameOfScreenLabel.bottomAnchor,
                constant: UIConstants.tableViewToNameOfScreenLabelOffset),
            tableView.bottomAnchor.constraint(
                equalTo: readyButton.topAnchor,
                constant: UIConstants.tableViewToReadyButtonOffset),
            
            readyButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.readyButtonSideInsets),
            readyButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -UIConstants.readyButtonSideInsets),
            readyButton.heightAnchor.constraint(
                equalToConstant: UIConstants.readyButtonHeight),
            readyButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -UIConstants.readyButtonToBottomInset)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ChooseScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ScheduleTableViewCell.identifier,
                for: indexPath) as? ScheduleTableViewCell
        else {
            return UITableViewCell()
        }
        let info = weekDays[indexPath.row].fullDayName        
        cell.configure(with: info, number: selectedWeekDays[indexPath.row])
        cell.delegate = self        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChooseScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
