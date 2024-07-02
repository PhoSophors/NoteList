import UIKit
import SnapKit
import CoreData

class FolderDetailViewController: UIViewController {

    var folderName: String?
    private let dataManager = DataManager.shared
    private var notes: [Note] = []
    private var filteredNotes: [Note] = []
    private var isSearching: Bool = false

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: NoteCollectionViewCell.identifier)
        return collectionView
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search by note title"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupCollectionView()
        fetchNotes()
        setupRefreshControl()
    }

    private func setupSearchBar() {
        let searchContainer = UIView()
        view.addSubview(searchContainer)

        searchContainer.addSubview(searchBar)
        
        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.addTarget(self, action: #selector(createNote), for: .touchUpInside)
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
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNotes), for: .valueChanged)
    }

    @objc private func refreshNotes() {
        fetchNotes()
        refreshControl.endRefreshing()
        
    }

    // Fetch notes from data manager
    private func fetchNotes() {
        guard let folderName = folderName else {
            return
        }

        guard let folder = dataManager.fetchFolderByName(name: folderName) else {
            return
        }

        notes = dataManager.fetchNotes(for: folder)
        collectionView.reloadData()
    }

    @objc private func createNote() {
        guard let folderName = folderName else {
            showErrorMessage("Folder name is missing.")
            return
        }

        guard let folder = dataManager.fetchFolderByName(name: folderName) else {
            showErrorMessage("Failed to find folder in CoreData.")
            return
        }

        let createNoteVC = CreateNoteViewController()
        createNoteVC.selectedFolder = folder
        createNoteVC.noteCreatedCallback = { [weak self] in
            self?.fetchNotes()
        }
        navigationController?.pushViewController(createNoteVC, animated: true)
    }

    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension FolderDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredNotes.count : notes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.identifier, for: indexPath) as? NoteCollectionViewCell else {
            fatalError("Failed to dequeue NoteCollectionViewCell")
        }

        let note = isSearching ? filteredNotes[indexPath.item] : notes[indexPath.item]
        cell.configure(with: note)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedNote = isSearching ? filteredNotes[indexPath.item] : notes[indexPath.item]
        let noteVC = NoteViewController()
        noteVC.selectedNote = selectedNote
        navigationController?.pushViewController(noteVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.editNote(at: indexPath)
        }

        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.deleteNote(at: indexPath)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [editAction, deleteAction])
        }
    }

    private func editNote(at indexPath: IndexPath) {
        let selectedNote = isSearching ? filteredNotes[indexPath.item] : notes[indexPath.item]
        let noteVC = NoteViewController()
        noteVC.selectedNote = selectedNote
        navigationController?.pushViewController(noteVC, animated: true)
       
    }

    private func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = isSearching ? filteredNotes[indexPath.item] : notes[indexPath.item]
        // Delete note logic
        // Remove from data source and update collection view
        collectionView.performBatchUpdates {
            if isSearching {
                filteredNotes.remove(at: indexPath.item)
            } else {
                notes.remove(at: indexPath.item)
            }
            collectionView.deleteItems(at: [indexPath])
        } completion: { _ in
            self.dataManager.deleteNote(note: noteToDelete)
        }
    }
}

// MARK: - Search folder
extension FolderDetailViewController: UISearchBarDelegate {

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

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredNotes = notes.filter { note in
                return note.noteTitle?.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        collectionView.reloadData()
    }
}
