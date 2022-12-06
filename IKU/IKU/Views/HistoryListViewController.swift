//
//  HistoryListViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/24.
//

import UIKit
import Combine

class HistoryListViewController: UIViewController {
    // MARK: - Properties
    private let cellIdentifier = "testLogContentTabelViewCell"
    private var tableView: UITableView = {
        var view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var originData: [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)] = []
    var showBookmark: Bool = false {
        didSet {
            let barButtonItemImage = UIImage(systemName: showBookmark ? "bookmark.fill" : "bookmark",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
            barButtonItem.image = barButtonItemImage
        }
    }
    var loadData: [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)] {
        originData.filter { !showBookmark || $0.measurementResult.isBookMarked }
    }
    var barButtonItem: UIBarButtonItem = UIBarButtonItem()
    
    // MARK: - Methods
    private func setupNavigationController() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        title = "List"
        
        let barButtonItemImage = UIImage(systemName: "bookmark",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
        barButtonItem = UIBarButtonItem(image: barButtonItemImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(filterBookmark(_:)))
        barButtonItem.tintColor = .black
        navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .ikuBackgroundBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorColor = .clear
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 2, right: 0)
        tableView.register(TestLogContentTabelViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func fetchData() {
        do {
            let persistenceManager = try PersistenceManager()
            originData = try persistenceManager.fetchVideo(.all)
            tableView.reloadData()
        } catch {
            showAlertController(title: "데이터 불러오기 실패", message: "검사 결과를 가져오는데 실패했습니다.", isAddCancelAction: false) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func goToResultView() {
        
    }
    
    @objc func filterBookmark(_ sender: UIBarButtonItem) {
        showBookmark = !showBookmark
        tableView.reloadData()
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ikuBackgroundBlue
        setupNavigationController()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
}

// MARK: - Delegates And DataSources
extension HistoryListViewController: UITableViewDelegate, UITableViewDataSource {
    // Header
    func numberOfSections(in tableView: UITableView) -> Int {
        Set(loadData.map {
            Calendar.current.component(.year, from: $0.measurementResult.creationDate)
        }).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2022"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .nexonGothicFont(ofSize: 20, weight: .bold)
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
        ])
        
        return view
    }
    
    // Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        TestLogContentTabelViewCell(style: .default, reuseIdentifier: cellIdentifier, data: loadData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellData = (tableView.cellForRow(at: indexPath) as? TestLogContentTabelViewCell)?.data {
            guard let resultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return
            }
            let datas = loadData.filter {
                let date = $0.measurementResult.creationDate
                let cellDate = cellData.measurementResult.creationDate
                return Calendar.current.compare(date, to: cellDate, toGranularity: .day) == .orderedSame
            }
            resultViewController.prepareData(data: datas, showedEye: cellData.measurementResult.isLeftEye ? .left : .right)
            resultViewController.root = .history_list
            navigationController?.pushViewController(resultViewController, animated: true)
        }
    }
}

// MARK: - TableView Cell
class TestLogContentTabelViewCell: UITableViewCell {
    // MARK: - ProPerties
    var data: (videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)?
    var anyCancellable = Set<AnyCancellable>()
    
    // MARK: - Methods
    private func setAttributeOfCell() {
        backgroundColor = .ikuBackgroundBlue
    }
    
    private func setAttributeOfView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ikuBackgroundBlue
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
        
        let stackView = createStackView()
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func createStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        
        let date = data?.measurementResult.creationDate ?? .now
        view.addArrangedSubview(createDateLabel(date: date))
        view.addArrangedSubview(createAngleView())
        
        return view
    }
    
    private func createDateLabel(date: Date) -> UILabel {
        let label = UILabel()
        let day = Calendar.current.component(.day, from: date)
        let month = DateFormatter().shortMonthSymbols[Calendar.current.component(.month, from: date) - 1].uppercased()
        label.text = "\(day) DAY\n\(month)"
        label.textColor = .ikuCalendarWeeklyTitle
        label.textAlignment = .center
        label.font = .nexonGothicFont(ofSize: 13)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 50)
        ])
        return label
    }
    
    private func createAngleView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass.circle"))
        icon.tintColor = .ikuBlue
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.font = .nexonGothicFont(ofSize: 13)
        label.attributedText = createText()
        label.textColor = .ikuCalendarWeeklyTitle
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2/3)
            label.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        view.addSubview(stackView)
        
        if data?.measurementResult.isBookMarked ?? false {
            let bookmarkView = UIView()
            bookmarkView.publisher(for: \.bounds, options: [.new, .initial, .old, .prior])
                .receive(on: DispatchQueue.main)
                .filter { trunc($0.width) == trunc($0.height) }
                .sink {
                    let path = UIBezierPath()
                    path.move(to: .init(x: 0, y: $0.width))
                    path.addLine(to: .init(x: $0.width, y: $0.width))
                    path.addLine(to: .init(x: $0.width, y: 0))
                    path.close()
                    
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.fillColor = UIColor.ikuBlue.cgColor
                    bookmarkView.layer.sublayers?.removeAll()
                    bookmarkView.layer.addSublayer(shapeLayer)
                }
                .store(in: &anyCancellable)
            bookmarkView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bookmarkView)
            NSLayoutConstraint.activate([
                bookmarkView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 14/49),
                bookmarkView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 14/49),
                bookmarkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bookmarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalTo: icon.widthAnchor),
            
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier:  0.9),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
        
        return view
    }
    
    private func createText() -> NSAttributedString {
        var text = ""
        var attributedStr = NSMutableAttributedString(string: "")
        
        guard let data else { return attributedStr }
        text += data.measurementResult.isLeftEye ? "Left Eye" : "Right Eye"
        
        let uncoverAngle = data.angles[data.measurementResult.timeOne] ?? 0.0
        let coverAngle = data.angles[data.measurementResult.timeTwo] ?? 0.0
        var resultAngle = abs(uncoverAngle - coverAngle)
        resultAngle = (resultAngle * 180 / .pi).roundSecondPoint
        text += ", Angle : \(resultAngle)º(\(resultAngle * 2)PD) "
        text += Int(resultAngle) <= 5 ? "" : "(Caution))"
        
        attributedStr = NSMutableAttributedString(string: text)
        attributedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (text as NSString).range(of: "º"))
        return attributedStr
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String? = nil, data: (videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)? = nil) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.data = data
        setAttributeOfCell()
        setAttributeOfView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0))
    }
}
