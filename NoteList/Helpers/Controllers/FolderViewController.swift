import UIKit
import SnapKit

class FolderViewController: UIViewController {

    private var folders: [Folder] = []
    private var filteredFolders: [Folder] = [] // Array to hold filtered folders
    private let dataManager = DataManager()
    private let refreshControl = UIRefreshControl()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FolderCollectionViewCell.self, forCellWithReuseIdentifier: "folderCell")
        collectionView.refreshControl = refreshControl
        return collectionView
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self // Assigning delegate for search functionality
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        setupSearchBar()
        setupCollectionView()
        fetchFoldersFromCoreData()
        setupRefreshControl()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupSearchBar() {
        let searchContainer = UIView()
        view.addSubview(searchContainer)

        searchContainer.addSubview(searchBar)

        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.addTarget(self, action: #selector(createFolder), for: .touchUpInside)
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

    private func setupCollectionView() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshFolders), for: .valueChanged)
    }

    @objc private func refreshFolders() {
        fetchFoldersFromCoreData()
        refreshControl.endRefreshing()
    }

    private func fetchFoldersFromCoreData() {
        folders = dataManager.fetchFolders()
        filteredFolders = folders // Initialize filteredFolders with all folders initially
        collectionView.reloadData()
    }

    @objc private func createFolder() {
        let alertController = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert)
        alertController.addTextField()

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let folderName = alertController.textFields?.first?.text, !folderName.isEmpty else {
                self.showErrorMessage("Folder name can't be empty")
                return
            }
            if self.isFolderNameExists(folderName) {
                self.showErrorMessage("Folder name already exists")
                return
            }
            self.dataManager.saveFolder(name: folderName)
            self.fetchFoldersFromCoreData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func isFolderNameExists(_ folderName: String) -> Bool {
        return folders.contains { $0.folderName?.lowercased() == folderName.lowercased() }
    }

    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func openFolderDetail(at indexPath: IndexPath) {
        let selectedFolder: Folder
        if isFiltering() {
            selectedFolder = filteredFolders[indexPath.item]
        } else {
            selectedFolder = folders[indexPath.item]
        }

        guard let folderName = selectedFolder.folderName else { return }
        let folderDetailViewController = FolderDetailViewController()
        folderDetailViewController.folderName = folderName
        navigationController?.pushViewController(folderDetailViewController, animated: true)
    }
}

extension FolderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFolders.count
        } else {
            return folders.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "folderCell", for: indexPath) as! FolderCollectionViewCell

        let folder: Folder
        if isFiltering() {
            folder = filteredFolders[indexPath.item]
        } else {
            folder = folders[indexPath.item]
        }

        let folderName = folder.folderName ?? ""
        cell.nameLabel.text = folderName

        // Fetch notes for the folder to get the count
        let noteCount = dataManager.fetchNotes(for: folder).count
        cell.noteCountLabel.text = "Notes: \(noteCount)"

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        cell.addGestureRecognizer(tapRecognizer)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 4
        return CGSize(width: width, height: width * 1.2)
    }

    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? FolderCollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        UIView.transition(with: cell.nameLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let folder: Folder
            if self.isFiltering() {
                folder = self.filteredFolders[indexPath.item]
            } else {
                folder = self.folders[indexPath.item]
            }
            cell.nameLabel.text = folder.folderName ?? ""
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.openFolderDetail(at: indexPath)
            }
        })
    }

    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        if let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) {
            let folder: Folder
            if isFiltering() {
                folder = filteredFolders[indexPath.item]
            } else {
                folder = folders[indexPath.item]
            }
            showFolderActionSheet(for: folder, at: indexPath)
        }
    }

    private func showFolderActionSheet(for folder: Folder, at indexPath: IndexPath) {
        let alert = UIAlertController(title: folder.folderName ?? "", message: nil, preferredStyle: .actionSheet)

        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.editFolder(folder)
        }

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteFolder(folder)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func editFolder(_ folder: Folder) {
        let alertController = UIAlertController(title: "Edit Folder Name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = folder.folderName
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newFolderName = alertController.textFields?.first?.text, !newFolderName.isEmpty else {
                self.showErrorMessage("Folder name can't be empty")
                return
            }
            self.dataManager.updateFolder(folder: folder, newName: newFolderName)
            self.fetchFoldersFromCoreData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func deleteFolder(_ folder: Folder) {
        self.dataManager.deleteFolder(folder: folder)
        self.fetchFoldersFromCoreData()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension FolderViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterContentForSearchText("")
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func isFiltering() -> Bool {
        return !searchBar.text!.isEmpty
    }

    func filterContentForSearchText(_ searchText: String) {
        filteredFolders = folders.filter { (folder: Folder) -> Bool in
            return folder.folderName?.lowercased().contains(searchText.lowercased()) ?? false
        }
        collectionView.reloadData()
    }
}
