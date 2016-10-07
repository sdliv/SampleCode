//
//  ViewController.swift
//  SampleCode
//
//  Created by Sean Livingston on 10/6/16.
//  Copyright © 2016 Sean Livingston. All rights reserved.
//

import UIKit

extension Collection {
    // Return a copy of 'self' with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    // Shuffle the elements of 'self' in-place.
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in startIndex..<endIndex-1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

private let reuseIdentifier = "productCell"
private let recReuseIdentifier = "RecommendationCell"

class ProductUICollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ShowAlertDelegate {
    
    var departments:[String] = [String]()
    let dataSource = DataSource.sharedDataSource.items
    var recommendationManager: RecommendationManager!
    var items: [Item] = [Item]()
    var selectedProduct: Item!
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var searchBarActive: Bool = false
    var brands: [String] = ["Brand 1", "Brand 2", "Brand 3", "Brand 4", "Brand 5", "Brand 6", "Brand 7", "Brand 8", "Brand 9", "Brand 10", "Brand 11", "Brand 12", "Brand 13", "Brand 14"]
    
    @IBOutlet weak var segmentControl: SegmentedControl!
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var recommendationCollection: UICollectionView!
    @IBOutlet weak var departmentsTableView: UITableView!
    @IBOutlet weak var recDepartmentView: UIView!
    @IBOutlet weak var brandsView: UIView!
    @IBOutlet weak var brandSearch: UISearchBar!
    @IBOutlet weak var brandsTableView: UITableView!
    
