import UIKit

protocol CreateNoteDelegate: AnyObject {
    func didCreateNoteWithTitle(_ title: String, descriptions: String, inFolder folder: Folder)
}

class CreateNoteViewController: UIViewController {
    
    var selectedFolder: Folder?
    weak var delegate: CreateNoteDelegate?
    
    private let dataManager = DataManager()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter note title"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter note description"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(saveButton)
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func saveNote() {
        guard let folder = selectedFolder else {
            showErrorMessage("No folder selected")
            return
        }
        
        guard let title = titleTextField.text, !title.isEmpty else {
            showErrorMessage("Please enter a valid title")
            return
        }
        
        guard let description = descriptionTextField.text, !description.isEmpty else {
            showErrorMessage("Please enter a valid description")
            return
        }
        
        dataManager.saveNote(title: title, descriptions: description, folder: folder)
        delegate?.didCreateNoteWithTitle(title, descriptions: description, inFolder: folder)
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
