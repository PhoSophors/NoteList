
import UIKit
import SnapKit

class LoginViewController: UIViewController {

    // UI elements
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let noteIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "note.text")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
        

    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Get Started"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        textField.textColor = .black
        textField.layer.cornerRadius = 15
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemGray4.cgColor // Use systemGray4 color
        textField.layer.shadowRadius = 5
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        // Create a placeholder view to move the placeholder text when active
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = placeholderView
        textField.leftViewMode = .always

        return textField
    }()

    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        textField.textColor = .black
        textField.layer.cornerRadius = 15
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemGray4.cgColor // Set border color
        textField.layer.shadowRadius = 5
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(50) // Increased padding to accommodate the button
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        // Create a placeholder view to move the placeholder text when active
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = placeholderView
        textField.leftViewMode = .always
        
        // Add eye icon button
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .selected) // Set eye slash icon
        eyeButton.tintColor = .lightGray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10) // Adjust icon position
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        textField.rightView = eyeButton
        textField.rightViewMode = .always

        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Set bold font for the title
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: button.titleLabel?.font.pointSize ?? 17) // Use current size or default
        ]
        let attributedTitle = NSAttributedString(string: "Sign in", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()


    let formBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientBackground()
        
        // Add form background view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(formBackgroundView)
        
        // Add UI elements to the contentView
        contentView.addSubview(noteIconImageView)
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(usernameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(loginButton)
        
        // Setup constraints for UI elements
        setupConstraints()
        
        // Check login status on view load
        LoginHelper.checkLoginStatus { isLoggedIn, username in
            if isLoggedIn, let username = username {
                self.navigateToTabBar(username: username)
            }
        }
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Dismiss keyboard on tap outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        // Remove keyboard observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = view.frame
        rect.size.height -= keyboardSize.height
        if let activeField = [usernameTextField, passwordTextField].first(where: { $0.isFirstResponder }) {
            let point = activeField.convert(activeField.bounds.origin, to: scrollView)
            if !rect.contains(point) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Functions
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.top).offset(-30)
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        noteIconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(200)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(noteIconImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemCyan.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func loginButtonTapped() {
        validateCredentials()
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
  
    @objc private func togglePasswordVisibility(sender: UIButton) {
        sender.isSelected.toggle() // Toggle button state
        
        passwordTextField.isSecureTextEntry.toggle() // Toggle password visibility
    }
   
    private func validateCredentials() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Username and password can't be empty!")
            return
        }

        LoginHelper.validateCredentials(username: username, password: password) { success, errorMessage in
            if success {
                // Save login state and navigate to tab bar
                LoginHelper.saveLoginState(username: username)
                self.navigateToTabBar(username: username)
            } else {
                self.showAlert(message: errorMessage ?? "Login failed.")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToTabBar(username: String) {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }

}

// Extension to add padding to UITextField
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