    // Reloads specific TableView or Collection view based on segment selected.
    @IBAction func segmentSelected(_ sender: AnyObject) {
        if segmentControl.selectedIndex == 0 {
            self.shopCollectionView.isHidden = false
            self.recDepartmentView.isHidden = true
            self.brandsView.isHidden = true
            
            shopCollectionView.reloadData()
        }
        
        if segmentControl.selectedIndex == 1 {
            self.recDepartmentView.isHidden = false
            self.shopCollectionView.isHidden = true
            self.brandsView.isHidden = true
            
            self.recommendationCollection.reloadData()
            self.departmentsTableView.reloadData()
        }
        
        if segmentControl.selectedIndex == 2 {
            self.brandsView.isHidden = false
            self.recDepartmentView.isHidden = true
            self.shopCollectionView.isHidden = true
            
            self.brandsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if noAllowanceForRecommendationsAtDepartments() == false {
            self.recommendationCollection.isHidden = true
            self.recommendationCollection.isUserInteractionEnabled = false
        }
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image: logo)
        
        self.navigationItem.titleView = imageView
        
        let nib = UINib(nibName: "ProductionCell", bundle: nil)
        self.shopCollectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        let recNib = UINib(nibName: "RecommendationCell", bundle: nil)
        self.recommendationCollection.register(recNib, forCellWithReuseIdentifier: recReuseIdentifier)
        
        shopCollectionView.delegate = self
        shopCollectionView.dataSource = self
        
        recommendationCollection.delegate = self
        recommendationCollection.dataSource = self
        
        departmentsTableView.delegate = self
        departmentsTableView.dataSource = self
        
        brandsTableView.delegate = self
        brandsTableView.dataSource = self
        brandSearch.delegate = self
        
        grabData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBarSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSetup() {
        self.brandSearch.layer.borderWidth = 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Determines what array to return based on segment selected.
        
        if self.segmentControl.selectedIndex == 0 {
            return items.count
        } else if self.segmentControl.selectedIndex == 1 {
            return items.count
        } else {
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var productCell: ProductCollectionViewCell!
        var recommendationCell: RecommendationCell!
        
        // Switches type of UICollectionViewCell based on which segment index is selected.
        
        if self.segmentControl.selectedIndex == 0 {
            
            productCell = shopCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
            productCell.delegate = self
            let item = items[(indexPath as NSIndexPath).row]
            productCell.layer.borderWidth = 0.1
            productCell.layer.borderColor = UIColor.gray.cgColor
            productCell.setupCell(item)
            return productCell
        } else if self.segmentControl.selectedIndex == 1 {
            recommendationCell = recommendationCollection.dequeueReusableCell(withReuseIdentifier: recReuseIdentifier, for: indexPath) as! RecommendationCell
            recommendationCell.delegate = self
            
            let item = items[(indexPath as NSIndexPath).row]
            recommendationCell.layer.borderWidth = 0.1
            recommendationCell.layer.borderColor = UIColor.gray.cgColor
            recommendationCell.setupCell(item)
            return recommendationCell
        } else {
            productCell = shopCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
            
            let item = items[(indexPath as NSIndexPath).row]
            productCell.layer.borderWidth = 0.1
            productCell.layer.borderColor = UIColor.gray.cgColor
            productCell.setupCell(item)
            return productCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 191, height: 300)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedIndex == 2 {
            return brands.count
        } else {
            return departments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Determines which UITableViewCell to use based on which segment is selected
        
        if self.segmentControl.selectedIndex == 1 {
            let cell = departmentsTableView.dequeueReusableCell(withIdentifier: "DepartmentsCell", for: indexPath) as UITableViewCell
            let department = departments[(indexPath as NSIndexPath).row]
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = department
            
            return cell
        } else if self.segmentControl.selectedIndex == 2 {
            let cell = brandsTableView.dequeueReusableCell(withIdentifier: "brandCell", for: indexPath) as UITableViewCell
            let brand = brands[(indexPath as NSIndexPath).row]
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = brand
            
            return cell
        } else {
            let cell = departmentsTableView.dequeueReusableCell(withIdentifier: "DepartmentsCell", for: indexPath) as UITableViewCell
            
            cell.textLabel?.text = ""
            
            return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Swicthes between which UITableView inherits this function depending on segment selected
        
        if self.segmentControl.selectedIndex == 1 {
            let selectedDepartment = departments[(indexPath as NSIndexPath).row]
            
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "DepartmentsTableView") as! DepartmentProductsTableViewController
            
            for item in items {
                if item.category == selectedDepartment {
                    destVC.productsInCategory.append(item)
                }
            }
            
            destVC.selectedDepartment = selectedDepartment
            
            self.navigationController?.pushViewController(destVC, animated: true)
            self.departmentsTableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.brandsTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.brandSearch.showsCancelButton = true
        searchBarActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.brandSearch.showsCancelButton = false
        
        searchBarActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        brandSearch.text = ""
        brandSearch.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        brandSearch.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let waitingIndicator: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        waitingIndicator.mode = MBProgressHUDMode.indeterminate
        waitingIndicator.label.text = "Loading..."
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async { () -> Void in
            let selectedItem = self.items[(indexPath as NSIndexPath).row]
            
            addItemToPersonallyRecommend(selectedItem)
            
            self.selectedProduct = selectedItem
            
            addItemToFavorites(self.selectedProduct)
            
            
            let storyboard = UIStoryboard(name: "ProductViewStoryboard", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "NewProductViewController") as! NewProductViewController
            
            destVC.selectedItem = self.selectedProduct
            
            DispatchQueue.main.async(execute: { () -> Void in
                waitingIndicator.hide(animated: true)
                self.navigationController?.pushViewController(destVC, animated: true)
                
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ProductViewController
        
        viewController.selectedProduct = self.selectedProduct
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func showAlert() {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        
        let checkMarkImage = UIImage(named: "checkMark")
        let tintedImage = checkMarkImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        let customView = UIImageView(image: tintedImage)
        customView.tintColor = UIColor.white
        
        hud.customView = customView
        hud.mode = .customView
        
        hud.label.text = "Item Added."
        hud.label.textColor = UIColor.black
        hud.margin = CGFloat(Float(10))
        
        hud.offset.y = CGFloat(Float(150))
        hud.isUserInteractionEnabled = false
        hud.removeFromSuperViewOnHide = true
        
        hud.hide(animated: true, afterDelay: 1.5)
        
    }
    
    func grabData() {
        DataSource.sharedDataSource.apiRequest { (result) in
            
            self.items = result as! [Item]
            
            if fromNotificationSegue  {
                for item in self.items {
                    if item.itemID == productIDFromNotification {
                        self.selectedProduct = item
                        break
                    }
                }
            }
            
            self.departments = DataSource.sharedDataSource.categories
            
            if fromNotificationSegue {
                if self.selectedProduct != nil {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "ProductViewStoryboard", bundle: nil)
                        let destVC = storyboard.instantiateViewController(withIdentifier: "NewProductViewController") as! NewProductViewController
                        destVC.selectedItem = self.selectedProduct
                        self.navigationController?.pushViewController(destVC, animated: true)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.shopCollectionView.reloadData()
                self.recommendationCollection.reloadData()
                self.departmentsTableView.reloadData()
            }
        }
    }
}
