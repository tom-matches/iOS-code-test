import UIKit

final class MoviesViewController: UITableViewController {
    
    var movies = [Movie]() {
        didSet {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizedString(key: "movies.title")
        
        tableView.dm_registerClassWithDefaultIdentifier(cellClass: MovieCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        fetchData()
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
