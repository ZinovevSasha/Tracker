import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
    // MARK: - Configuration
    enum Configuration {
        case oneRow
        case twoRows
    }
    
    // MARK: - Public
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let view = UILabel()
        view.text = "Новая привычка"
        view.font = .medium16
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var titleTextfield: UITextField = {
        let view = UITextField()
        view.delegate = self
        
        view.placeholder = "Ведите название трекера"
        view.leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height))
        view.leftViewMode = .always
        view.rightView = UIView(frame: CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height))
        view.rightViewMode = .always
        view.backgroundColor = .myBackground
        view.textColor = .myBlack
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        view.font = .regular17
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = "Ограничение 38 символов"
        view.font = .regular17
        view.textColor = .myRed
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var parametersTableView: UITableView = {
        let view = UITableView()
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.layer.cornerRadius = .cornerRadius
        view.separatorInset = .visibleCellSeparator
        view.register(cellClass: MyTableViewCell.self)
        view.dataSource = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var parametersCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        view.allowsMultipleSelection = false
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.registerHeader(CollectionReusableView.self)
        view.register(cellClass: TrackerEmojiCollectionViewCell.self)
        view.register(cellClass: TrackerColorCollectionViewCell.self)
        return view
    }()
    
    private let cancelButton = ActionButton(colorType: .red, title: "Отменить")
    private let createButton = ActionButton(colorType: .grey, title: "Создать")

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let container = UIView()
    private var mainScrollView = UIScrollView()
    
    
    private var indexPath: IndexPath?
    
    let params = GeometryParams(
        cellCount: 6,
        cellSize: CGSize(width: 40, height: 40),
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        spacing: 0
    )
    
    // MARK: - Model
    
    private var categories: [TrackerCategory] = []
    private var days: [Int: WeekDay] = [:]
    private var dataForTableView = DataForTableInCreateTrackerController()
    private var dataForCollectionView = DataForCollectionInCreateTrackerController().dataSource
    private let trackerMaker = TrackerMaker()
    

    private var user = User() {
        didSet {
            if user.isUserGaveEnoughToCreateTracker {
                if buttonState == .unselected {
                    buttonState.toggle()
                }
            } else {
                if buttonState == .selected {
                    buttonState.toggle()
                }
            }
        }
    }
    
    private var buttonState = State.unselected {
        didSet {
            configureButton()
        }
    }
    
    // MARK: - Init
    private var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
        configureButton()
    }
    
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if parametersCollectionViewHeight?.constant != parametersCollectionView.contentSize.height {
            parametersCollectionViewHeight?.constant = parametersCollectionView.contentSize.height
        }
    }
    
    // MARK: - Private @objc target action methods
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        if user.isUserGaveEnoughToCreateTracker {
            trackerMaker.createTrackerFrom(
                userInputData: user,
                tableData: dataForTableView.twoRows,
                collectionData: dataForCollectionView
            )
            createButton.isEnabled.toggle()
            dismiss(animated: false)
            presentingViewController?.dismiss(animated: true)
        } else {
            createButton.shakeSelf()
        }
    }
}

// MARK: - Private methods
private extension CreateTrackerViewController {
    func initialise() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        container.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.showsVerticalScrollIndicator = false
        
        view.backgroundColor = .myWhite
        view.addSubviews(nameOfScreenLabel, container, buttonStackView)
        buttonStackView.addArrangedSubviews(cancelButton, createButton)
        container.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubviews(
            titleTextfield,
            warningCharactersLabel,
            parametersTableView,
            parametersCollectionView
        )
        mainStackView.setCustomSpacing(8, after: titleTextfield)
        mainStackView.setCustomSpacing(16, after: warningCharactersLabel)
        mainStackView.setCustomSpacing(32, after: parametersTableView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 27),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            container.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            container.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            container.topAnchor.constraint(
                equalTo: nameOfScreenLabel.bottomAnchor,
                constant: 27),
            container.bottomAnchor.constraint(
                equalTo: buttonStackView.topAnchor,
                constant: -16),
            
