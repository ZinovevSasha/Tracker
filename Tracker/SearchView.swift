import UIKit

protocol SearchViewDelegate: AnyObject {
    func search(for query: String)
    func cancelSearch()
}

final class SearchView: UIView {
    // MARK: - Public
    func setDelegate(delegate: SearchViewDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Private properties
    private weak var delegate: SearchViewDelegate?
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .minimal
        view.placeholder = "Поиск"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private methods
    private func initialise() {
        searchBar.delegate = self
        addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UISearchBarDelegate
extension SearchView: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.cancelSearch()
    }
}

// MARK: - UISearchResultsUpdating
extension SearchView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        delegate?.search(for: query)
    }
}
