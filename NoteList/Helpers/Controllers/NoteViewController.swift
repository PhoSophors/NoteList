import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    var selectedNote: Note?
    var folder: Folder? // Assuming you pass the folder object to display the note

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.backgroundColor = .systemGray6
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true // Allow editing
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemGray6
        textView.textColor = .black
        textView.textAlignment = .left
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()

    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNoteChanges))
        return button
    }()

    private var keyboardHeight: CGFloat = 0.0
    var noteUpdatedCallback: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Edit Note"

        setupUI()
        setupKeyboardObservers()
        displayNoteDetails()

        navigationItem.rightBarButtonItem = saveButton
    }

    private func setupUI() {
        // Add titleTextField
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Add descriptionTextView
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }

        // Constraint to dynamically adjust height based on content
        descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }

    private func displayNoteDetails() {
        if let note = selectedNote {
            titleTextField.text = note.noteTitle
            descriptionTextView.text = note.noteDescription
        }
    }

    @objc private func saveNoteChanges() {
        guard let updatedTitle = titleTextField.text, !updatedTitle.isEmpty,
              let updatedDescription = descriptionTextView.text, !updatedDescription.isEmpty,
              let note = selectedNote else {
            showErrorMessage("Title or description cannot be empty.")
            return
        }

        DataManager.shared.updateNote(note: note, withTitle: updatedTitle, description: updatedDescription)

        // Update the selected note object with new data
        selectedNote?.noteTitle = updatedTitle
        selectedNote?.noteDescription = updatedDescription

        // Invoke the callback to notify that a note has been updated
        noteUpdatedCallback?()

        // Show success alert
        let alertController = UIAlertController(title: "Success", message: "Note updated successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            // Navigate back to FolderDetailViewController
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardSize = keyboardFrame.size
        keyboardHeight = keyboardSize.height

        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -self.keyboardHeight
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
