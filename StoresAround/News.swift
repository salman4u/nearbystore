/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse


// MARK: - CUSTOM NEWS CELL
class NewsCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
}






// MARK: - NEWS CONTROLLER
class News: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var newsTableView: UITableView!
    let refreshControl = UIRefreshControl()

    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Init a refresh Control
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    newsTableView.addSubview(refreshControl)
    

    // Call query
    queryNews()
}

 
// MARK: - REFRESH DATA
@objc func refreshTB () {
   // newsArray.removeAll()
    queryNews()
    print(newsArray.count)
    if refreshControl.isRefreshing {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: date))"
        let attrsDictionary = NSDictionary(object: UIColor.darkGray, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary as? [NSAttributedStringKey : Any]);
        refreshControl.attributedTitle = attributedTitle
        refreshControl.endRefreshing()
        self.newsTableView.reloadData()
    }
}
  
 
    
// MARK: - QUERY NEWS
func queryNews() {
    showHUD()
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}

}
 
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(newsArray.count)
    return newsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
    
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    print(indexPath.row)
    print(newsArray[indexPath.row])
    newsClass = newsArray[indexPath.row]
    
    cell.mainView.layer.cornerRadius = 10
    
    cell.newsImage.layer.cornerRadius = 10
    cell.newsImage.layer.masksToBounds = true
    cell.newsImage.layer.borderColor = UIColor(red: 128.0/255, green: 128.0/255, blue: 128.0/255, alpha: 1.0).cgColor
    cell.newsImage.layer.borderWidth = 2.0
    
    cell.titleLabel.text = "\(newsClass[NEWS_TITLE]!)"
    cell.newsLabel.text = "\(newsClass[NEWS_TEXT]!)"
    
    // Get Date
    let date = newsClass.createdAt
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM dd yyyy"
    cell.dateLabel.text = dateFormat.string(from: date!)
    
    // Get image
    let imageFile = newsClass[NEWS_IMAGE] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.newsImage.image = UIImage(data:imageData)
    }}})
    

    
return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 160
}
    

// MARK: -  CELL HAS BEEN TAPPED
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[indexPath.row]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsDetails") as! NewsDetails
    aVC.newsObj = newsClass
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
