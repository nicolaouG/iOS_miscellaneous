//
//  SignInUpTableViewController.swift
//  TestProject
//
//  Created by george on 13/04/2020.
//  Copyright © 2020 george. All rights reserved.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import FacebookLogin
import FontAwesome_swift

class SignInUpTableViewController: UITableViewController {
    enum TableRows: Int {
        case header
        case googleSignIn
        case facebookSignIn
        case appleSignIn
        case emailSignIn
        
        static let count = 5
        
        func estimatedHeightForRow() -> CGFloat {
            switch self {
            case .header:
                return 300
            case .googleSignIn:
                return 44
            case .appleSignIn:
                if #available(iOS 13.0, *) {
                    return 44
                } else {
                    return 0
                }
            case .facebookSignIn:
                return 44
            case .emailSignIn:
                return 44
            }
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
        tableView.refreshControl = nil
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        
        googleSignInSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func googleSignInSetup() {
        GIDSignIn.sharedInstance().clientID = "1034395428326-imutfjm73gpnaob81qv50i1sjqfkjo97.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableRows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableRows(rawValue: indexPath.row) {
        case .appleSignIn:
            if #available(iOS 13.0, *) {
            } else {
                return 0
            }
        default:
            break
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableRows(rawValue: indexPath.row)?.estimatedHeightForRow() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableRows(rawValue: indexPath.row) {
        case .header:
            var cell = tableView.dequeueReusableCell(withIdentifier: "headerCellId")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "headerCellId")
            }
            if !(cell?.subviews.contains(where: { $0.tag == 123 }) ?? true) {
                let headerImageView = UIImageView(image: #imageLiteral(resourceName: "aot"))
                headerImageView.contentMode = .scaleAspectFit
                cell?.addSubview(headerImageView)
                headerImageView.snp.makeConstraints({ make in
                    make.top.bottom.equalToSuperview().inset(20)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.7)
                    make.height.equalTo(headerImageView.snp.width)
                })
            }
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()

        case .googleSignIn:
            var cell = tableView.dequeueReusableCell(withIdentifier: "googleCellId") as? GoogleSignInTableViewCell
            if cell == nil {
                cell = GoogleSignInTableViewCell(style: .default, reuseIdentifier: "googleCellId")
            }
            cell?.googleButton.addTarget(self, action: #selector(googleButtonClicked), for: .touchUpInside)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()

        case .facebookSignIn:
            var cell = tableView.dequeueReusableCell(withIdentifier: "facebookCellId") as? FacebookSignInTableViewCell
            if cell == nil {
                cell = FacebookSignInTableViewCell(style: .default, reuseIdentifier: "facebookCellId")
            }
            cell?.facebookButton.addTarget(self, action: #selector(facebookButtonClicked), for: .touchUpInside)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
            
        case .appleSignIn:
            if #available(iOS 13.0, *) {
                var cell = tableView.dequeueReusableCell(withIdentifier: "appleCellId") as? AppleSignInTableViewCell
                if cell == nil {
                    cell = AppleSignInTableViewCell(style: .default, reuseIdentifier: "appleCellId")
                }
                cell?.appleButton.addTarget(self, action: #selector(appleButtonClicked), for: .touchUpInside)
                cell?.selectionStyle = .none
                return cell ?? UITableViewCell()
            } else {
                return UITableViewCell()
            }

        case .emailSignIn:
            var cell = tableView.dequeueReusableCell(withIdentifier: "emailCellId") as? EmailSignInTableViewCell
            if cell == nil {
                cell = EmailSignInTableViewCell(style: .default, reuseIdentifier: "emailCellId")
            }
            cell?.emailButton.addTarget(self, action: #selector(emailButtonClicked), for: .touchUpInside)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
            
        default:
            return UITableViewCell()
        }
    }
    
    
    /// for custom google button
    @objc func googleButtonClicked() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    /// for custom facebook button
    @objc func facebookButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email, .userBirthday, .userGender], viewController: self) { (result) in
            self.loginManagerDidComplete(result)
        }
    }
    
    @objc func emailButtonClicked() {
    }
}




