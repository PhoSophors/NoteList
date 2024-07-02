import UIKit
import SnapKit

class SettingViewController: UIViewController {

    var username: String?
    
    // UI elements
    private let personIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        view.backgroundColor = .systemGray6
        
        view.addSubview(personIconImageView)
        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)
        
        setupUI()
        
        // Check if user is logged in and update usernameLabel
        updateUsernameLabel()
    }

    // MARK: - Private Functions
    
    // Function to setup UI elements and their constraints
    private func setupUI() {
        // Setup constraints using SnapKit
        personIconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(personIconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view).offset(20)
            make.trailing.lessThanOrEqualTo(view).offset(-20)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(40)
        }
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            // Clear login state and Core Data
            LoginHelper.clearLoginState()
            DataManager.shared.clearCoreData()
            
            // Dismiss current view controller
            self.dismiss(animated: true, completion: nil)
            
            // Present the login screen again
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showLoginScreen()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }


    // Function to update usernameLabel with the current logged-in username
    private func updateUsernameLabel() {
        LoginHelper.checkLoginStatus { isLoggedIn, username in
            if isLoggedIn, let username = username {
                DispatchQueue.main.async {
                    self.usernameLabel.text = "Logged in as: \(username)"
                }
            }
        }
    }
}

