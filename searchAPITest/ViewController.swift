//
//  ViewController.swift
//  serachAPITest
//
//  Created by 민경준 on 08/09/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var seletedCell = ""
    var responseResult = [String]()
    var resultLink = [String]()
    var saveLink = [String]()
    static var tableCount = 0
    var searchWord = ""
    var plist = UserDefaults.standard
    static var wordArray = [String]()
    var setList = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.searchTable.dataSource = self
        self.searchTable.delegate = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Enter the search word"
        self.searchTable.frame.size.height = self.searchTable.contentSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewController.wordArray = loadWordTitle()
        print("wordArray = \(ViewController.wordArray)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ViewController.wordArray = loadWordTitle()
        print("wordArray = \(ViewController.wordArray)")
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchBar.text = nil
            self.seletedCell = "Searched"
            ViewController.tableCount = ViewController.wordArray.count
            
            self.reloadData(self.searchTable)
        } else {
            let searchWord = searchText.replacingOccurrences(of: " ", with: "_")
            getWikiJSONData(searchWord)
            
            print(self.responseResult)
        }
    
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("셀선택")
        
        if self.seletedCell == "Searched" {
            saveWordContent(title: ViewController.wordArray[indexPath.row], link: self.saveLink[indexPath.row])
            self.searchBar.text = nil
            performSegue(withIdentifier: "showWebView", sender: self.saveLink[indexPath.row])
        } else if self.seletedCell == "Changed" {
            saveWordContent(title: self.responseResult[indexPath.row], link: self.resultLink[indexPath.row])
            self.searchBar.text = nil
            performSegue(withIdentifier: "showWebView", sender: self.resultLink[indexPath.row])
        }
        
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.tableCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.searchTable.dequeueReusableCell(withIdentifier: "EmptyCell")
        
        
        if self.seletedCell == "" {
            let emptyCell : EmptyTableViewCell = self.searchTable.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyTableViewCell
            
            return emptyCell
            
        } else if self.seletedCell == "Searched" {
            let searchedCell : SearchedTableViewCell = self.searchTable.dequeueReusableCell(withIdentifier: "Searched") as! SearchedTableViewCell
            
            searchedCell.didSelectedRow = indexPath.row
            
            return loadWordContent(ViewController.wordArray[indexPath.row], cell: searchedCell)
        } else if self.seletedCell == "Changed" {
            let changedCell : RecommendTableViewCell =
            self.searchTable.dequeueReusableCell(withIdentifier: "Recommendation") as! RecommendTableViewCell
            
            return changedText(self.responseResult[indexPath.row], cell: changedCell)
        }
        
        return cell!
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        ViewController.tableCount = ViewController.wordArray.count
        
        self.seletedCell = "Searched"
        self.reloadData(self.searchTable)
        
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = nil
        self.searchBar.showsCancelButton = false
        self.searchBar.endEditing(true)
        ViewController.tableCount = 0
        self.seletedCell = ""
        
        self.reloadData(self.searchTable)
    }
    
    
    func getWikiJSONData(_ text : String) {
        
        let wikiURLString = WikiDataSource.instance.wikiURL
        
        
        let params: Parameters =
            ["action":"opensearch",
             "search":text]
        
        Alamofire.request(wikiURLString, method: .get, parameters: params)
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let responseData = try JSONDecoder().decode(WikiDataSource.wikiData.self, from: value)
                        self.resultLink = responseData.resultLinks
                        self.responseResult = responseData.responseResult
                        self.searchWord = responseData.searchWord
                        
                        self.seletedCell = "Changed"
                        ViewController.tableCount = self.responseResult.count
                        
                        self.reloadData(self.searchTable)
                        
                    } catch {
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
        
    }
    
    func reloadData(_ table : UITableView) {
        ViewController.wordArray = loadWordTitle()
        table.reloadData()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.frame.size.height = self.searchTable.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("웹뷰로 이동")
        let webVC = segue.destination as! WebViewController
        webVC.wikiURL = sender as! String
    }
    
    func saveWordContent(title : String, link : String) {
        var wordList = self.plist.array(forKey: "searchedlist") ?? [String]()
        
        for i in wordList {
            self.setList.insert(i as! String)
        }
        
        if setList.insert(title).inserted {
            wordList.append(title)
            
            self.plist.set(wordList, forKey: "searchedlist")
            self.plist.synchronize()
        }
        
        
        let customPlist = "\(title).plist"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plistFile = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plistFile) ?? NSMutableDictionary()
        
        data.setValue(link, forKey: "link")
        
        let today = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today as Date)
        
        data.setValue(dateString, forKey: "date")
        
        data.write(toFile: plistFile, atomically: true)
    }
    
    func loadWordContent(_ title : String, cell : SearchedTableViewCell) -> SearchedTableViewCell {
        
        let customPlist = "\(title).plist"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let clist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSDictionary(contentsOfFile:clist)
        
        cell.searchedText.text = title
        cell.timeText.text = data?["date"] as? String
        self.saveLink.append(data?["link"] as? String ?? "")
        
        return cell
    }
    
    func loadWordTitle() -> [String]{
        let wordTitle = self.plist.array(forKey: "searchedlist") ?? [String]()
        
        print("결과 값 = \(wordTitle)")
        
        return wordTitle as! [String]
    }
    
    func changedText(_ word : String, cell : RecommendTableViewCell) -> RecommendTableViewCell {
        
        let text = word
        let textRange = (text as NSString).range(of: self.searchWord)
        
        let resultText = NSMutableAttributedString(string: text)
        resultText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: textRange)
        cell.recommendText.attributedText = resultText
        
        return cell
    }

}