// MARK: - Facebook login

extension SignInUpTableViewController: LoginButtonDelegate {
    /// for custom facebook button
    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .cancelled:
            print("* * facebook login cancelled")
        case .failed(let error):
            print("* * facebook Login failed with error \(error.localizedDescription)")
        case .success(let grantedPermissions, _, _):
            print("* * Facebook login succeeded with granted permissions: \(grantedPermissions)")
        }
    }
    
    func isFacebookLogedIn() -> Bool {
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            // User is logged in, use 'accessToken' here.
            return true
        }
        return false
    }
    
    func logoutFromFacebook() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }


    /** default facebook button */
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let err = error {
            print("* * facebook error: \(err.localizedDescription)")
        } else {
            print("* * * facebook logged in or cancel")
        }
    }
    /** default facebook button */
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("* * * facebook logged out")
    }
}


// MARK: - GIDSignInDelegate

extension SignInUpTableViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("* * The user has not signed in before or they have since signed out.")
          } else {
            print("* * \(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        print("* * \(userId) - \(idToken) - \(fullName) - \(givenName) - \(familyName) - \(email)")
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance().signOut()
    }
}



// MARK: - ASAuthorizationControllerDelegate

@available(iOS 13.0, *)
extension SignInUpTableViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @objc func appleButtonClicked() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
//        performExistingAccountSetupFlows()
    }
    
    /// use for auto-login, in init or appDelegate
    func getAppleCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                /// show homeVC
                break /// The Apple ID credential is valid.
            case .revoked, .notFound:
                /// show loginVC
                break /// The Apple ID credential is either revoked or was not found.
            default:
                break
            }
        }
    }
    
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let requestAppleID = appleIDProvider.createRequest()
        requestAppleID.requestedScopes = [.fullName, .email]
        
        let passwordProvider = ASAuthorizationPasswordProvider()
        let requestPasswords = passwordProvider.createRequest()

        // Prepare requests for both Apple ID and password providers.
        let requests = [requestAppleID, requestPasswords]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("\(userIdentifier) - \(fullName) - \(email)")
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
                    
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("\(username) - \(password)")
                        
        default:
            break
        }
        
        // Proceed with successfull sign in.
        // self.showHomeViewController()
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}









// MARK: - Google cell

class GoogleSignInTableViewCell: UITableViewCell {
//    lazy var googleButton: GIDSignInButton = {
//        let b = GIDSignInButton()
//        b.style = .wide
//        b.colorScheme = GIDSignInButtonColorScheme.light
//        return b
//    }()
    
    lazy var googleButton: UIButton = {
        return getGoogleButton()
    }()

        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
    }
    
    func getGoogleButton() -> AnimatingButton {
        let b = AnimatingButton(title: "Sign in with Google", image: #imageLiteral(resourceName: "google_icon"), spacing: 14, leftInset: 18)
        return b
    }
        
    func setupView() {
        addSubview(googleButton)
        googleButton.snp.makeConstraints({ make in
            make.top.bottom.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44)
        })
    }
}

// MARK: - Facebook cell

class FacebookSignInTableViewCell: UITableViewCell {
//    lazy var facebookButton: FBLoginButton = {
//        let b = FBLoginButton(frame: .zero, permissions: [.email, .userBirthday, .userGender])
//        return b
//    }()

    lazy var facebookButton: UIButton = {
        return getFacebookButton()
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFacebookButton() -> AnimatingButton {
        let b = AnimatingButton(title: "Sign in with Facebook", image: #imageLiteral(resourceName: "facebook_icon"), spacing: 14, leftInset: 18)
        return b
    }

    
    func setupView() {
        addSubview(facebookButton)
        facebookButton.snp.makeConstraints({ make in
            make.top.bottom.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44)
        })
    }
}


// MARK: - Apple cell

@available(iOS 13.0, *)
class AppleSignInTableViewCell: UITableViewCell {
//    lazy var appleButton: ASAuthorizationAppleIDButton = {
//        let b: ASAuthorizationAppleIDButton
//        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
//            b = ASAuthorizationAppleIDButton(type: ASAuthorizationAppleIDButton.ButtonType.signIn, style: ASAuthorizationAppleIDButton.Style.white)
//        } else {
//            b = ASAuthorizationAppleIDButton(type: ASAuthorizationAppleIDButton.ButtonType.signIn, style: ASAuthorizationAppleIDButton.Style.black)
//        }
//        return b
//    }()

