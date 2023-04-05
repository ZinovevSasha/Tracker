//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func weekDaysDidSelected(_ days: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
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
    
    @objc func handleReadyButton() {
        var orderedDays = selectedWeekDays
            .flatMap { $0.value }
            .sorted { $0.sortValue < $1.sortValue }
        delegate?.weekDaysDidSelected(orderedDays)
        dismiss(animated: true)
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
}

// MARK: - Private Methods
private extension ScheduleViewController {
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
                constant: 27),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -4),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 4),
            tableView.topAnchor.constraint(
                equalTo: nameOfScreenLabel.bottomAnchor,
                constant: 14),
            tableView.bottomAnchor.constraint(
                equalTo: readyButton.topAnchor,
                constant: -39),
            
            readyButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            readyButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24)
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource {
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
        cell.delegate = self
        let info = weekDays[indexPath.row].fullDayName
        cell.configure(with: info)
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func daySelected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let selectedWeekDay = weekDays[indexPath.row]
        selectedWeekDays.updateValue(selectedWeekDay, forKey: indexPath.row)
    }
    
    func dayUnselected(on cell: ScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        selectedWeekDays.removeValue(forKey: indexPath.row)
    }
}
