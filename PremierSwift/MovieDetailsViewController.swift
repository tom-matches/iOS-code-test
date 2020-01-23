import UIKit

final class MovieDetailsViewController: UIViewController {
    
    let movie: Movie
    var movieDetails: MovieDetails?
    var currentViewController: UIViewController!
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let loadingViewController = LoadingViewController()
        addChild(loadingViewController)
        loadingViewController.view.frame = view.bounds
        loadingViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        currentViewController = loadingViewController
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        navigationItem.leftBarButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(didTapBack(_:)))
        fetchData()
    }
    
    @objc func fetchData() {
        APIManager.shared.execute(MovieDetails.details(for: movie)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movieDetails):
                DispatchQueue.main.async {
                    self.showMovieDetails(movieDetails)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showError()
                }
            }
        }
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func showMovieDetails(_ movieDetails: MovieDetails) {
        let displayViewController = MovieDetailsDisplayViewController(movieDetails: movieDetails)
        addChild(displayViewController)
        displayViewController.view.frame = view.bounds
        displayViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        currentViewController.willMove(toParent: nil)
        transition(
            from: currentViewController,
            to: displayViewController,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: nil
        ) { (_) in
            self.currentViewController.removeFromParent()
            self.currentViewController = displayViewController
            self.currentViewController.didMove(toParent: self)
        }
    }
    
    func showError() {
        let alertController = UIAlertController(title: "", message: LocalizedString(key: "moviedetails.load.error.body"), preferredStyle: .alert)
        let alertAction = UIAlertAction(title: LocalizedString(key: "moviedetails.load.error.actionButton"), style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}
