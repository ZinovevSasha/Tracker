import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func addTrackerCategory(_ category: TrackerCategory)
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
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextfield = TrackerUITextField(text: "Ведите название трекера")

    private let warningCharactersLabel: UILabel = {
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
        view.register(cellClass: MyTableViewCell.self)
        view.delegate = self
        view.dataSource = self
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
    private let mainScrollView = UIScrollView()
    
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
    
    // Categories to pass to CategoryListViewController(categories: categories)
    private var categories: [TrackerCategory] = []
    private var lastRow: Int?
    
    // Days to pass to ChooseScheduleViewController(weekDays: days) to show them updated
    private var days: [WeekDay] = []
    
    private var dataForTableView = DataForTableInCreateTrackerController()
    private var dataForCollectionView = DataForCollectionInCreateTrackerController().dataSource
    private let trackerMaker = TrackerMaker()
    
    // User inputs still need to convert to emoji and color!
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
    
    init(configuration: Configuration, addCategories categories: [TrackerCategory]) {
        self.categories = categories
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
        configureButton()
    }
    
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
            if let category = trackerMaker.createTrackerFrom(
                userInput: user,
                tableData: dataForTableView.twoRows,
                collectionData: dataForCollectionView
            ) {
                // Give newly created category to delegate
                delegate?.addTrackerCategory(category)
                createButton.isEnabled.toggle()
                dismiss(animated: false)
            }
        } else {
            feedbackGenerator.impactOccurred()
            createButton.shakeSelf()
        }
    }
}

// MARK: - Private methods
private extension CreateTrackerViewController {
    func initialise() {
        titleTextfield.delegate = self
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
                self.createButton.colorType = .black
            }
        case .unselected:
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.createButton.colorType = .grey
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
        switch configuration {
        case .oneRow:
            let categoryController = CategoryListViewController(tempCategory: categories, lastRow: lastRow)
            navigationController?.pushViewController(categoryController, animated: true)
            // call back
            categoryController.trackerCategories =
            {  [weak self] categories, header, lastRow in
                self?.lastRow = lastRow
                self?.user.selectedCategory = header
                self?.categories = categories
                self?.dataForTableView.addCategory(header)
                tableView.reloadData()
            }
        case .twoRows:
            if indexPath.row == .zero {
                let categoryController = CategoryListViewController(tempCategory: categories, lastRow: lastRow)
                navigationController?.pushViewController(categoryController, animated: true)
                // call back
                categoryController.trackerCategories =
                { [weak self] categories, header, lastRow in
                    self?.lastRow = lastRow
                    self?.user.selectedCategory = header
                    self?.categories = categories
                    self?.dataForTableView.addCategory(header)
                    tableView.reloadData()
                }
            } else {
                // Presenting controller
                let scheduleController = ChooseScheduleViewController(weekDays: days)
                navigationController?.pushViewController(scheduleController, animated: true)
                // Configuring call back
                scheduleController.weekDaysToShow = { [weak self] days in
                    guard let self = self else { return }
                    
                    self.days = days
                    self.user.selectedWeekDay = days
                    self.dataForTableView.addSchedule(WeekDay.shortNamesFor(days) ?? "Error")
                    tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
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
        case .emojiSection(let items):
            return items.count
        case .colorSection(let items):
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataForCollectionView[indexPath.section]
        switch section {
        case .emojiSection(let items):
            let cell: TrackerEmojiCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row])
            return cell
        case .colorSection(let items):
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
        case .emojiSection:
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
        case .colorSection:
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
extension CreateTrackerViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool {
        // Save text as tracker Name
        if text.isEmpty {
            self.user.setTitle(nil)
        } else {
            self.user.setTitle(text)
        }
        
        let maxLength = 38
        let isTextTooLong = newLength > maxLength
        
        // Show animation if text more than 38, and shake if continue typing
        forbidEnterTextAnimationWillShowIf(isTextTooLong)
        return !isTextTooLong
    }
    
    func forbidEnterTextAnimationWillShowIf(_ isTextTooLong: Bool) {
        if isTextTooLong {
            let warningHeight: CGFloat = 20
            // Shake if label fully opened
            if warningLabelHeight?.constant == warningHeight {
                warningCharactersLabel.shakeSelf()
            }
            // Animate constraint to 20
            UIView.animate(withDuration: 0.3) {
                if self.warningLabelHeight?.constant != warningHeight {
                    self.warningLabelHeight?.constant = warningHeight
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            // Animate constraint back to 0
            UIView.animate(withDuration: 0.3) {
                if self.warningLabelHeight?.constant != .zero {
                    self.warningLabelHeight?.constant = .zero
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
