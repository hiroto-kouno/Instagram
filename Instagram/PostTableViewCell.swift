//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 河野 裕門 on 2022/05/13.
//

import UIKit
import FirebaseStorageUI

class PostTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    // MARK: - Lifecycle Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Private Method
    // PostDataの内容をカスタムセルに表示
    func setPostData(_ postData: PostData) {
        // インジケーターを指定
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        // 画像のダウンロード先を取得し、名前を設定
        let imageRef = Storage.storage().reference().child(Const.imagePath).child(postData.id + ".jpg")
        // Storageから画像をダウンロードしImageViewに表示
        self.postImageView.sd_setImage(with: imageRef)
        
        // 投稿キャプション+コメントの文字列を格納する変数を用意
        var allCaption: String = ""
        // postDataから投稿者、投稿キャプションを取得
        if let name = postData.name, let caption = postData.caption {
            // 投稿者、キャプションをラベルに表示し、コメント用に2行改行
            allCaption = "\(name) : \(caption)\n\n"
        }
        
        // コメント数を表示
        self.commentLabel.text = "\(postData.comments.count)"
        
        // 全てのコメントをキャプションに追加
        for comment in postData.comments {
            allCaption.append(contentsOf:"\(comment)\n")
        }
        
        // キャプションを表示
        self.captionLabel.text = allCaption
        
        // 日時の表示
        // 文字列の初期化
        self.dateLabel.text = ""
        // postDataから日付を取得
        if let date = postData.date {
            let formatter = DateFormatter()
            // 日付フォーマットを指定
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            // date型をstring型に変更
            let dateString = formatter.string(from: date)
            // 日付をラベルに表示
            self.dateLabel.text = dateString
        }
        
        // いいね配列からいいね数を取得
        let likeNumber = postData.likes.count
        // いいね数を表示
        self.likeLabel.text = "\(likeNumber)"
        // すでにいいねをした投稿か判定
        if postData.isLiked {
            // した場合の処理
            // ボタンのイメージを取得
            let buttonImage = UIImage(named: "like_exist")
            // 取得したイメージを設定する
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            // してない場合の処理
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        
        
    }
    
}
