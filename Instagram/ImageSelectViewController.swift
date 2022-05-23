//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import SVProgressHUD
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {

    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBAction
    
    // ライブラリボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）が使用できるかどうかを判定
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //インスタンスを生成
            let pickerController = UIImagePickerController()
            // デリゲートを指定
            pickerController.delegate = self
            // 画像の取得先を指定
            pickerController.sourceType = .photoLibrary
            // 設定したpicker Controllerに遷移する
            self.present(pickerController, animated: true, completion: nil)
        } else {
            // 使用できない場合、内容を記述したHUDを表示
            SVProgressHUD.showError(withStatus: "カメラロールが使用不可です")
        }
        
    }
    
    // カメラボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラが使用できるかどうかを判定する
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスを生成
            let pickerController = UIImagePickerController()
            // デリゲートを指定
            pickerController.delegate = self
            // 画像の取得先を指定
            pickerController.sourceType = .camera
            // 設定したpickerControllerに遷移する
            self.present(pickerController, animated: true, completion: nil)
        } else {
            // 使用できない場合、内容を記述したHUDを表示
            SVProgressHUD.showError(withStatus: "カメラが使用不可です")
        }
    }
    
    // キャンセルボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画像選択画面を閉じる
        self.dismiss(animated: true,completion: nil)
    }
    
    // MARK: - デリゲートメソッド
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // UIImageにダウンキャストした辞書infoの値を、アンラップし、それを引数に指定したCLImageEditorを生成
        if let image = info[.originalImage] as? UIImage, let editor = CLImageEditor(image: image) {
            print("DEBUG_PRINT: image = \(image)")
            // デリゲートを指定
            editor.delegate = self
            // 加工画面を起動する
            self.present(editor, animated: true, completion: nil)
            
        }
    }
    
    // キャンセルした時に呼ばれるメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerControllerを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        //PostViewControllerをstoryboardIDから取得
        if let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as? PostViewController {
            // 遷移先のimageプロパティに画像を渡す
            postViewController.image = image
            // 投稿画面に遷移する
            editor.present(postViewController, animated: true, completion: nil)
        }
    }
    
    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // 加工画面を閉じる
        editor.dismiss(animated: true, completion: nil)
    }
}
