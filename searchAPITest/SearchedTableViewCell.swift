//
//  SearchedTableViewCell.swift
//  serachAPITest
//
//  Created by 민경준 on 08/09/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit

class SearchedTableViewCell: UITableViewCell {

    @IBOutlet weak var searchedText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    let tableVC : ViewController = ViewController()
    var didSelectedRow = 0
    var plist = UserDefaults.standard
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    @IBAction func deleteRecord(_ sender: UIButton) {
        deleteData()
        
        print("wordArray = \(ViewController.wordArray)")
        guard let contentView = sender.superview else {
            print("contentView 오류")
            return
        }
        guard let cell = contentView.superview as? SearchedTableViewCell else {
            print("cell 오류")
            return
        }
        guard let table = cell.superview as? UITableView else {
            print("table 오류")
            return
        }
        
        table.reloadData()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.frame.size.height = table.contentSize.height
        print("Running reload")
    }
    
    func deleteData() {
        
        print("데이터 삭제")
        
        var wordList = self.plist.array(forKey: "searchedlist") ?? [String]()

        wordList.remove(at: didSelectedRow)
        ViewController.wordArray = wordList as! [String]
        ViewController.tableCount = ViewController.wordArray.count
        
        self.plist.set(wordList, forKey: "searchedlist")
    }
    
}
