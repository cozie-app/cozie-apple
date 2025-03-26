//
//  TimeModelTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 05.01.25.
//
import Testing
@testable import Cozie

struct TimeModelTests {
    
    @Test
    func timeModelWithMinuteConvertToTimeInMinutes() async throws {
        let minute = 130
        
        let sut = TimeModel(minute: minute)
        
        #expect(sut.timeInMinutes() == minute)
        #expect(sut.formattedHourMinString() == "02:10")
    }
    
    @Test
    func timeModelWithMinute2ConvertToTimeInMinutes() async throws {
        let minute = 30
        
        let sut = TimeModel(minute: minute)
        
        #expect(sut.timeInMinutes() == minute)
        #expect(sut.formattedHourMinString() == "00:30")
    }
    
    @Test
    func timeModelWithHourAndMinuteConvertToTimeInMinutes() async throws {
        let hour = 12
        let minute = 30
        
        let sut = TimeModel(hour: hour, minute: minute)
        
        #expect(sut.timeInMinutes() == hour*60+minute)
    }
    
    @Test
    func timeModelWithHourAndMinuteConvertToFormattedMinString() async throws {
        let hour = 12
        let minute = 30
        
        let sut = TimeModel(hour: hour, minute: minute)
        
        #expect(sut.formattedMinString() == "\(hour*60+minute) min")
    }
    
    @Test
    func timeModelWithHourAndMinuteConvertToFormattedHourMinString() async throws {
        let sut1 = TimeModel(hour: 12, minute: 30)
        #expect(sut1.formattedHourMinString() == "12:30")
        
        let sut2 = TimeModel(hour: 1, minute: 30)
        #expect(sut2.formattedHourMinString() == "01:30")
        
        let sut3 = TimeModel(hour: 0, minute: 30)
        #expect(sut3.formattedHourMinString() == "00:30")
        
        let sut4 = TimeModel(hour: 23, minute: 59)
        #expect(sut4.formattedHourMinString() == "23:59")
    }
}
