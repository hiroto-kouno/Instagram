//
//  LoginViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    // MARK: - IBAction
    
    // ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        // 各テキストプロパティをアンラップ
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {
            
            // アドレスまたはパスワード名の入力の有無を判定
            if address.isEmpty || password.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                // いずれかの入力がない場合、内容を記述したHUDを表示し、メソッドを抜ける
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードからサインインを実行
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                // エラーの有無を判定
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                
                // ログイン画面を閉じ、タブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // アカウント作成ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        // 各テキストプロパティをアンラップ
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = self.displayNameTextField.text {
            
            // アドレス、パスワード名、表示名の入力の有無を判定
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                // いずれかの入力がない場合、エラー内容を記述したHUDを表示し、メソッドを抜ける
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードからユーザー作成を実行
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                // エラーの有無を判定
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // ログインユーザーを取得
                if let user = Auth.auth().currentUser {
                    // プロフィールを更新するために使用するリクエスト
                    let changeRequest = user.createProfileChangeRequest()
                    // 表示名変更を設定
                    changeRequest.displayName = displayName
                    // プロフィールの更新を実行
                    changeRequest.commitChanges { error in
                        // エラーの有無を判定
                        if let error = error {
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        // HUDを消す
                        SVProgressHUD.dismiss()
                        
                        // ログイン画面を閉じ、タブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
