import UIKit

class CreateTrackerViewController: UIViewController {
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
    
    @objc private func createButtonTapped() {}
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Model
    private let sections = TrackerCreationData().sections
    private var selectedColorsIndexPath: IndexPath?
    private var selectedEmojiIndexPath: IndexPath?
}

// MARK: - Private methods
private extension CreateTrackerViewController {
    func initialise() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.backgroundColor = .myWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
        collectionView.register(
            ScheduleCollectionViewCell.self,
            forCellWithReuseIdentifier: ScheduleCollectionViewCell.identifier)
        
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        
        collectionView.register(
            ColorsCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        
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
            
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - Layout
private extension CreateTrackerViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            let section = self.sections[sectionIndex]
            switch section {
            case .sales:
                return self.createSaleSection()
            case .category:
                return self.createCategorySection()
            case .category2:
                return self.createCategorySection2()
            case .emoji:
                return self.createEmojiSection()
            case .colors:
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

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .sales(let sale):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchCollectionViewCell.identifier,
                for: indexPath) as? SearchCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: sale[indexPath.row])
            return cell
        case .category(let categ):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCollectionViewCell.identifier,
                for: indexPath) as? CategoryCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: categ[indexPath.row])
            return cell
        case .category2(let categ):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ScheduleCollectionViewCell.identifier,
                for: indexPath) as? ScheduleCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: categ[indexPath.row])
            return cell
        case .emoji(let other):
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath) as? EmojiCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: other[indexPath.row])
            return cell
        case .colors(let color):
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorsCollectionViewCell.identifier,
                for: indexPath) as? ColorsCollectionViewCell
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
            header.configure(with: sections[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}


extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let section = self.sections[indexPath.section]
        switch section {
        case .sales:
            break
        case .category:
            break
        case .category2:
            break
        case .emoji:
            if let selectedIndexPath = selectedEmojiIndexPath,
                selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? EmojiCollectionViewCell
                cell?.configureDeselection()
                collectionView.reloadItems(at: [selectedIndexPath])
            }
            
            selectedEmojiIndexPath = indexPath
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.configureSelection()
        case .colors:
            if let selectedIndexPath = selectedColorsIndexPath,
                selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? ColorsCollectionViewCell
                cell?.configureDeselection()
                collectionView.reloadItems(at: [selectedIndexPath])
            }
            
            selectedColorsIndexPath = indexPath
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell
            cell?.configureSelection()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        switch section {
        case .sales, .category, .category2, .emoji:
            break
        case .colors:
            if let selectedIndexPath = selectedColorsIndexPath,
                selectedIndexPath != indexPath {
                let cell = collectionView.cellForItem(at: selectedIndexPath) as? ColorsCollectionViewCell
                cell?.configureSelection()
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell
                cell?.configureDeselection()
            }
        }
    }
}
