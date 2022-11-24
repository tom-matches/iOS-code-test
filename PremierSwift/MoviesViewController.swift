import UIKit

final class MoviesViewController: UITableViewController, UISearchResultsUpdating {
    
    var movies = [Movie]() {
        didSet {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    let searchViewController = UISearchController(searchResultsController: SearchResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizedString(key: "movies.title")
        
        tableView.dm_registerClassWithDefaultIdentifier(cellClass: MovieCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        configureSearchBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        searchViewController.searchResultsUpdater = self
        
        navigationItem.searchController = searchViewController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let request = Request<Page<Movie>>(method: Method.get, path: "/search/movie", pars: ["query": searchController.searchBar.text!])
        APIManager.shared.execute(request, completion: { result in
            if case .success(let page) = result {
                DispatchQueue.main.async {
                    (searchController.searchResultsController as! SearchResultsViewController).movies = page.results
                }
            }
        })
    }
    
    @objc func textSizeChanged() {
        tableView.reloadData()
    }
    
    @objc func fetchData() {
        APIManager.shared.execute(Movie.topRated) { [weak self] result in
            switch result {
            case .success(let page):
                DispatchQueue.main.async {
                    self?.refreshControl?.endRefreshing()
                    self?.movies = page.results
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.refreshControl?.endRefreshing()
                    self?.showError()
                }
            }
        }
    }
    
    func showError() {
        let alertController = UIAlertController(title: "", message: LocalizedString(key: "movies.load.error.body"), preferredStyle: .alert)
        let alertAction = UIAlertAction(title: LocalizedString(key: "movies.load.error.actionButton"), style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func configureSearchBar() {
    
        let searchTextField = searchViewController.searchBar.searchTextField
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.font: UIFont.Body.medium, .foregroundColor: UIColor.Text.charcoal])
        searchTextField.font = UIFont(name: "Poppins-Regular", size: 16)
        searchTextField.backgroundColor = UIColor(red: 248 / 255.0, green: 248 / 255.0, blue: 248 / 255.0, alpha: 1)
        searchTextField.borderStyle = .none
        searchTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        searchTextField.layer.borderWidth = 1.0
        searchTextField.layer.cornerRadius = 8
        
        searchViewController.searchBar.setLeftImage(UIImage(named: "Search"))
        searchViewController.searchBar.barTintColor = .clear
        searchViewController.searchBar.setImage(UIImage(named: "Filter"), for: .bookmark, state: .normal)
        searchViewController.searchBar.showsBookmarkButton = true
        searchViewController.searchBar.delegate = self
        searchViewController.searchBar.tintColor = UIColor.Brand.popsicle40
    }
}

// MARK: - UITableViewDataSource
extension MoviesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieCell = tableView.dm_dequeueReusableCellWithDefaultIdentifier()
        
        let movie = movies[indexPath.row]
        cell.configure(movie)
        
        return cell
    }
    
}

// MARK: - UITableViewControllerDelegate
extension MoviesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let viewController = MovieDetailsViewController(movie: movie)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
