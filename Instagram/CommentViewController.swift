//
//  CommentViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/18.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var commentTextField: UITextField!
    
    // MARK: - Member Variable
    
    var postId = ""
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBAction
    
    // 投稿ボタンがタップされた時に呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // ログインユーザーの表示名を取得
        if let comment = self.commentTextField.text {
            // 入力の有無を判定
            if comment.isEmpty {
                print("DEBUG_PRINT: コメントが空文字です。")
                // 入力がない場合エラー内容を記述したHUDを表示し、メソッドを抜ける
                SVProgressHUD.showError(withStatus: "コメントを入力して下さい")
                return
            }
            // 表示名を取得
            if let name = Auth.auth().currentUser?.displayName{
                // 表示名とコメントをまとめて文字列にする
                let commentCaption = "\(name) : \(comment)"
                // 更新データを作成
                let updateValue = FieldValue.arrayUnion([commentCaption])
                // タップした投稿のドキュメントを取得
                let postRef = Firestore.firestore().collection(Const.postPath).document(self.postId)
                // comments配列に対して更新データの内容を更新
                postRef.updateData(["comments": updateValue])
            }
            // コメント画面を閉じる
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    // キャンセルボタンがタップされた時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // コメント画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
}
