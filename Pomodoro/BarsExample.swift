//
//  BarsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts




struct ExamplesDefaults {
    
    static var chartSettings: ChartSettings {
        return self.iPhoneChartSettings
    }
    
    private static var iPhoneChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        return chartSettings
    }

}
    

// This example uses a normal view generator to create bars. This allows a high degree of customization at view level, since any UIView can be used.
// Alternatively it's possible to use ChartBarsLayer (see e.g. implementation of BarsChart for a simple example), which provides more ready to use, bar-specific functionality, but is accordingly more constrained.
class BarsExample: UIViewController {
    private var chart: Chart?
    var tuplesXY:[(Int,Int)]!
    var max:Int=0
    var numofPomodoro:Int=0
    
    @IBOutlet weak var StartDate: UILabel!
    
    @IBOutlet weak var EndDate: UILabel!
    @IBOutlet weak var numPomodoro: UILabel!
    let sideSelectorHeight: CGFloat = 50
    
    private func barsChart(horizontal horizontal: Bool) -> Chart {
       // tuplesXY = [(1, 8), (2, 9), (3, 10), (4, 8), (5, 17),(6, 5),(7, 7)]

        func reverseTuples(tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        
        let chartPoints = (horizontal ? reverseTuples(tuplesXY) : tuplesXY).map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: UIFont(name: "Helvetica", size: 11)!)
        
        
        let (axisValues1, axisValues2) = (
            0.stride(through: max+2, by: 2).map {ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings)},
            0.stride(through: 7, by: 1).map {ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings)}
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Day", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Pomodoro", settings: labelSettings.defaultVertical()))
        
        let barViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            
            let barWidth: CGFloat =  30
            
            let (p1, p2): (CGPoint, CGPoint) = {
                if horizontal {
                    return (CGPointMake(bottomLeft.x, chartPointModel.screenLoc.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                } else {
                    return (CGPointMake(chartPointModel.screenLoc.x, bottomLeft.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                }
            }()
            return ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: UIColor.blueColor().colorWithAlphaComponent(0.6))
        }
        
        let frame = CGRectMake(0, 300, 320, 300)
        
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - sideSelectorHeight)
      //  let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: 0.1)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer]
        )
    }
    
    private func showChart(horizontal horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = self.barsChart(horizontal: horizontal)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart(horizontal: false)
        title="Pass 7 Days Statistic"
        
        EndDate.text = NSDate().toMediumDateString()
        StartDate.text = (NSDate()-7.days).toMediumDateString()
        numPomodoro.text="\(numofPomodoro)"
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController!.navigationBar.hidden = false
        
        
    }
    
   
}




