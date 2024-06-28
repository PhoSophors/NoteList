import UIKit

class FolderDetailViewController: UIViewController {

    var folderName: String?
    private let dataManager = DataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()

        // Example: Display folder name in a label
        let label = UILabel()
        label.text = folderName ?? "No folder name"
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal

        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.addTarget(self, action: #selector(createNote), for: .touchUpInside)

        let searchContainer = UIView()
        view.addSubview(searchContainer)

        searchContainer.addSubview(searchBar)
        searchContainer.addSubview(plusButton)

        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        searchBar.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalTo(plusButton.snp.leading)
        }

        plusButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }
    }

    @objc private func createNote() {
        let createNoteVC = CreateNoteViewController()
        navigationController?.pushViewController(createNoteVC, animated: true)
    }

    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
