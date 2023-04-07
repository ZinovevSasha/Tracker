import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
    // MARK: - Public
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let view = UILabel()
        view.text = "Новая привычка"
        view.font = UIFont.systemFont(ofSize: 16)
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
        view.placeholder = "Ведите название трекера"
        view.leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height))
        view.leftViewMode = .always
        view.rightView = UIView(frame: CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height))
        view.rightViewMode = .always
        view.backgroundColor = .myBackground
        view.textColor = .myBlack
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = "Ограничение 38 символов"
        view.font = .systemFont(ofSize: 17)
        view.textColor = .myRed
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var parametersTableView: UITableView = {
        let view = UITableView()
       
        view.separatorColor = .myGray
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .myWhite
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.layer.cornerRadius = 16
        view.dataSource = self
        view.delegate = self
        view.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.identifier)
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
       
        view.register(
            TrackerEmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerEmojiCollectionViewCell.identifier
        )
        view.register(
            TrackerColorCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerColorCollectionViewCell.identifier
        )
        
        view.register(
            CollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionReusableView.identifier
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let cancelButton: UIButton = {
        let view = UIButton(type: .system)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.myRed.cgColor
        view.setTitle("Отменить", for: .normal)
        view.setTitleColor(.myRed, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let createButton: UIButton = {
        let view = UIButton(type: .system)
        view.layer.cornerRadius = 16
        view.setTitle("Создать", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    private let sections = CreateTrackerCollectionViewSections().items
    private let trackerMaker = TrackerMaker()
    private var valuesForTrackerMaker = TrackerCreationHelper() {
        didSet {
            if valuesForTrackerMaker.isAllPropertiesFilled {
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
    
    private var buttonState = ButtonState.unselected {
        didSet {
            configureButton()
        }
    }
    
    private var dataForTableView: [RowData] {
        configuration.data
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
        if valuesForTrackerMaker.isAllPropertiesFilled {
            trackerMaker.createTrackerWith(
                values: valuesForTrackerMaker,
                sections: sections
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
            
            warningCharactersLabel.heightAnchor.constraint(equalToConstant: 0),
            
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
        
        parametersCollectionViewHeight = parametersCollectionView.heightAnchor.constraint(equalToConstant: 480)

        parametersCollectionViewHeight?.isActive = true
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
        return dataForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MyTableViewCell.identifier, for: indexPath) as? MyTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: dataForTableView[indexPath.row])
        return cell
    }
}
// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch configuration {
        case .oneRow:
            break
        case .twoRows:
            if indexPath.row == .zero {
                
            } else {
                let scheduleController = ChooseScheduleViewController()
                present(scheduleController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
        if tableView.numberOfRows(inSection: indexPath.section) == 1 || indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(section)
        switch dataSource[section] {
        case .firstSection(let items):
            return items.count
        case .secondSection(let items):
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataSource[indexPath.section]
        
        switch section {
        case .firstSection(let items):
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerEmojiCollectionViewCell.identifier,
                    for: indexPath) as? TrackerEmojiCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: items[indexPath.row])
            return cell
        case .secondSection(let items):
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerColorCollectionViewCell.identifier,
                    for: indexPath) as? TrackerColorCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: items[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableView.identifier, for: indexPath) as? CollectionReusableView
            else {
                return UICollectionReusableView()
            }
            let section = dataSource[indexPath.section]
            headerView.configure(with: section.title)
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}
// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {

}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.isEmpty {
            valuesForTrackerMaker.trackerName = nil
        } else {
            valuesForTrackerMaker.trackerName = updatedText
        }
        return true
    }
}

// MARK: - Delete from here

enum Configuration: Int {
    case oneRow
    case twoRows
    
    var data: [RowData] {
        switch self {
        case .oneRow:
            return [RowData(title: "Category", subtitle: "")]
        case .twoRows:
            return [
                RowData(title: "Category", subtitle: ""),
                RowData(title: "Schedule", subtitle: "")
            ]
        }
    }
}

struct RowData {
    let title: String
    let subtitle: String
    
    func withSubtitle(_ subtitle: String) -> RowData {
        return RowData(title: title, subtitle: subtitle)
    }
}

enum CollectionViewDataSource {
    case firstSection(items: [String])
    case secondSection(items: [String])
    
    var title: String {
        switch self {
        case .firstSection:
            return "Emojis"
        case .secondSection:
            return "Цвет"
        }
    }
}

extension CollectionViewDataSource: CaseIterable {
    static var allCases: [CollectionViewDataSource] {
        return [
            .firstSection(items: []),
            .secondSection(items: [])
        ]
    }
}
