//
// Created by Federico Tartarini on 9/7/20.
// Copyright (c) 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

public func consentPDFViewerTask() -> ORKOrderedTask{
    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
    docURL = docURL?.appendingPathComponent("consent.pdf")
    let PDFViewerStep = ORKPDFViewerStep.init(identifier: "ConsentPDFViewer", pdfURL: docURL)
    PDFViewerStep.title = "Consent"
    return ORKOrderedTask(identifier: String("ConsentPDF"), steps: [PDFViewerStep])
}