//
//  ViewController.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 07.08.2023.
//

import UIKit
import RealmSwift

struct CameraModelResponse {
    let success: Bool
    let data: CameraDataModel
}

struct CameraDataModel {
    let room: [String]
    let cameras: [CameraModel]
}

struct CameraModel {
    let id: Int
    let name: String
    let snapshot: String
    let room: String
    let favorites: Bool
    let rec: Bool
}

struct DoorsModel {
    let success: Bool
    let data: [DoorsDataModel]
}

struct DoorsDataModel {
    let id: Int
    var name: String
    let room: String
    let favorites: Bool
    let snapshot: String?
}

final class MainViewController: UIViewController {
    
    private enum Constants {
        static let segmentedControlHeight: CGFloat = 40
        static let underlineViewHeight: CGFloat = 2
        static let rowActionWidth: CGFloat = 40
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private lazy var bottomUnderlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = R.color.mainBlue()!
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()

    private lazy var leadingDistanceConstraint: NSLayoutConstraint = {
        return bottomUnderlineView.leftAnchor.constraint(equalTo: segmentControl.leftAnchor)
    }()
    
    // MARK: - Internal vars
    private var service: Services = Services(service: NetworkService())
    private let realm = RealmService.shared
    private var cameras: CameraDataModel?
    private var doors: [DoorsDataModel] = []
    
    private var rowActionTypes: [RowActionType] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - TableView Data Sourse
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return cameras?.cameras.count ?? 0
        default:
            return doors.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as! ContentTableViewCell
            cell.selectionStyle = .none
            cell.setupCameraCell(model: (cameras?.cameras[row])!)
            return cell
        default:
            if doors[row].snapshot != nil {
                if doors[row].snapshot! != "" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as! ContentTableViewCell
                    cell.selectionStyle = .none
                    cell.setupDoorCell(model: doors[row])
                    return cell
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WithoutContentTableViewCell", for: indexPath) as! WithoutContentTableViewCell
            cell.selectionStyle = .none
            cell.setupDoorCell(model: doors[row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return 287
        default:
            if doors[indexPath.row].snapshot != nil {
                if doors[indexPath.row].snapshot != "" {
                    return 287
                }
            }
            return 80
        }
    }
}

// MARK: - TableView Delegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView.cellForRow(at: indexPath) != nil else { return nil }
        
        var contextualActions: [UIContextualAction] = []
        
        if segmentControl.selectedSegmentIndex == 0 {
            rowActionTypes = [.favourite]
        } else {
            rowActionTypes = [.favourite, .edit]
        }
        
        for type in rowActionTypes {
            let rowActionFactory = TCSCustomRowActionFactory { indexPath in
                
                switch type {
                case .edit:
                    self.showAlert(row: indexPath.row)
                case .favourite:
                    print("запрос на добавление в избранное")
                }
                
                tableView.setEditing(false, animated: true)
            }
            
            let rowActionView = createRowActionView(with: 40, type: type)
            rowActionFactory.setupForCell(with: rowActionView)
            
            if let contextualAction = rowActionFactory.contextualAction(for: indexPath) {
                contextualAction.backgroundColor = rowActionBackgroundColor(for: type)
                contextualActions.append(contextualAction)
            }
        }
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: contextualActions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionsConfiguration
    }
}


// MARK: - Private methods
private extension MainViewController {
    private func setupView() {
        setupSegmentControl()
        configureTableView()
        setupRefreshControl()
        
        fetchData()
    }
    
    private func setupRefreshControl() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: "Обновить", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func setupSegmentControl() {
        segmentControl.backgroundColor = R.color.mainBackground()
        segmentControl.tintColor = .clear
        
        let tintcolorimage = UIImage()
        segmentControl.setBackgroundImage(tintcolorimage, for: .normal, barMetrics: .default)
        segmentControl.setDividerImage(tintcolorimage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: R.font.circeLight(size: 17)!], for: .normal)

        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        segmentControl.addSubview(bottomUnderlineView)
        NSLayoutConstraint.activate([
            bottomUnderlineView.bottomAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            bottomUnderlineView.heightAnchor.constraint(equalToConstant: Constants.underlineViewHeight),
            leadingDistanceConstraint,
            bottomUnderlineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments))
        ])
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func showAlert(row: Int) {
        let alertController = UIAlertController(title: "Введите название двери", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Название двери"
        }
        let saveAction = UIAlertAction(title: "Сохранить", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            
            let doorRM = self.realm.realm.objects(DoorsDataRM.self).where {
                $0.id == self.doors[row].id
            }.first!
            try! self.realm.realm.write {
                doorRM.name = firstTextField.text!
            }
            
            self.doors[row].name = firstTextField.text!
            self.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()
        tableView.reloadData()
    }

    private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            fetchCameras()
        default:
            fetchDoors()
            tableView.reloadData()
        }
    }
    
    private func createRowActionView(with height: CGFloat, type: RowActionType) -> RowActionView {
        let className = String(describing: RowActionView.self)
        let rowActionView = Bundle.main.loadNibNamed(className, owner: nil, options: nil)?.first as! RowActionView
        rowActionView.frame = CGRect(x: 0, y: 0, width: Constants.rowActionWidth, height: height)
        
        rowActionView.configure(with: type)
        
        rowActionView.layoutIfNeeded()
        
        return rowActionView
    }
    
    private func rowActionBackgroundColor(for type: RowActionType) -> UIColor {
        switch type {
        default:
            return R.color.mainBackground()!
        }
    }
}

