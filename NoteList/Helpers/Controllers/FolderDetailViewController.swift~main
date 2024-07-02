import UIKit
import SnapKit
import CoreData

class FolderDetailViewController: UIViewController {

    var folderName: String?
    private let dataManager = DataManager.shared
    private var notes: [Note] = []

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupCollectionView()
        fetchNotes()
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

    private func setupCollectionView() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func fetchNotes() {
        guard let folderName = folderName else {
            return
        }

        // Fetch the selected folder from CoreData using folderName
        guard let folder = dataManager.fetchFolderByName(name: folderName) else {
            return
        }

        // Fetch notes for the selected folder
        notes = dataManager.fetchNotes(in: folder)
        collectionView.reloadData()
    }

    @objc private func createNote() {
        guard let folderName = folderName else {
            showErrorMessage("Folder name is missing.")
            return
        }

        // Fetch the selected folder from CoreData using folderName
        guard let folder = dataManager.fetchFolderByName(name: folderName) else {
            showErrorMessage("Failed to find folder in CoreData.")
            return
        }

        let createNoteVC = CreateNoteViewController()
        createNoteVC.selectedFolder = folder // Pass the selected folder
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
        return notes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.identifier, for: indexPath) as? NoteCollectionViewCell else {
            fatalError("Failed to dequeue NoteCollectionViewCell")
        }

        let note = notes[indexPath.item]
        cell.configure(with: note)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the cell size as per your requirements
        return CGSize(width: collectionView.bounds.width - 20, height: 100)
    }
}
