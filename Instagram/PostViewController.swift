//
//  PostViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {

    // MARK: - Member Variable
    
    var image: UIImage!
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加工画面から受け取った画像をimageViewに渡す
        self.imageView.image = self.image
    }
    
    // MARK: - IBAction
    
    // 投稿ボタンをタップした時に呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // 画像をJPEG形式に変換する
        guard let imageData = self.image.jpegData(compressionQuality: 0.75) else {
            // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
            SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
            // 親のViewController(TabbarController)を取得し、子のViewController(画像選択から投稿画面まで)を全て閉じる
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            return
        }
        // 投稿の保存場所を取得
        let postRef = Firestore.firestore().collection(Const.postPath).document()
        // 画像をどこに、どのような名前(投稿のdocumentId)で保存するかというデータを取得
        let imageRef = Storage.storage().reference().child(Const.imagePath).child(postRef.documentID + ".jpg")
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        // メタデータ(付加的情報)のインスタンスを生成
        let metadata = StorageMetadata()
        // 保存するファイルの情報を指定
        metadata.contentType = "image/jpeg"
        // 画像をアップロードする
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            // エラーの有無の判定
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                // エラーがある場合、内容を記述したHUDを表示し、メソッドを抜ける
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                // 親のViewController(TabbarController)を取得し、子のViewController(画像選択から投稿画面まで)を全て閉じる
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }

            // ユーザーを取得し、表示名をアンラップ
            if let user = Auth.auth().currentUser,
                let name = user.displayName {
                // 投稿データを保存する辞書を定義
                let postDic: [String : Any] = [
                    "uid": user.uid,
                    "name": name,
                    "caption": self.textField.text!,
                    "date": FieldValue.serverTimestamp(),
                ]
                // FireStoreに投稿データを書き込む
                postRef.setData(postDic)
            }
            
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            // 投稿処理が完了したので先頭画面に戻る
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 投稿画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }

}
