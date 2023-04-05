import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func didCreateTracker(_ category: TrackerCategory)
}

final class TrackerCreationViewController: UIViewController {
    // MARK: - Public
    weak var delegate: TrackerCreationViewControllerDelegate?
    
    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.myRed.cgColor
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.myRed, for: .normal)
        return button
    }()
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .myCreateButtonColor
        return button
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Private @objc methods
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        trackerMaker.createTrackerWith(
            name: trackerName,
            indexPathEmoji: selectedEmojiIndexPath,
            indexPathColor: selectedColorsIndexPath,
            weekDays: trackerSchedule,
            sections: sections
        )
        dismiss(animated: false)
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Model
    private var trackerMaker = TrackerMaker()
    private let sections = CreateTrackerCollectionViewSectionsData().sections
    private var trackerName = ""
    private var trackerSchedule: [WeekDay] = []
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorsIndexPath: IndexPath?
}

// MARK: - Private methods
private extension TrackerCreationViewController {
    func initialise() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.backgroundColor = .myWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            TrackerNameCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerNameCollectionViewCell.identifier)
        
        collectionView.register(
            TrackersCategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCategoryCollectionViewCell.identifier)
        
        collectionView.register(
            TrackerScheduleCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerScheduleCollectionViewCell.identifier)
        
        collectionView.register(
            TrackerEmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerEmojiCollectionViewCell.identifier)
        
        collectionView.register(
            TrackerColorCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerColorCollectionViewCell.identifier)
        
        collectionView.register(
            CollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionReusableView.identifier)
                
        collectionView.collectionViewLayout = createLayout()
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        view.addSubview(nameOfScreenLabel)
        view.addSubview(collectionView)
        view.addSubview(stackView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 27),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            collectionView.topAnchor.constraint(
                equalTo: nameOfScreenLabel.bottomAnchor,
                constant: 27),
            collectionView.bottomAnchor.constraint(
                equalTo: stackView.topAnchor,
                constant: -16),
            
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            stackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - Layout
private extension TrackerCreationViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            let section = self.sections[sectionIndex]
            switch section {
            case .trackerName:
                return self.createSaleSection()
            case .trackersCategory:
                return self.createCategorySection()
            case .trackerSchedule:
                return self.createCategorySection2()
            case .trackerEmoji:
                return self.createEmojiSection()
            case .trackerColor:
                return self.createColorsSection()
            }
        }
    }
    
    func createLayoutSection(
        group: NSCollectionLayoutGroup,
        behaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior,
        interGroupSpacing: CGFloat,
        supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem],
        contentInsets: NSDirectionalEdgeInsets
    ) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = behaviour
        section.interGroupSpacing = interGroupSpacing
        section.boundarySupplementaryItems = supplementaryItems
        section.contentInsets = contentInsets
        return section
    }
    
    func createSaleSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(75)
            ),
            subitems: [item]
        )
    
        return createLayoutSection(
            group: group,
            behaviour: .none,
            interGroupSpacing: .zero,
            supplementaryItems: [],
            contentInsets: .zero
        )
    }
    
    func createCategorySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(75)
            ),
            subitems: [item]
        )
    
        return createLayoutSection(
            group: group,
            behaviour: .none,
            interGroupSpacing: .zero,
            supplementaryItems: [supplementaryHeaderItemBetweenButtons()],
            contentInsets: .zero
        )
    }
    
    func createCategorySection2() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(75)
            ),
            subitems: [item]
        )
    
        return createLayoutSection(
            group: group,
            behaviour: .none,
            interGroupSpacing: .zero,
            supplementaryItems: [],
            contentInsets: .zero
        )
    }
    
    func createEmojiSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/6),
                heightDimension: .fractionalHeight(1)
            )
        )
    
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/6)
            ),
            subitem: item,
            count: 6)
        
        return createLayoutSection(
            group: group,
            behaviour: .none,
            interGroupSpacing: .zero,
            supplementaryItems: [supplementaryHeaderItemBetweenEmojiAndButton()],
            contentInsets: .init(top: 24, leading: 8, bottom: 24, trailing: 8)
        )
    }
    
    func createColorsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/6),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/6)
            ),
            subitem: item,
            count: 6)
        
        return createLayoutSection(
            group: group,
            behaviour: .none,
            interGroupSpacing: .zero,
            supplementaryItems: [supplementaryHeaderItem()],
            contentInsets: .init(top: 24, leading: 4, bottom: 24, trailing: 4)
        )
    }
    
    func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(34)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    func supplementaryHeaderItemBetweenEmojiAndButton() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    func supplementaryHeaderItemBetweenButtons() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(24)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerCreationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .trackerName(let sale):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerNameCollectionViewCell.identifier,
                for: indexPath) as? TrackerNameCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.configure(with: sale[indexPath.row])
            return cell
        case .trackersCategory(let categ):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackersCategoryCollectionViewCell.identifier,
                for: indexPath) as? TrackersCategoryCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: categ[indexPath.row])
            return cell
        case .trackerSchedule(let categ):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerScheduleCollectionViewCell.identifier,
                for: indexPath) as? TrackerScheduleCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: categ[indexPath.row])
            return cell
        case .trackerEmoji(let other):
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerEmojiCollectionViewCell.identifier,
                for: indexPath) as? TrackerEmojiCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: other[indexPath.row])
            return cell
        case .trackerColor(let color):
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerColorCollectionViewCell.identifier,
                for: indexPath) as? TrackerColorCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: color[indexPath.row])
            cell.configureDeselection()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionReusableView.identifier,
                for: indexPath) as? CollectionReusableView
            else {
                return UICollectionReusableView()
            }
            header.configure(with: sections[indexPath.section].headerTitle)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case .trackerName, .trackersCategory:
            break
        case .trackerSchedule:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        case .trackerEmoji:
            if let selectedIndexPath = selectedEmojiIndexPath,
                selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? TrackerEmojiCollectionViewCell
                cell?.configureDeselection()
                collectionView.reloadItems(at: [selectedIndexPath])
            }
            
            selectedEmojiIndexPath = indexPath
            let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiCollectionViewCell
            cell?.configureSelection()
        case .trackerColor:
            if let selectedIndexPath = selectedColorsIndexPath,
                selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? TrackerColorCollectionViewCell
                cell?.configureDeselection()
                collectionView.reloadItems(at: [selectedIndexPath])
            }
            
            selectedColorsIndexPath = indexPath
            let cell = collectionView.cellForItem(at: indexPath) as? TrackerColorCollectionViewCell
            cell?.configureSelection()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        switch section {
        case .trackerName, .trackersCategory, .trackerSchedule, .trackerEmoji:
            break
        case .trackerColor:
            if let selectedIndexPath = selectedColorsIndexPath,
                selectedIndexPath != indexPath {
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? TrackerColorCollectionViewCell
                cell?.configureSelection()
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as? TrackerColorCollectionViewCell
                cell?.configureDeselection()
            }
        }
    }
}

extension TrackerCreationViewController: TrackerNameCollectionViewCellDelegate {
    func textChanged(_ text: String) {
        trackerName = text
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate  {
    func weekDaysDidSelected(_ days: [WeekDay]) {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 2)) as? TrackerScheduleCollectionViewCell else { return }
        trackerSchedule = days
        if days.count == 7 {
            cell.configure(with: "Каждый день")
        } else {
            let string = days
                .map { "\($0.dayShorthand)" }
                .joined(separator: ", ")
            cell.configure(with: string)
        }
        collectionView.reloadData()
    }
}
