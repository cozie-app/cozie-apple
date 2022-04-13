//
//  DataViewController.swift
//  Cozie
//
//  Created by MAC on 22/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController, ChartViewDelegate{
    
    @IBOutlet weak var labelData: UILabel!
    @IBOutlet weak var graphView1: UIView!
    @IBOutlet weak var graphView2: UIView!
    @IBOutlet weak var dataDownloadView: UIView!
    
    private var dateValues = [String]()
    private let validResValues = ["Valid Responses", "Goal"]
    private var responseValues = [Double]()
    private var chart1: BarChartView?
    private var chart2: BarChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelData.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickDataDownloadView(_:)))
        dataDownloadView.addGestureRecognizer(tap)
        
        let barChartView1 = barChart()
        self.chart1 = barChartView1
        graphView1.addSubview(barChartView1)
        
        barChartView1.translatesAutoresizingMaskIntoConstraints = false
        barChartView1.leadingAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView1.trailingAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView1.topAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.topAnchor).isActive = true
        barChartView1.bottomAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let barChartView2 = barChart()
        self.chart2 = barChartView2
        graphView2.addSubview(barChartView2)
        
        barChartView2.translatesAutoresizingMaskIntoConstraints = false
        barChartView2.leadingAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView2.trailingAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView2.topAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.topAnchor).isActive = true
        barChartView2.bottomAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.bottomAnchor).isActive = true
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.getData { (isSuccess, data) in
            if isSuccess {
                self.reloadPage(forData: data)
            }
        }
    }
    
    private func setupUI() {
        
        dateValues.removeAll()
        responseValues.removeAll()
        let data = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.dayData.rawValue) as? [String: Int]
        if let data = data {
            let data1 = data.sorted{($0.key.date()) < ($1.key.date())}
            data1.forEach { (date,response) in
                dateValues.append(date)
                responseValues.append(Double(response))
            }
        }
        
        var yValues1:[BarChartDataEntry] = []
        for (index, value) in self.responseValues.enumerated() {
            yValues1.append(BarChartDataEntry(x: Double(index), y: value))
        }
        
        let yValues2:[BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue) as? Double ?? 0.0),
            BarChartDataEntry(x: 1, y: 20)
        ]
        
        self.setChartValue(values: yValues1,barChartView: self.chart1!)
        self.chart1?.xAxis.labelCount = self.dateValues.count
        self.chart1?.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.dateValues)
        self.setChartValue(values: yValues2, barChartView: self.chart2!)
        self.chart2?.xAxis.labelCount = self.validResValues.count
        self.chart2?.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.validResValues)
        if self.dateValues.count > 0 {
            self.chart1?.scaleYEnabled = false
            self.chart1?.isUserInteractionEnabled = true
            self.chart1?.setVisibleXRangeMaximum(4)
            self.chart1?.setVisibleXRangeMinimum(4)
            self.chart1?.moveViewToX(Double(self.dateValues.count))
        }
    }
    
    private func barChart() -> BarChartView{
        let chartView = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        let yAxis = chartView.rightAxis
        yAxis.drawAxisLineEnabled = false
        yAxis.labelTextColor = .lightGray
        yAxis.axisMinimum = 0.0
        
        let xAxis = chartView.xAxis
        xAxis.labelTextColor = .lightGray
        xAxis.labelPosition = .bottom
        xAxis.granularityEnabled = true
        xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0.0
        chartView.animate(yAxisDuration: 2.5)
        chartView.isUserInteractionEnabled = false
        return chartView
    }
    
    private func setChartValue(values: [BarChartDataEntry], barChartView: BarChartView){
        
        let set = BarChartDataSet(entries: values,label: "No. of responses")
        set.colors = [.systemRed]
        set.valueFont = .boldSystemFont(ofSize: 10)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        set.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        let data = BarChartData(dataSet: set)
        data.barWidth = 0.5
        barChartView.data = data
        barChartView.fitBars = true
        barChartView.legend.horizontalAlignment = . center
    }
    
    @objc func onClickDataDownloadView(_ :UITapGestureRecognizer ){
        let alert = UIAlertController(title: "Download Data", message: "Are you sure you want to download your data? This might take a few moments", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
            Utilities.downloadData(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension DataViewController {
    func reloadPage(forData: [Response]) {
        let actualResponse = forData.filter { $0.voteLog != nil }
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue, value: actualResponse.count)
        var dateData = [String: Int]()
        actualResponse.forEach { response in
            let date = Date(timeIntervalSince1970: TimeInterval(Int(response.timestamp ?? "") ?? 0) / 1000)
            if dateData[date.getDayString()] != nil {
                dateData[date.getDayString()]? += 1
            } else {
                dateData[date.getDayString()] = 1
            }
        }
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.dayData.rawValue, value: dateData)
        self.setupUI()
    }
}