// MARK: - Fetch methods
private extension MainViewController {
    private func fetchData() {
        let cam = Array(realm.read(CamerasRM.self))
        let doors = Array(realm.read(DoorsRM.self))
        
        if !cam.isEmpty {
            presentCamerasRM(cameras: cam)
        } else {
            fetchCameras()
        }
        
        if !doors.isEmpty {
            presentDoorsRM(doors: doors)
        } else {
            fetchDoors()
        }
    }
    
    private func fetchCameras() {
        service.performGetCameras { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                self?.presentCameras(response: response)
            case .failure(let error):
                MessageService.showError(error)
            }
        }
    }
    
    private func fetchDoors() {
        service.performGetDoors { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                self?.presentDoors(response: response)
            case .failure(let error):
                MessageService.showError(error)
            }
        }
    }
}

// MARK: - Present methods
private extension MainViewController {
    private func presentCameras(response: GetCamerasResponse) {
        guard let responseData = response.data else { return }
        
        var cameras: [CameraModel] = []
        let _ = responseData.cameras?.map({ resp in
            let item = CameraModel(id: resp.id ?? 0,
                                   name: resp.name ?? "",
                                   snapshot: resp.snapshot ?? "",
                                   room: resp.room ?? "",
                                   favorites: resp.favorites ?? false,
                                   rec: resp.rec ?? false)
            
            cameras.append(item)
        })
        
        self.cameras = CameraDataModel(room: responseData.room ?? [],
                                        cameras: cameras)
        
        camerasWorker(cameras: self.cameras!)
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func presentDoors(response: GetDoorsResponse) {
        doors.removeAll()
        
        let _ = response.data.map { door in
            let item = DoorsDataModel(id: door?.id ?? 0,
                                      name: door?.name ?? "",
                                      room: door?.room ?? "",
                                      favorites: door?.favorites ?? false,
                                      snapshot: door?.snapshot)
            
            doors.append(item)
        }
        
        if segmentControl.selectedSegmentIndex == 1 {
            tableView.reloadData()
        }
        doorsWorker(doors: doors)
        
        refreshControl.endRefreshing()
    }
    
    private func presentCamerasRM(cameras: [CamerasRM]) {
        guard let camera = cameras.first else { return }
        
        var cameras: [CameraModel] = []
        
        guard let data = camera.data.first else { return }
        
        let _ = Array(data.cameras).map({ resp in
            
            let item = CameraModel(id: resp.id,
                                   name: resp.name,
                                   snapshot: resp.snapshot,
                                   room: resp.room,
                                   favorites: resp.favorites,
                                   rec: resp.rec)

            cameras.append(item)
        })
        
        self.cameras = CameraDataModel(room: Array(data.room),
                                        cameras: cameras)
        
        tableView.reloadData()
    }
    
    private func presentDoorsRM(doors: [DoorsRM]) {
        guard let door = doors.first else { return }
        
        let _ = Array(door.data).map { doorRM in
            let item = DoorsDataModel(id: doorRM.id,
                                      name: doorRM.name,
                                      room: doorRM.room,
                                      favorites: doorRM.favorites,
                                      snapshot: doorRM.snapshot)

            self.doors.append(item)
        }
        
        tableView.reloadData()
    }
}

// MARK: - Workers methods
extension MainViewController {
    private func camerasWorker(cameras: CameraDataModel) {
        realm.cascadeDelete(CamerasRM.self)
        
        let roomRM = List<String>()
        let _ = cameras.room.map { room in
            roomRM.append(room)
        }
        
        let camerasRM = List<CamerasStructRM>()
        let _ = cameras.cameras.map { CameraModel in
            let item = CamerasStructRM(id: CameraModel.id,
                                       name: CameraModel.name,
                                       snapshot: CameraModel.snapshot,
                                       room: CameraModel.room,
                                       favorites: CameraModel.favorites,
                                       rec: CameraModel.rec)
            
            camerasRM.append(item)
        }
        
        let data = List<CamerasDataRM>()
        data.append(CamerasDataRM(room: roomRM, cameras: camerasRM))
        
        let item = CamerasRM(data: data)
        print(item)
        realm.create(item)
    }
    
    private func doorsWorker(doors: [DoorsDataModel]) {
        realm.cascadeDelete(DoorsRM.self)
        
        let doorsRM = List<DoorsDataRM>()
        
        let _ = doors.map { (door) in
            
            print("3213123312312312")
            
            let item = DoorsDataRM(id: door.id,
                                   name: door.name,
                                   room: door.room,
                                   favorites: door.favorites,
                                   snapshot: door.snapshot ?? "")
            
            doorsRM.append(item)
            
        }
        
        let item = DoorsRM(data: doorsRM)
        print(item)
        realm.create(item)
    }
}

// MARK: - Public methods
extension MainViewController {
    
}
