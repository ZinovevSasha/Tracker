import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, textDidChange searchText: String)
}

final class SearchView: UIView {
    // MARK: - Public
    weak var delegate: SearchViewDelegate?
    
    // MARK: - Private properties
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchView(self, textDidChange: searchText)
    }
}
