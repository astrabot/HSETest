//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

final class HomeViewController: UITableViewController {
    private var cancellables: Set<AnyCancellable> = []
    var viewModel: HomeViewModelType? {
        didSet { bind(to: viewModel) }
    }

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .systemOrange
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HomeCell.self)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startInitialFetching()
    }

    private func bind(to viewModel: HomeViewModelType?) {
        cancellables.removeAll()
        guard let viewModel = viewModel else { return }

        viewModel.titlePublisher.receive(on: DispatchQueue.main).assign(to: \.title, on: self).store(in: &cancellables)
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
        alertController.addAction(UIAlertAction(title: Strings.errorAlertOK, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categories.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(for: indexPath) as HomeCell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let homeCell = cell as? HomeCell else { return }
        configure(homeCell, forItemAt: indexPath)
    }

    private func configure(_ cell: HomeCell, forItemAt indexPath: IndexPath) {
        guard let category = viewModel?.categories[indexPath.row] else { return }
        cell.textLabel?.text = category.displayName
        if category.children.isEmpty {
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
        } else {
            cell.detailTextLabel?.text = "Subcategories : \(category.children.count)"
            cell.accessoryType = .disclosureIndicator
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let category = viewModel?.categories[indexPath.row] else { return }
        viewModel?.selectCategory(category)
    }
}
