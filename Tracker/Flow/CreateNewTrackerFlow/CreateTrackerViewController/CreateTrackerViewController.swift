import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func addTrackerCategory(category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
    // MARK: - Public
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    // MARK: - Configuration
    enum Configuration {
        case oneRow
        case twoRows
    }

    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let view = UILabel()
        view.text = "Новая привычка"
        view.font = .medium16
        view.textAlignment = .center
        return view
    }()
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()
    private let titleTextfield = TrackerUITextField(text: "Ведите название трекера")
    private let warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = "Ограничение 38 символов"
        view.font = .regular17
        view.textColor = .myRed
        view.textAlignment = .center
        return view
    }()
    private let tableView: UITableView = {
        let view = UITableView()
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.layer.cornerRadius = .cornerRadius
        view.register(cellClass: MyTableViewCell.self)
        return view
    }()
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.isScrollEnabled = false
        view.allowsMultipleSelection = false
        view.showsVerticalScrollIndicator = false
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
    
    private var dataForTableView = DataForTableInCreateTrackerController()
    private let dataForCollectionView = DataSourceEmojisColor().dataSource
    private let date: String
    private let trackerMaker = TrackerMaker()
    
    // User inputs
    private var user = User() {
        didSet {
            switch configuration {
            case .oneRow:
                changeAppearanceOfTracker(type: .occasional)
            case .twoRows:
                changeAppearanceOfTracker(type: .habit)
            }
        }
    }
    
    func changeAppearanceOfTracker(type: TrackerType) {
        if user.isUserGaveEnoughToCreateTracker(of: type) {
            if buttonState == .unselected {
                buttonState.toggle()
            }
        } else {
            if buttonState == .selected {
                buttonState.toggle()
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
    
    init(
        configuration: Configuration,
        date: String
    ) {
        self.configuration = configuration
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        addTargets()
        setupUI()
        setupLayout()
        configureButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if parametersCollectionViewHeight?.constant != collectionView.contentSize.height {
            parametersCollectionViewHeight?.constant = collectionView.contentSize.height
        }
    }
    
    // MARK: - Private @objc target action methods
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {        
        // if all fields are filled
        switch configuration {
        case .oneRow:
            createTracker(of: .occasional)
        case .twoRows:
            createTracker(of: .habit)
        }
    }
    
    func createTracker(of type: TrackerType) {
        guard user.isUserGaveEnoughToCreateTracker(of: type),
              let category = trackerMaker.createTrackerFrom(
                userInput: user,
                collectionData: dataForCollectionView,
                configuration: configuration,
                date: date) else {
            // if category cant be created shake button for better user experience
            feedbackGenerator.impactOccurred()
            createButton.shakeSelf()
            return
        }
        // Give newly created category to delegate
        delegate?.addTrackerCategory(category: category)
        createButton.isEnabled.toggle()
        dismiss(animated: false)
    }
}

// MARK: - Private methods
private extension CreateTrackerViewController {
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        titleTextfield.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func addTargets() {
        cancelButton.addTarget(
            self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(
            self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    func setupUI() {
        view.addSubviews(nameOfScreenLabel, container, buttonStackView)
        view.backgroundColor = .myWhite
        
        buttonStackView.addSubviews(cancelButton, createButton)
        
        container.addSubviews(mainScrollView)
        
        mainScrollView.addSubviews(mainStackView)
        mainScrollView.showsVerticalScrollIndicator = false
        
        mainStackView.addSubviews(
            titleTextfield,
            warningCharactersLabel,
            tableView,
            collectionView
        )
        mainStackView.setCustomSpacing(8, after: titleTextfield)
        mainStackView.setCustomSpacing(16, after: warningCharactersLabel)
        mainStackView.setCustomSpacing(32, after: tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 27),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: nameOfScreenLabel.bottomAnchor, constant: 27),
            container.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            mainScrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mainScrollView.topAnchor.constraint(equalTo: container.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                        
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.topAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(
                equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
            
            titleTextfield.heightAnchor.constraint(equalToConstant: .cellHeight),
            
            tableView.heightAnchor.constraint(
                equalToConstant: CGFloat(tableView.numberOfRows(inSection: .zero) * 75)
            ),
            
            cancelButton.heightAnchor.constraint(equalToConstant: .buttonsHeight),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            buttonStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: .trailingInset),
            buttonStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24)
        ])
        
        parametersCollectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: .zero)
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
            pushCategoryListViewController(withCategoryName: dataForTableView.categoryName)
        case .twoRows:
            if indexPath.row == .zero {
                pushCategoryListViewController(withCategoryName: dataForTableView.categoryName)
            } else {
                pushScheduleListViewController(weekDays: user.selectedWeekDay ?? [])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
    
    // Private
    private func pushScheduleListViewController(weekDays: Set<Int>) {
        let scheduleController = ChooseScheduleViewController(weekDays: weekDays)
        navigationController?.pushViewController(scheduleController, animated: true)
        // Call back
        scheduleController.weekDaysToShow = { [weak self] weekDays in
            // save data
            self?.user.setWeekDay(weekDays)
            // update ui
            self?.dataForTableView.addSchedule(weekDays.weekdayStringShort())
            self?.tableView.reloadData()
        }
    }
    
    private func pushCategoryListViewController(withCategoryName name: String) {
        let categoryController = CategoriesListViewController()
        let viewModel = CategoriesListViewModel(categoryName: name)
        categoryController.set(viewModel: viewModel)
        navigationController?.pushViewController(categoryController, animated: true)
        // Call back
        categoryController.getHeaderOfCategory = { [weak self] header in
            self?.user.setCategory(header)
            // update ui
            self?.dataForTableView.addCategory(header)
            self?.tableView.reloadData()
        }
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
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
                oldCell.highlightUnhighlight() // set old cell
            } configureSelectedCell: { [weak self]  newCell, indexPath, isSameCell in
                guard let newCell = newCell as? TrackerEmojiCollectionViewCell else { return }
                newCell.highlightUnhighlight() // set new cell
                isSameCell ? self?.user.setEmojiIndexPath(nil): self?.user.setEmojiIndexPath(indexPath)
            }
        case .colorSection:
            collectionView.deselectOldSelectNew(user.selectedColor) { oldCell in
                guard let oldCell = oldCell as? TrackerColorCollectionViewCell else { return }
                oldCell.addOrRemoveBorders() // set old cell
            } configureSelectedCell: { [weak self]  newCell, indexPath, isSameCell in
                guard let newCell = newCell as? TrackerColorCollectionViewCell else { return }
                newCell.addOrRemoveBorders() // set new cell
                isSameCell ? self?.user.setColorIndexPath(nil): self?.user.setColorIndexPath(indexPath)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
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
    
    // Private methods
    private func forbidEnterTextAnimationWillShowIf(_ isTextTooLong: Bool) {
        if isTextTooLong {
            let warningHeight: CGFloat = 20
            // Shake if label fully opened
            if warningLabelHeight?.constant == warningHeight {
                warningCharactersLabel.shakeSelf()
            }
            // Animate constraint to 20
            animateHeight(warningHeight)
        } else {
            // Animate constraint back to 0
            animateHeight(.zero)
        }
    }
    
    private func animateHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            if self.warningLabelHeight?.constant != height {
                self.warningLabelHeight?.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
}
