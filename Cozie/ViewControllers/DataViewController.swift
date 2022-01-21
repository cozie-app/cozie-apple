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
    var stringVal1 = ["02/12/2021", "03/12/2021", "04/12/2021"]
    let stringVal2 = ["Valid Responses", "Goal"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelData.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickDataDownloadView(_:)))
        dataDownloadView.addGestureRecognizer(tap)
        
        let barChartView1 = barChart()
        graphView1.addSubview(barChartView1)
        
        barChartView1.translatesAutoresizingMaskIntoConstraints = false
        barChartView1.leadingAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView1.trailingAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView1.topAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.topAnchor).isActive = true
        barChartView1.bottomAnchor.constraint(equalTo: self.graphView1.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let barChartView2 = barChart()
        graphView2.addSubview(barChartView2)
        
        barChartView2.translatesAutoresizingMaskIntoConstraints = false
        barChartView2.leadingAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.leadingAnchor).isActive = true
        barChartView2.trailingAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.trailingAnchor).isActive = true
        barChartView2.topAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.topAnchor).isActive = true
        barChartView2.bottomAnchor.constraint(equalTo: self.graphView2.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let yValues1:[BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: 9),
            BarChartDataEntry(x: 1, y: 6),
            BarChartDataEntry(x: 2, y: 12)
        ]
        
        let yValues2:[BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: 55),
            BarChartDataEntry(x: 1, y: 80)
        ]
        
        self.setChartValue(values: yValues1,barChartView: barChartView1)
        barChartView1.xAxis.labelCount = self.stringVal1.count
        barChartView1.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.stringVal1)
        self.setChartValue(values: yValues2, barChartView: barChartView2)
        barChartView2.xAxis.labelCount = self.stringVal2.count
        barChartView2.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.stringVal2)
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
            print("download")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
