//
//  LogInViewController.swift
//  Today
//


import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInButtonClicked(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] (user, error) in
            if error == nil{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainTabController")
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
            else{
                print("error has occured")
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
