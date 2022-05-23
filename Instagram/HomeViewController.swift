//
//  HomeViewController.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/10.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Member Variable
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    var postId = ""
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲートを指定
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // 指定したxibファイルを取得
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        // テーブルビューにnib(カスタムセル)を登録
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // 投稿を日付順に並べたクエリを取得
            let postsRef = Firestore.firestore().collection(Const.postPath).order(by: "date", descending: true)
            // listenerを登録して投稿データの更新を監視する
            self.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                // エラーの有無を判定
                if let error = error {
                    // エラーがある場合、メソッドを抜ける
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                if let querySnapshot = querySnapshot {
                    // 取得したdocumentの配列の全要素に要素を引数にPostDataのインスタンスを生成する処理を行う。
                    self.postArray = querySnapshot.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        // 投稿ごとに生成したPostDataのインスタンスを配列の要素として返す
                        return postData
                    }
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()
    }
    
    // MARK: - Delegate Method
    
    // セルの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数に配列postArrayの要素数(投稿の数)を指定
        return self.postArray.count
    }
    
    // セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なセルがあればそのセル、なければ新しく作ったものを取得
        // PostTavleViewCellに型キャスト
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        // PostDataの内容を表示するためのメソッドを呼び出す
        cell.setPostData(self.postArray[indexPath.row])
        
        // セル内のボタンをタップしたら指定したクラスの指定したメソッドを呼び出すように設定する
        cell.likeButton.addTarget(self, action:#selector(handleLikeButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self,action:#selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }    

    // MARK: - Private Method
    
    // セル内のいいねボタンがタップされた時に呼ばれるメソッド
    @objc func handleLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップ情報を取得
        let touch = event.allTouches?.first
        // タップ情報からtableView内での座標を取得し、その座標からTableViewのindexPathを取得
        if let point = touch?.location(in: self.tableView), let indexPath = self.tableView.indexPathForRow(at: point) {
            // 配列からタップされた投稿データを取り出す
            let postData = self.postArray[indexPath.row]
            
            // ログインユーザーのidを取得
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                // いいねが押されているか判定
                if postData.isLiked {
                    // 配列からmyidを取り除く更新データを作成
                    updateValue = FieldValue.arrayRemove([myid])
                } else {
                    // 配列にmyidを追加する更新データを作成
                    updateValue = FieldValue.arrayUnion([myid])
                }
                // タップした投稿のドキュメントを取得
                let postRef = Firestore.firestore().collection(Const.postPath).document(postData.id)
                // likes配列に対して更新データの内容を更新
                postRef.updateData(["likes": updateValue])
            }
        }
    }
    
    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました。")
        
        // タップ情報を取得
        let touch = event.allTouches?.first
        //タップ情報からtableView内での座標を取得し、その座標からTableViewのindexPathを取得
        if let point = touch?.location(in: self.tableView), let indexPath = self.tableView.indexPathForRow(at: point) {
            // 配列からタップされた投稿データのidを取り出す
            self.postId = self.postArray[indexPath.row].id
        }
        // storyboardIDからCommentViewControllerを取得し、型キャスト
        if let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as? CommentViewController {
            // 投稿のidを遷移先に渡す
            commentViewController.postId = self.postId
            // コメント画面に遷移する
            self.present(commentViewController, animated: true, completion: nil)
        }
        
        
    }
    

}
