//
//  SettingViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ログインユーザーを取得
        if let user = Auth.auth().currentUser {
            // ユーザーの表示名をテキストプロパティに表示
            self.displayNameTextField.text = user.displayName
        }
    }
    
    // MARK: - IBAction
    
    // 表示名変更ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleChangeButton(_ sender: Any) {
        // テキストプロパティをアンラップ
        if let displayName = self.displayNameTextField.text {
            
            // 表示名の入力有無を判定
            if displayName.isEmpty {
                // 入力がない場合、内容を記述したHUDを表示し、メソッドを抜ける
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }
            
            // ログインユーザーを取得
            if let user = Auth.auth().currentUser {
                // プロフィール変更のリクエストを作成
                let changeRequest = user.createProfileChangeRequest()
                // 表示名変更に入力した表示名を設定
                changeRequest.displayName = displayName
                // リクエストを実行する
                changeRequest.commitChanges { error in
                    // エラーの有無を判定
                    if let error = error {
                        // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    // IDと表示名を引数に投稿者名を変更するメソッドを呼び出す
                    self.changedDisplayName(user.uid, displayName)
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
                
            }
        }
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // ログアウトボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLogoutButton(_ sender: Any) {
        // サインアウトを実行
        do {
            try Auth.auth().signOut()
        } catch {
            // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました。")
            print("DEBUG_PRINT: ログアウトに失敗")
            return
        }
        
        // ログイン画面を表示
        if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
            self.present(loginViewController, animated: true, completion: nil)
        }
        
        // 親のTabBarControlleの選択をホーム画面(0)にする
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Private Method
    
    // 投稿者名を変更するメソッド
    func changedDisplayName (_ uid: String, _ displayName: String) {
        // ログインユーザとuidが一致する投稿のクエリを取得
        let postsRef = Firestore.firestore().collection(Const.postPath).whereField("uid", isEqualTo: uid)
        // ドキュメントを取得
        postsRef.getDocuments() { (querySnapshot, error) in
            // エラーの有無を判定
            if let error = error {
                // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                print("DEBUG_PRINT: " + error.localizedDescription)
                return
            } else {
                if let querySnapshot = querySnapshot {
                    // ドキュメントごとに処理を実行
                    for document in querySnapshot.documents {
                        // ドキュメントIDから投稿を取得
                        let postRef = Firestore.firestore().collection(Const.postPath).document(document.documentID)
                        // 投稿の表示名を変更後のものに更新
                        postRef.updateData(["name": displayName])
                    }
                }
            }
        }
    }
    
}
