import UIKit

class SearchResultsViewController: UITableViewController {
    
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
        tableView.allowsSelection = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc func textSizeChanged() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SearchResultsViewController {
    
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
