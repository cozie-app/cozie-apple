//
//  DataViewController.swift
//  Cozie
//
//  Created by MAC on 22/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController, ChartViewDelegate {

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
        labelData.layer.masksToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickDataDownloadView(_:)))
        dataDownloadView.addGestureRecognizer(tap)

        let barChartView1 = barChart()
        chart1 = barChartView1
        graphView1.addSubview(barChartView1)

        barChartView1.translatesAutoresizingMaskIntoConstraints = false
        barChartView1.leadingAnchor.constraint(equalTo: graphView1.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView1.trailingAnchor.constraint(equalTo: graphView1.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView1.topAnchor.constraint(equalTo: graphView1.layoutMarginsGuide.topAnchor).isActive = true
        barChartView1.bottomAnchor.constraint(equalTo: graphView1.layoutMarginsGuide.bottomAnchor).isActive = true

        let barChartView2 = barChart()
        chart2 = barChartView2
        graphView2.addSubview(barChartView2)

        barChartView2.translatesAutoresizingMaskIntoConstraints = false
        barChartView2.leadingAnchor.constraint(equalTo: graphView2.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView2.trailingAnchor.constraint(equalTo: graphView2.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView2.topAnchor.constraint(equalTo: graphView2.layoutMarginsGuide.topAnchor).isActive = true
        barChartView2.bottomAnchor.constraint(equalTo: graphView2.layoutMarginsGuide.bottomAnchor).isActive = true

        setupUI()
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
            let data1 = data.sorted {
                ($0.key.date()) < ($1.key.date())
            }
            data1.forEach { (date, response) in
                dateValues.append(date)
                responseValues.append(Double(response))
            }
        }

        var yValues1: [BarChartDataEntry] = []
        for (index, value) in responseValues.enumerated() {
            yValues1.append(BarChartDataEntry(x: Double(index), y: value))
        }

        let yValues2: [BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue) as? Double ?? 0.0),
            BarChartDataEntry(x: 1, y: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.studyGoal.rawValue) as? Double ?? 0.0)
        ]

        setChartValue(values: yValues1, barChartView: chart1!)
        chart1?.xAxis.labelCount = dateValues.count
        chart1?.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateValues)
        setChartValue(values: yValues2, barChartView: chart2!)
        chart2?.xAxis.labelCount = validResValues.count
        chart2?.xAxis.valueFormatter = IndexAxisValueFormatter(values: validResValues)
        if dateValues.count > 0 {
            chart1?.scaleYEnabled = false
            chart1?.isUserInteractionEnabled = true
            chart1?.setVisibleXRangeMaximum(4)
            chart1?.setVisibleXRangeMinimum(4)
            chart1?.moveViewToX(Double(dateValues.count))
        }
    }

    private func barChart() -> BarChartView {
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

    private func setChartValue(values: [BarChartDataEntry], barChartView: BarChartView) {

        let set = BarChartDataSet(entries: values, label: "No. of responses")
        set.colors = [.systemRed]
        set.valueFont = .boldSystemFont(ofSize: 10)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        set.valueFormatter = DefaultValueFormatter(formatter: formatter)

        let data = BarChartData(dataSet: set)
        data.barWidth = 0.5
        barChartView.data = data
        barChartView.fitBars = true
        barChartView.legend.horizontalAlignment = .center
    }

    @objc func onClickDataDownloadView(_: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Download Data", message: "Are you sure you want to download your data? This might take a few moments", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
            Utilities.downloadData(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DataViewController {
    func reloadPage(forData: [Response]) {
        let actualResponse = forData.filter {
            $0.vote_count != nil
        }
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
        setupUI()
    }
}
