//
//  ComplicationController.swift
//  Cozie
//
//  Created by Federico Tartarini on 27/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import ClockKit
import WatchKit


class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Timeline Configuration

    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }

    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    // guide https://stackoverflow.com/questions/39708407/watchos3-complication-that-launches-app

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        if complication.family == .circularSmall
        {

            let template = CLKComplicationTemplateCircularSmallRingImage()
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            template.tintColor = .orange
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)

        } else if complication.family == .utilitarianSmall
        {

            let template = CLKComplicationTemplateUtilitarianSmallRingImage()
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template.tintColor = .orange
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)

        } else if complication.family == .modularSmall
        {

            let template = CLKComplicationTemplateModularSmallRingImage()
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            template.tintColor = .orange
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)

        } else if complication.family == .graphicCorner
        {

            if #available(watchOSApplicationExtension 5.0, *) {
                let template = CLKComplicationTemplateGraphicCornerCircularImage()
                let image = UIImage(named: "Complication/Graphic Corner")!
                template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
                template.tintColor = .orange
                let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(timelineEntry)
            } else {
                handler(nil)
            }

        } else if complication.family == .graphicCircular
        {

            if #available(watchOSApplicationExtension 5.0, *) {
                let template = CLKComplicationTemplateGraphicCircularImage()
                let image = UIImage(named: "Complication/Graphic Circular")!
                template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
                template.tintColor = .orange
                let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(timelineEntry)
            } else {
                handler(nil)
            }
            
        } else {

            handler(nil)

        }

    }

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }

    // MARK: - Placeholder Templates

    func getLocalizableSampleTemplate(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    {
        switch complication.family
        {
            case .circularSmall:
                let image: UIImage = UIImage(named: "Complication/Circular")!
                let template = CLKComplicationTemplateCircularSmallSimpleImage()
                template.imageProvider = CLKImageProvider(onePieceImage: image)
                template.tintColor = .orange
                handler(template)
            case .utilitarianSmall:
                let image: UIImage = UIImage(named: "Complication/Utilitarian")!
                let template = CLKComplicationTemplateUtilitarianSmallSquare()
                template.imageProvider = CLKImageProvider(onePieceImage: image)
                template.tintColor = .orange
                handler(template)
            case .modularSmall:
                let image: UIImage = UIImage(named: "Complication/Modular")!
                let template = CLKComplicationTemplateModularSmallSimpleImage()
                template.imageProvider = CLKImageProvider(onePieceImage: image)
                template.tintColor = .orange
                handler(template)
            case .graphicCorner:
                if #available(watchOSApplicationExtension 5.0, *) {
                    let template = CLKComplicationTemplateGraphicCornerCircularImage()
                    let image = UIImage(named: "Complication/Graphic Corner")!
                    template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
                    template.tintColor = .orange
                    handler(template)
                } else {
                    handler(nil)
                }
            case .graphicCircular:
                if #available(watchOSApplicationExtension 5.0, *) {
                    let template = CLKComplicationTemplateGraphicCircularImage()
                    let image = UIImage(named: "Complication/Graphic Circular")!
                    template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
                    template.tintColor = .orange
                    handler(template)
                } else {
                    handler(nil)
                }
            default:
                handler(nil)
        }
    }

}

