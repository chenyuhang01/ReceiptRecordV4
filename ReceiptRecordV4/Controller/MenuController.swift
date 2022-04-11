//
//  ViewController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 27/3/22.
//

import UIKit
import Vision
import VisionKit

let HEADER_HEIGHT: CGFloat = 70
let NO_HEADER: CGFloat = 0
let CELL_HEIGHT: CGFloat = 140

class MenuVC: UIViewController {
    // DI
    var receiptManager: ReceiptRecordManager!
    var documentCameraViewController: VNDocumentCameraViewController!
    var addMainVC: AddMainVC!
    
    // ViewModels
    var databaseVM: DatabaseVM?
    var receiptRecordArrayVM: ReceiptRecordArrayVM?
    var receiptRecordArrayDoneVM: ReceiptRecordArrayVM?
    var receiptRecordArrayNotDoneVM: ReceiptRecordArrayVM?
    
    // UI Component
    @IBOutlet weak var dateIndicateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStackView: UIStackView!
    @IBOutlet weak var horizontalNavStackView: UIStackView!
    @IBOutlet weak var segmentTableControl: UISegmentedControl!
    
    // Segment control value
    var cellIdentifier: CellType = .NotDone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureUI()
        self.setupObserver()
        self.forceInit()
    }
}
/*
 Setting up UI Component
 */
extension MenuVC {
    private func configureTabVC() {
        self.tabBarController?.viewControllers?.insert(documentCameraViewController, at: 1)
        documentCameraViewController.tabBarItem.title = "Scan"
        documentCameraViewController.tabBarItem.image = UIImage(named: "scan.png")
    }
    
    private func configureTableViewCell() {
        let nib = UINib(nibName: "TableReceiptViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TableReceiptViewCell")
        let nibForSectionCell = UINib(nibName: "HeaderViewCell", bundle: nil)
        self.tableView.register(nibForSectionCell, forCellReuseIdentifier: "HeaderViewCell")
    }
    
    private func revealEmptyIndicator() {
        self.tableView.isHidden = true
        self.emptyStackView.isHidden = false
    }
    
    private func unrevealEmptyIndicator() {
        self.tableView.isHidden = false
        self.emptyStackView.isHidden = true
    }
    
    private func configureTableViewDelegate() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    private func configureUI() {
        
        self.configureTabVC()
        self.configureTableViewCell()
        self.revealEmptyIndicator()
        self.configureTableViewDelegate()
        let screenSize: CGRect = UIScreen.main.bounds
        NSLayoutConstraint(item: self.horizontalNavStackView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenSize.width).isActive = true
        
        self.dateIndicateLabel.textColor = UIColor.tertiaryColor
        self.dateLabel.textColor = UIColor.tertiaryColor
    }
    @IBAction func segmentValueOnChanged(_ sender: Any) {
        cellIdentifier = (self.segmentTableControl.selectedSegmentIndex == 0) ? CellType.NotDone : CellType.Done
        self.tableView.reloadData()
    }
}

/*
 Setting Observer pattern framework
 */
extension MenuVC {
    
    func setupObserver() {
        // Suscribe to the data update msg
        NotificationCenter.default.addObserver(self, selector: #selector(databaseUpdateMsg), name: .databaseUpdatesPostMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRecordUpdateMsg), name: .receiptRecordUpdatesPostMessage, object: nil)
        
        // Setup Scan VC delegate
        documentCameraViewController.delegate = self
    }
    
    func forceInit() {
        self.receiptManager.refreshDatabase()
        self.receiptManager.refreshReceiptRecord()
    }
    
    @objc func databaseUpdateMsg(_ notification: Notification) {
        guard let databaseVM = notification.object as? DatabaseVM else { return }
        self.databaseVM = databaseVM
    }
    
    @objc func receiptRecordUpdateMsg(_ notification: Notification) {
        guard let receiptRecordArrayVM = notification.object as? ReceiptRecordArrayVM else { return }
        self.receiptRecordArrayVM = receiptRecordArrayVM
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.unrevealEmptyIndicator()
        }
    }
}