    lazy var appleButton: AnimatingButton = {
        let b = AnimatingButton(title: "Sign in with Apple", image: #imageLiteral(resourceName: "apple_icon_2"), spacing: 4.4, imageSize: round(2.33 * 19)) /// apple guidelines
        return b
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupView() {
        addSubview(appleButton)
        appleButton.snp.makeConstraints({ make in
            make.top.bottom.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44) /// apple guidelines
        })
    }
}


// MARK: - Email cell

class EmailSignInTableViewCell: UITableViewCell {
    lazy var orLabel: UILabel = {
        let l = UILabel()
        l.text = "-or-"
        l.font = .systemFont(ofSize: 12, weight: UIFont.Weight.thin)
        return l
    }()
    
    lazy var emailButton: AnimatingButton = {
        return getEmailButton()
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getEmailButton() -> AnimatingButton {
        let image = UIImage.fontAwesomeIcon(name: .user, style: .regular, textColor: Singleton.shared.textColor, size: CGSize(width: 22, height: 22))
        let b = AnimatingButton(title: "Sign in with Email", image: image, spacing: 14, leftInset: 18)
        b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        return b
    }

    func setupView() {
        addSubview(orLabel)
        addSubview(emailButton)
        
        orLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        })
        emailButton.snp.makeConstraints({ make in
            make.bottom.equalToSuperview().inset(16)
            make.top.equalTo(orLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44)
        })
    }
}



// MARK: - AnimatingButton

class AnimatingButton: UIButton {
    var buttonTitle: String
    var buttonImage: UIImage?
    var spacing: CGFloat
    var leftInset: Int
    var imageSize: Double
    static let sideInsets: Int = 8
    
    
    init(title: String, image: UIImage? = nil, spacing: CGFloat = 0, leftInset: Int = sideInsets, imageSize: Double = 22) {
        self.buttonTitle = title
        self.buttonImage = image
        self.spacing = spacing
        self.leftInset = leftInset
        self.imageSize = imageSize
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(buttonPressed), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(buttonPressCancel), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
        
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = Singleton.shared.textColor.cgColor
        }
    }
    
    func setupButton() {
        layer.cornerRadius = 6
        layer.borderColor = Singleton.shared.textColor.cgColor
        layer.borderWidth = 0.5
        backgroundColor = Singleton.shared.backgroundColor
        
        if let buttonImage = buttonImage {
            let iv = UIImageView(image: buttonImage)
            iv.contentMode = .scaleAspectFit
            
            let l = UILabel()
            l.textAlignment = .center
            l.text = buttonTitle
            l.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            l.textColor = Singleton.shared.textColor
            l.backgroundColor = .clear
            
            let stack = UIStackView(arrangedSubviews: [iv, l])
            stack.alignment = .center
            stack.distribution = .fill
            stack.axis = .horizontal
            stack.spacing = spacing
            stack.isUserInteractionEnabled = false
            
            addSubview(stack)
            iv.snp.makeConstraints({ $0.width.height.equalTo(imageSize) })
            stack.snp.makeConstraints({
                $0.top.bottom.equalToSuperview().inset(5)
                $0.right.equalToSuperview().inset(AnimatingButton.sideInsets)
                $0.left.equalToSuperview().inset(leftInset)
            })
        }
        else {
            setTitle(buttonTitle, for: .normal)
            setTitleColor(Singleton.shared.textColor, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.semibold)
        }
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.layoutIfNeeded()
        }
    }
    
    @objc func buttonPressCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = .identity
            self.layoutIfNeeded()
        }
    }
}
