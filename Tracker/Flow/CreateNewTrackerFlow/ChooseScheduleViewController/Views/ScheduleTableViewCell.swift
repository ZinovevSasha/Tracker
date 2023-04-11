//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func weekDaySelected(on cell: ScheduleTableViewCell)
    func weekDayUnselected(on cell: ScheduleTableViewCell)
}

final class ScheduleTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with info: String, number: WeekDay?) {
        weakDayLabel.text = info
        if number != nil {
            weakDaySwitch.isOn = true
        }
    }
    
    weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - Private properties
    private let weakDayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = .regular17
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weakDaySwitch: UISwitch = {
        let weakDaySwitch = UISwitch()
        weakDaySwitch.onTintColor = .myBlue
        weakDaySwitch.backgroundColor = .myLightGrey
        weakDaySwitch.layer.cornerRadius = .cornerRadius
        weakDaySwitch.layer.masksToBounds = true
        weakDaySwitch.translatesAutoresizingMaskIntoConstraints = false
        return weakDaySwitch
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func handleWeakDaySwitch(_ sender: UISwitch) {
        if sender.isOn {
            delegate?.weekDaySelected(on: self)
        } else {
            delegate?.weekDayUnselected(on: self)
        }
    }
}

// MARK: - Private methods
private extension ScheduleTableViewCell {
    func initialise() {
        weakDaySwitch.addTarget(self, action: #selector(handleWeakDaySwitch), for: .touchUpInside)
        stackView.addArrangedSubviews(weakDayLabel, weakDaySwitch)
        contentView.addSubview(stackView)
        contentView.backgroundColor = .myBackground
        separatorInset = .visibleCellSeparator
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor)
        ])
    }
}