/*
 Table View Implementation
*/
extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return 0 }
        
        if cellIdentifier == .Done {
            return receiptArrVM.getOrderedDateListCount()
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return 0 }

        if cellIdentifier == .Done {
            guard let list = self.getParticularDateSectionList(theSectionBelongsTo: section) else { return 0 }
            return list.count
        } else {
            return receiptArrVM.getNotDoneCount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var textToDisplay: String?
        guard let receiptArrVM = self.receiptRecordArrayVM else { return UITableViewCell() }
        // Get the number of not done cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableReceiptViewCell", for: indexPath) as! TableReceiptViewCell
        var recordVM: ReceiptRecordVM
        if cellIdentifier == .Done {
            receiptArrVM.switchMode(mode: .Done)
            guard let vmList = self.getParticularDateSectionList(theSectionBelongsTo: indexPath.section) else { return UITableViewCell() }
            recordVM = vmList[indexPath.row]
            cell.setUIImage(uIImage: UIImage(named: "cloth.jpg")!)
            textToDisplay = recordVM.getPropertiesValue(type: .Title)
        } else {
            receiptArrVM.switchMode(mode: .NotDone)
            recordVM = receiptArrVM[indexPath.row]
            cell.setImage(imageUrl: recordVM.getPropertiesValue(type: .ImageUrl))
            textToDisplay = recordVM.getPropertiesValue(type: .PurchasedDate)
        }
        
        cell.setInformation(title: textToDisplay!,
                            price: recordVM.getPropertiesNumericValue(type: .Price))
        cell.postProcess()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if cellIdentifier == .Done {
            guard let receiptArrVM = self.receiptRecordArrayVM else { return UITableViewCell() }
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "HeaderViewCell") as! HeaderViewCell
            cell.setWidth(widthOfCell: self.tableView.frame.width)
            cell.setTitle(title: receiptArrVM.getOrderedDateList()[section])
            return cell
        } else {
            // No header for not done cell type
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear.cgColor
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Only Done cell type have the header
        if cellIdentifier == .Done {
            return HEADER_HEIGHT
        } else {
            return NO_HEADER
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func getParticularDateSectionList(theSectionBelongsTo section: Int) -> [ReceiptRecordVM]? {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return nil }
        let selectedDate: String = receiptArrVM.getOrderedDateList()[section]
        return receiptArrVM.receiptRecordDoneDateDict[selectedDate]
    }
}

/*
   Scan view Controller
*/
extension MenuVC: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

        if scan.pageCount == 0 {
            dismiss(animated: true, completion: nil)
            return
        }
        
        print("AA")
        
        for index in 0...(scan.pageCount - 1) {
            let uiImage = scan.imageOfPage(at: index)
            let imageName = self.randomFileName(length: 10)
            
            DispatchQueue(label: "Uploading new records").async {
                FirebaseManager.shared.uploadingImage(uiImage: uiImage, imageName: imageName) { urlString, errorMsg in
                    if let errorMsg = errorMsg {
                        print(errorMsg)
                    }
                    
                    if let urlString = urlString {
                        guard let newRecordVM = self.receiptManager.spawnNewReceiptRecord() else { return }
                        newRecordVM.setPropertiesValue(type: .Title, value: "")
                        newRecordVM.setPropertiesNumericValue(type: .Price, value: -1)
                        newRecordVM.setPropertiesValue(type: .ImageUrl, value: urlString)
                        newRecordVM.clearArchived()
                        newRecordVM.setUIImage(Image: uiImage)
                        self.receiptManager.insertNewReceiptRecord(receiptRecord: newRecordVM.receiptRecord, completion: { isSuccess in
                            if isSuccess {
                                print("Success")
                            }
                        })
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
    }
    
    func randomFileName(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension MenuVC {
    enum CellType {
        case Done
        case NotDone
    }
}
