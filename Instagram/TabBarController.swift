//
//  TabBarController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // インスタンスを生成
        let appearance = UITabBarAppearance()
        // タブバーの背景色を設定
        appearance.backgroundColor =  UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        // スクロール中、通常時のtabbarの見た目を設定
        self.tabBar.standardAppearance = appearance
        // 画面下端までスクロールした際のtabbarの見た目を設定
        self.tabBar.scrollEdgeAppearance = appearance
        // デリゲートを指定
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        
        // LoginViewControllerをstoryboardIDから取得する、ユーザがログインしているかの判定
        if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login"),  Auth.auth().currentUser == nil {
            // ログインしてない場合、ログイン画面を表示
            self.present(loginViewController, animated: true, completion: nil)
        }
        
    }

    // MARK: - Delegate Method
    
    // タブバーのアイコンがタップされた時に呼ばれるメソッドで、タブ遷移を行うか否かを返す
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // タップされたタブのViewControllerがImageSelectViewControllerかを判定
        if viewController is ImageSelectViewController {
            // storyboardIDからImageSelectViewControllerを取得
            if let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") {
                // 画像選択画面を表示
                self.present(imageSelectViewController, animated: true)
            }
            // モーダル遷移をさせるため、タブ遷移を行わない
            return false
        } else {
            // その他のViewControllerはタブ遷移を行う
            return true
        }
    }

}
