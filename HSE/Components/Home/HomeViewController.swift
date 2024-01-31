//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

final class HomeViewController: UITableViewController {
    private var cancellables: Set<AnyCancellable> = []
    var viewModel: HomeViewModelType {
        didSet {
            if isViewLoaded {
                bind(to: viewModel)
            }
        }
    }

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .systemOrange
        spinner.hidesWhenStopped = true
        return spinner
    }()

    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HomeCell.self)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        bind(to: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startInitialFetching()
    }

    private func bind(to viewModel: HomeViewModelType?) {
        cancellables.removeAll()
        guard let viewModel = viewModel else { return }

        viewModel.titlePublisher.receive(on: DispatchQueue.main).sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        viewModel.statePublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .initial: break
            case .loading:
                self.spinner.startAnimating()
            case .loaded:
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            case .fail(let error):
                self.spinner.stopAnimating()
                self.showError(error)
            }
        }.store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        let alertController = UIAlertController(title: Strings.errorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Strings.errorAlertOKAction, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(for: indexPath) as HomeCell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let homeCell = cell as? HomeCell else { return }
        guard let cellViewModel = viewModel.cellViewModel(at: indexPath) else { return }
        homeCell.configure(with: cellViewModel)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath)
    }
}
