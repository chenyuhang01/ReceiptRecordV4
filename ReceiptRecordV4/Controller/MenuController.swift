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


let SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW: CGFloat = 5
let SPACE_BETWEEN_CELL_TOP_DOWN: CGFloat = 10
let SPACE_BETWEEN_CELL_LEFT_RIGHT: CGFloat = 0
let NUM_OF_COLLECTION_CELL_PER_ROW: CGFloat = 2

class MenuVC: UIViewController {
    // DI
    var receiptManager: ReceiptRecordManager!
    var documentCameraViewController: VNDocumentCameraViewController!
    var addMainVC: AddMainVC!
    var detailVC: DetailVC!
    
    // ViewModels
    var databaseVM: DatabaseVM?
    var receiptRecordArrayVM: ReceiptRecordArrayVM?
    var receiptRecordArrayDoneVM: ReceiptRecordArrayVM?
    var receiptRecordArrayNotDoneVM: ReceiptRecordArrayVM?
    
    // UI Component
    @IBOutlet weak var dateIndicateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
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
        // Setup Scan VC delegate
        documentCameraViewController.delegate = self
    }
    
    private func configureTableViewCell() {
        let nib = UINib(nibName: "TableReceiptViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TableReceiptViewCell")
        let nibForSectionCell = UINib(nibName: "HeaderViewCell", bundle: nil)
        self.tableView.register(nibForSectionCell, forCellReuseIdentifier: "HeaderViewCell")
    }
    
    private func configureCollectionViewCell() {
        let nib = UINib(nibName: "TableReceiptCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "TableReceiptCollectionViewCell")
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
    
    private func configureCollectionViewDelegate() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func configureSegmentControll() {
        segmentTableControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 28), .foregroundColor: UIColor.tertiaryColor], for: .selected)
        segmentTableControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.tertiaryColor], for: .normal)
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressedGesture)
    }
    
    private func configureUI() {
        
        self.configureTabVC()
        self.configureTableViewCell()
        self.revealEmptyIndicator()
        self.configureSegmentControll()
        self.configureTableViewDelegate()
        self.configureCollectionViewCell()
        self.configureCollectionViewDelegate()
        self.setupLongGestureRecognizerOnCollection()
        
        let screenSize: CGRect = UIScreen.main.bounds
        NSLayoutConstraint(item: self.horizontalNavStackView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenSize.width - 50).isActive = true
        
        self.dateIndicateLabel.textColor = UIColor.tertiaryColor
        self.dateLabel.textColor = UIColor.tertiaryColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.dateLabel.text = dateFormatter.string(from: Date())
        
        // self.collectionView.isHidden = true
    }
    @IBAction func segmentControlValueOnChanged(_ sender: Any) {
        cellIdentifier = (self.segmentTableControl.selectedSegmentIndex == 0) ? CellType.NotDone : CellType.Done
        if cellIdentifier == .NotDone {
            self.collectionView.isHidden = false
        }
        else {
            self.tableView.isHidden = false
            self.collectionView.isHidden = true
            self.tableView.reloadData()
        }
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
            if self.cellIdentifier == .NotDone {
                self.collectionView.reloadData()
            } else {
                self.tableView.reloadData()
            }
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
        guard let receiptArrVM = self.receiptRecordArrayVM else { return UITableViewCell() }
        // Get the number of not done cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableReceiptViewCell", for: indexPath) as! TableReceiptViewCell
        var recordVM: ReceiptRecordVM
        if cellIdentifier == .Done {
            receiptArrVM.switchMode(mode: .Done)
            guard let vmList = self.getParticularDateSectionList(theSectionBelongsTo: indexPath.section) else { return UITableViewCell() }
            recordVM = vmList[indexPath.row]
        } else {
            receiptArrVM.switchMode(mode: .NotDone)
            recordVM = receiptArrVM[indexPath.row]
        }
        
        cell.setRecordVM(recordVM: recordVM)
        cell.setInformation( )
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
        guard let vmList = self.getParticularDateSectionList(theSectionBelongsTo: indexPath.section) else { return }
        let recordVM = vmList[indexPath.row]
        self.detailVC.recordVM = recordVM
        self.navigationController?.pushViewController(self.detailVC, animated: true)
    }
    
    func getParticularDateSectionList(theSectionBelongsTo section: Int) -> [ReceiptRecordVM]? {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return nil }
        let selectedDate: String = receiptArrVM.getOrderedDateList()[section]
        return receiptArrVM.receiptRecordDoneDateDict[selectedDate]
    }
    
    
    // Swipe left action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return 0 }
        if cellIdentifier == .NotDone {
            return receiptArrVM.getNotDoneCount()
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return UICollectionViewCell( ) }
        receiptArrVM.switchMode(mode: .NotDone)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "TableReceiptCollectionViewCell", for: indexPath) as! TableReceiptCollectionViewCell
        cell.setRecordVM(recordVM: receiptArrVM[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let receiptVM = self.getUnDoneRecordVM(idx: indexPath.row) else { return }
        self.navigationController?.pushViewController(addMainVC, animated: true)
        addMainVC.setRecordVM(recordVM: receiptVM)
        addMainVC.receiptRecordManager = receiptManager
    }
    
    func getUnDoneRecordVM(idx: Int) -> ReceiptRecordVM? {
        guard let receiptArrVM = self.receiptRecordArrayVM else { return nil }
        var returnVM: ReceiptRecordVM?
        let originalMode = receiptArrVM.mode
        receiptArrVM.switchMode(mode: .NotDone)
        returnVM = receiptArrVM[idx]
        receiptArrVM.switchMode(mode: originalMode)
        return returnVM
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let p = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView?.indexPathForItem(at: p) {
            print("Long press at item: \(indexPath.row)")
            
            self.promptUserAction { IsConfirm in
                if IsConfirm {
                    guard let receiptArrVM = self.receiptRecordArrayVM else { return }
                    receiptArrVM.switchMode(mode: .NotDone)
                    
                    let recordVM = receiptArrVM[indexPath.row]
                    recordVM.markAsArchived()
                    
                    self.receiptManager.updateNewReceiptRecord(receiptRecord: recordVM.receiptRecord) { IsSuccess in
                        if ( IsSuccess )
                        {
                            print(IsSuccess)
                        }
                    }
                }
            }
        }
    }
    
    private func promptUserAction(completion: @escaping (Bool)->Void) {
        let ConfirmAlert = UIAlertController(title: "Confirm to delete", message: "The image will be deleted", preferredStyle: .alert)

        ConfirmAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            completion(true)
        }))
        
        ConfirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            completion(false)
        }))
        
        present(ConfirmAlert, animated: true, completion: nil)
    }
}

extension MenuVC: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW, left: SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW, bottom: SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW, right: SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW)
    }
    
    ///  設定 CollectionViewCell 的寬、高
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = ( self.collectionView.frame.width ) / NUM_OF_COLLECTION_CELL_PER_ROW - ( SPACE_BETWEEN_SUPERVIEW_AND_COLLECTION_VIEW * 2 )
        return CGSize(width: frameWidth , height: frameWidth)
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SPACE_BETWEEN_CELL_TOP_DOWN
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SPACE_BETWEEN_CELL_LEFT_RIGHT
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
                                DispatchQueue.main.async {
                                    self.forceInit()
                                }
                            }
                        })
                    }
                }
            }
        }
        
        
        dismiss(animated: true) {
            self.tabBarController?.selectedIndex = 0
            self.refresh()
        }
    }
    
    func refresh() {
        if let tabBarController = self.tabBarController {
            let indexToRemove = 1
            if indexToRemove < tabBarController.viewControllers!.count {
                var viewControllers = tabBarController.viewControllers
                viewControllers?.remove(at: indexToRemove)
                tabBarController.viewControllers = viewControllers
                documentCameraViewController = VNDocumentCameraViewController()
                self.configureTabVC()
                print("renew")
            }
        }
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
