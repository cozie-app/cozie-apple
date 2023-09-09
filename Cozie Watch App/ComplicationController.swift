import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    private let complicationID = "Cozie_complication"
    private let displayName = "Cozie Dev"
    
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
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: complicationID, displayName: displayName,
                                      supportedFamilies: [CLKComplicationFamily.circularSmall,
                                                          CLKComplicationFamily.utilitarianSmall,
                                                          CLKComplicationFamily.modularSmall,
                                                          CLKComplicationFamily.graphicCorner,
                                                          CLKComplicationFamily.graphicCircular])]
        handler(descriptors)
    }


    // MARK: Timeline Population
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        getLocalizableSampleTemplate(for: complication) { template in
            guard let stemplate = template else {
                handler(nil)
                return
            }
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: stemplate)
            handler(timelineEntry)
        }
    }

    // MARK: Placeholder Templates
    func getLocalizableSampleTemplate(
            for complication: CLKComplication,
            withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .circularSmall:
            guard let image = UIImage(named: "CircleCompImage") else {
                handler(nil)
                return
            }
            let template = CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: image))
            handler(template)
        case .utilitarianSmall:
            guard let image = UIImage(named: "RectCompImage") else {
                handler(nil)
                return
            }
            let template = CLKComplicationTemplateUtilitarianSmallSquare(imageProvider: CLKImageProvider(onePieceImage: image))
            handler(template)
        case .modularSmall:
            guard let image = UIImage(named: "RectCompImage") else {
                handler(nil)
                return
            }
            let template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: image))
            handler(template)
        case .graphicCorner:
            if #available(watchOSApplicationExtension 5.0, *) {
                guard let image = UIImage(named: "CircleSmallCompImage") else {
                    handler(nil)
                    return
                }
                let template = CLKComplicationTemplateGraphicCornerCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: image))
                handler(template)
            } else {
                handler(nil)
            }
        case .graphicCircular:
            if #available(watchOSApplicationExtension 5.0, *) {
                guard let image = UIImage(named: "CircleCompImage") else {
                    handler(nil)
                    return
                }
                let template = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: image))
                handler(template)
            } else {
                handler(nil)
            }
        default:
            handler(nil)
        }
    }

}