            mainScrollView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(
                equalTo: container.trailingAnchor),
            mainScrollView.topAnchor.constraint(
                equalTo: container.topAnchor),
            mainScrollView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor),
            
            
            mainStackView.leadingAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.topAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
            
            titleTextfield.heightAnchor.constraint(equalToConstant: 75),
            
            parametersTableView.heightAnchor.constraint(
                equalToConstant: CGFloat(parametersTableView.numberOfRows(inSection: 0) * 75)
            ),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            buttonStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            buttonStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24)
        ])
        
        parametersCollectionViewHeight = parametersCollectionView.heightAnchor.constraint(equalToConstant: .zero)
        parametersCollectionViewHeight?.isActive = true
        
        warningLabelHeight = warningCharactersLabel.heightAnchor.constraint(equalToConstant: .zero)
        warningLabelHeight?.isActive = true
    }
    
    func configureButton() {
        switch buttonState {
        case .selected:
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.createButton.backgroundColor = .myBlack
                self.createButton.setTitleColor(.myWhite, for: .normal)
            }
        case .unselected:
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.createButton.backgroundColor = .myGray
                self.createButton.setTitleColor(.white, for: .normal)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch configuration {
        case .oneRow:
            return dataForTableView.oneRow.count
        case .twoRows:
            return dataForTableView.twoRows.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        switch configuration {
        case .oneRow:
            cell.configure(with: dataForTableView.oneRow[indexPath.row])
        case .twoRows:
            cell.configure(with: dataForTableView.twoRows[indexPath.row])
        }
        return cell
    }
}
// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryController = CategoryListViewController(categories: [
            TrackerCategory(header: "", trackers: [])
        ])
        categoryController.trackerCategories = { [weak self] category in
            
            
        }
        switch configuration {
        case .oneRow:
            present(categoryController, animated: true)
        case .twoRows:
            if tableView.cellIsFirst(at: indexPath) {
                present(categoryController, animated: true)
            } else {
                let scheduleController = ChooseScheduleViewController(weekDays: days)
                
                scheduleController.weekDaysToShow = { [weak self] days in
                    guard let self = self else { return }
                    self.days = days
                    
                    let orderedDays = days
                        .compactMap { $0.value }
                        .sorted { $0.sortValue < $1.sortValue }
                    let cell = tableView.cellForRow(at: indexPath) as? MyTableViewCell
                    self.user.selectedWeekDay = orderedDays
                    
                    if orderedDays.count == 7 {
                        self.dataForTableView.addSchedule(subtitle: "Каждый день")
                        cell?.configure(with: self.dataForTableView.twoRows[indexPath.row])
                    } else {
                        let days = orderedDays
                            .map { "\($0.dayShorthand)" }
                            .joined(separator: ", ")
                        self.dataForTableView.addSchedule(subtitle: days)
                        cell?.configure(with: self.dataForTableView.twoRows[indexPath.row])
                    }
                }
                present(scheduleController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
}
// MARK: - Layout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.emptySpaceWidth
        let size = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}
// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataForCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch dataForCollectionView[section] {
        case .firstSection(let items):
            return items.count
        case .secondSection(let items):
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataForCollectionView[indexPath.section]
        switch section {
        case .firstSection(let items):
            let cell: TrackerEmojiCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row])
            return cell
        case .secondSection(let items):
            let cell: TrackerColorCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row].rawValue)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header: CollectionReusableView = collectionView.dequeueHeader(ofKind: kind, for: indexPath)
            let section = dataForCollectionView[indexPath.section]
            header.configure(with: section.title)
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
}
// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sections = dataForCollectionView[indexPath.section]
        switch sections {
        case .firstSection:
            collectionView.deselectOldSelectNew(user.selectedEmoji) { oldCell in
                guard let oldCell = oldCell as? TrackerEmojiCollectionViewCell else { return }
                oldCell.highlightUnhighlight() // old cell
            } configureSelectedCell: { [weak self]  newCell, indexPath, isSameCell in
                guard let newCell = newCell as? TrackerEmojiCollectionViewCell else { return }
                if isSameCell {
                    newCell.highlightUnhighlight()
                    self?.user.selectedEmoji = nil
                } else {
                    newCell.highlightUnhighlight()
                    self?.user.selectedEmoji = indexPath
                }
            }
        case .secondSection:
            collectionView.deselectOldSelectNew(user.selectedColor) { oldCell in
                guard let oldCell = oldCell as? TrackerColorCollectionViewCell else { return }
                oldCell.addOrRemoveBorders() // old cell
            } configureSelectedCell: { [weak self]  newCell, indexPath, isSameCell in
                guard let newCell = newCell as? TrackerColorCollectionViewCell else { return }
                if isSameCell {
                    newCell.addOrRemoveBorders()
                    self?.user.selectedColor = nil
                } else {
                    newCell.addOrRemoveBorders()
                    self?.user.selectedColor = indexPath
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.isEmpty {
            user.setTitle(nil)
        } else {
            user.setTitle(updatedText)
        }

        let shouldChangeCharacter = shouldChangeCharactersIn(currentText: currentText, string: string, range: range)
        if updatedText.count > 38 && warningLabelHeight?.constant == 22 {
            self.warningCharactersLabel.shakeSelf()
        }
        showAlertAndAnimate(isHide: shouldChangeCharacter)
        return shouldChangeCharacter
    }

    private func shouldChangeCharactersIn(currentText: String, string: String, range: NSRange) -> Bool {
        let maxLength = 38
        let newLength = currentText.count + string.count - range.length
        return newLength <= maxLength
    }

    private func showAlertAndAnimate(isHide: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0) {
            if isHide {
                self.warningLabelHeight?.constant = .zero
            } else {
                self.warningLabelHeight?.constant = 22
            }
            self.view.layoutIfNeeded()
        }
    }
}