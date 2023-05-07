import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func addTrackerCategory(category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
    // MARK: - Public
    weak var delegate: CreateTrackerViewControllerDelegate?
    
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
        view.register(cellClass: EmojiCell.self)
        view.register(cellClass: ColorCell.self)
        return view
    }()
    private let cancelButton = ActionButton(colorType: .red, title: "Отменить")
    // Button that is changing depending on how the data is filled
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
        
    // Collection view setup   
    let params = GeometryParams(
        cellCount: 6,
        cellSize: CGSize(width: 40, height: 40),
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        spacing: 0
    )
    
    private var viewModel: CreateTrackerViewModel?
    
    func setViewModel(viewModel: CreateTrackerViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
//        viewModel?..bind { [weak self] category in
//            if let category {
//
//            } else {
//                self?.createButton.shakeSelf()
//            }
//        }
        
        viewModel?.$onCreateAllowedStateChange.bind { [weak self] isEnabled in
            self?.setCreateButton(enabled: isEnabled)
        }
    }
    
    // IndexPath representing selected item
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?
    // Animatable
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    // FeedbackGenerator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        addTargets()
        setupUI()
        setupLayout()
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
        viewModel?.createButtonTapped()
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
        mainScrollView.showsVerticalScrollIndicator = false
    }
    
    func setupLayout() {
        view.addSubviews(nameOfScreenLabel, container, buttonStackView)
        view.backgroundColor = .myWhite
        
        buttonStackView.addSubviews(cancelButton, createButton)
        
        container.addSubviews(mainScrollView)
        
        mainScrollView.addSubviews(mainStackView)
        
        mainStackView.addSubviews(
            titleTextfield,
            warningCharactersLabel,
            tableView,
            collectionView
        )
        mainStackView.setCustomSpacing(8, after: titleTextfield)
        mainStackView.setCustomSpacing(16, after: warningCharactersLabel)
        mainStackView.setCustomSpacing(32, after: tableView)
        
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
    
    private func setCreateButton(enabled: Bool) {
        if enabled {
            createButton.buttonState = .enabled
        } else {
            createButton.buttonState = .disabled
        }
        
    }
}

// MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {       
        viewModel?.numberOfRows ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: viewModel?.dataForTable[indexPath.row])
        return cell
    }
}
// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            let categoryName = viewModel?.userTracker.name ?? ""
            pushCategoryListViewController(withCategoryName: categoryName)
        } else {
            let selectedWeekDays = viewModel?.userTracker.weekDay ?? []
            pushScheduleListViewController(weekDays: selectedWeekDays)
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
            guard let self = self else { return }
            // save data
            self.viewModel?.userTracker.weekDay = weekDays
            self.viewModel?.dataForTableView.addSchedule(weekDays.weekdayStringShort())
            self.tableView.reloadData()
        }
    }
    
    private func pushCategoryListViewController(withCategoryName name: String) {
        let categoryController = CategoriesListViewController()
        let viewModel = CategoriesListViewModel(categoryName: name)
        categoryController.set(viewModel: viewModel)
        navigationController?.pushViewController(categoryController, animated: true)
        // Call back
        categoryController.getHeaderOfCategory = { [weak self] header in
            guard let self = self else { return }
            self.viewModel?.userTracker.name = header
            self.viewModel?.dataForTableView.addCategory(header)
            self.tableView.reloadData()
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
        viewModel?.numberOfCollectionSections ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfItemsInSection(section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = viewModel?.getSection(indexPath) else {
            return UICollectionViewCell()
        }
        switch sectionType {
        case .emojiSection(let items):
            let cell: EmojiCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row])
            return cell
        case .colorSection(let items):
            let cell: ColorCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row].rawValue)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header: CollectionReusableView = collectionView.dequeueHeader(ofKind: kind, for: indexPath)
            header.configure(with: viewModel?.getSection(indexPath).title ?? "")
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
}
// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = viewModel?.getSection(indexPath) else { return }
        switch sectionType {
        case .emojiSection:
            collectionView.deselectOldSelectNew(type: EmojiCell.self,
                selectedEmojiIndexPath) { [weak self]  emoji in
                    
                    self?.viewModel?.userTracker.emoji = emoji
                }
        case .colorSection:
            collectionView.deselectOldSelectNew(type: ColorCell.self,
                selectedColorIndexPath) { [weak self]  color in
                    
                    self?.viewModel?.userTracker.color = color
                }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        // Save text as tracker Name
        if text.isEmpty {
            self.viewModel?.userTracker.name = nil
        } else {
            self.viewModel?.userTracker.name = text
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
