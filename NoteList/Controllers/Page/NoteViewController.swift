import UIKit
import SnapKit

class NoteViewController: UIViewController {
    
    private var folders: [String] = ["Documents", "Files", "Photo"] // Example folder names
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FolderCollectionViewCell.self, forCellWithReuseIdentifier: "folderCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        
        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.addTarget(self, action: #selector(addFolder), for: .touchUpInside)
        
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60) // Adjust top space as needed
            make.leading.equalToSuperview().offset(10) // Adjust leading space as needed
            make.trailing.equalToSuperview().offset(-10) // Adjust trailing space as needed
            make.bottom.equalToSuperview().offset(-10) // Adjust bottom space as needed
        }
    }
    
    @objc private func addFolder() {
        let alertController = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert)
        alertController.addTextField()
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let folderName = alertController.textFields?.first?.text, !folderName.isEmpty else {
                self.showErrorMessage("Folder name can't be empty")
                return
            }
            self.folders.append(folderName)
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension NoteViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "folderCell", for: indexPath) as! FolderCollectionViewCell
        
        // Configure the cell with folder data
        let folderName = folders[indexPath.item]
        cell.nameLabel.text = folderName
        
        // Add long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 4 // Four items per row with spacing
        return CGSize(width: width, height: width * 1.2) // Adjust height as needed
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        if let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) {
            let folderName = folders[indexPath.item]
            showFolderActionSheet(for: folderName, at: indexPath)
        }
    }
    
    private func showFolderActionSheet(for folderName: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: folderName, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.editFolder(at: indexPath)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteFolder(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func editFolder(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Folder Name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = self.folders[indexPath.item]
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newFolderName = alertController.textFields?.first?.text, !newFolderName.isEmpty else {
                self.showErrorMessage("Folder name can't be empty")
                return
            }
            self.folders[indexPath.item] = newFolderName
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteFolder(at indexPath: IndexPath) {
        self.folders.remove(at: indexPath.item)
        self.collectionView.reloadData()
    }
}
