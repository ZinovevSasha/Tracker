//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func daySelected(on cell: ScheduleTableViewCell)
    func dayUnselected(on cell: ScheduleTableViewCell)
}

final class ScheduleTableViewCell: UITableViewCell {
    static let identifier = String(describing: ScheduleTableViewCell.self)
    // MARK: - Public
    func configure(with info: String) {
        weakDayLabel.text = info
    }
    
    weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private properties
    private let weakDayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weakDaySwitch: UISwitch = {
        let weakDaySwitch = UISwitch()
        weakDaySwitch.onTintColor = .myBlue
        weakDaySwitch.backgroundColor = .myLightGrey
        weakDaySwitch.layer.cornerRadius = 16
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
    
    private var isSwitchOn = false
    
    // MARK: - Target Action
    @objc func handleWeakDaySwitch() {
        isSwitchOn.toggle()
        isSwitchOn ? delegate?.daySelected(on: self) : delegate?.dayUnselected(on: self)        
    }
}

// MARK: - Private methods
private extension ScheduleTableViewCell {
    func initialise() {
        weakDaySwitch.addTarget(self, action: #selector(handleWeakDaySwitch), for: .touchUpInside)
        stackView.addArrangedSubviews(weakDayLabel, weakDaySwitch)
        contentView.addSubview(stackView)
        contentView.backgroundColor = .myBackground
        
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
