//
//  NoiseMeterControlle.swift
//  Cozie
//
//  Created by Alexandr Chmal on 10.08.2022.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import Foundation
import AVFoundation

class NoiseMeterController {
    var timer: DispatchSourceTimer?
    
    func noiseMeshurnments() {
        let recordSettings = [
            AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
            AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32),
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = urls[0] as URL
            let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
            
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            let audioRecorder = try AVAudioRecorder(url: soundURL, settings: recordSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            try audioSession.setActive(true)
            audioRecorder.isMeteringEnabled = true
            recordForever(audioRecorder: audioRecorder)
        } catch let err {
            print("Unable start recording", err)
        }
    }
    
    func recordForever(audioRecorder: AVAudioRecorder) {
        let queue = DispatchQueue(label: "meter.decibel", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        timer?.setEventHandler { /*[weak self] in*/
            audioRecorder.updateMeters()

            let correction: Float = 100
            let average = audioRecorder.averagePower(forChannel: 0) + correction
            let peak = audioRecorder.peakPower(forChannel: 0) + correction
            print("average: \(average) ---- peak: \(peak)")
        }
        timer?.resume()
    }
}
