//
//  ECJetDataStructures.swift
//  
//
//  Created by Daniel Pink on 7/7/2023.
//

import Foundation

enum ValueError: Error {
    case encodingValueError
    case setTriggerRepeatError
    case incorrectNumberOfBytesError
}

// https://oleb.net/blog/2018/03/making-illegal-states-unrepresentable/

typealias ThreeUInt8 = (UInt8, UInt8, UInt8)

// MARK: Get Print Width 0x02
public struct PrintWidth: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8)
    
    public var tuple: (UInt8, UInt8, UInt8) { return data }
    public var bytes: [UInt8] { return [data.0, data.1, data.2] }
    public var mm: Double { return (0.256 * Double(data.1)) + (0.001 * Double(data.0)) }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 3 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2])
    }
    
    public init(tuple: (UInt8, UInt8, UInt8)) {
        // Needs to only accept three bytes
        self.data = tuple
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        precondition(value < (256 * 0.256), "encodePrintWidth value (\(value)) is too large")
        let q1 = (value / 0.256).rounded(.towardZero)
        let r = value.truncatingRemainder(dividingBy: 0.256)
        let q2 = (r / 0.001).rounded(.toNearestOrAwayFromZero)
        //print("\(value),\(q1),\(r),\(q2)")
        //self.data = [UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1]
        self.data = (UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Delay 0x04
public struct PrintDelay: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public var bytes: [UInt8] { return [data.0, data.1, data.2, data.3, data.4] }
    public var mm: Double {
        let value: Double = (16777.216 * Double(self.data.3))
                             + (65.536 * Double(self.data.2))
                              + (0.256 * Double(self.data.1))
                              + (0.001 * Double(self.data.0))
        return value
    }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4])
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        self.data = (UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Interval 0x06
public struct PrintInterval: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8, UInt8, UInt8)
    public var bytes: [UInt8] { return [data.0, data.1, data.2, data.3, data.4] }
    public var mm: Double {
        let value: Double = (16777.216 * Double(self.data.3))
                             + (65.536 * Double(self.data.2))
                              + (0.256 * Double(self.data.1))
                              + (0.001 * Double(self.data.0))
        return value
    }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4])
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        self.data = (UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Height 0x08
public struct PrintHeight: CustomStringConvertible {
    private let data: UInt8
    public var bytes: [UInt8] { return [data] }
    public var mm: Double { return Double(self.data) } // TODO: Probably a scaling factor
    public var description: String { return "\(String(format: "%.2f", self.mm))mm" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        self.data = bytes[0]
    }
    
    public init(mm value: Double) throws {
        self.data = UInt8(value) // TODO: Scaling and/or rounding likely required
    }
}

// MARK: Get Print Count 0x0A
// The 5-byte data structure is as follows:
// [CountType] 1 byte count type
//      - 0 represents the total print count of the printhead
//      - 1 represents the printing data printing count
//      - 2 represents editing data printing count
// [PrintCount] 4 bytes print count value
// TODO: PrintCount structure doesn't handle getPrintCount data
public struct PrintCount: CustomStringConvertible {
    
    public enum CountType: UInt8 {
        case total = 0
        case printingData = 1
        case editingData = 2
    }
    public let type: CountType?
    public let count: UInt32
    //public var setBytes: [UInt8] { [UInt8(type.rawValue)] + count.bytes }
    //public var getBytes: [UInt8] { count.bytes } // This will never be used
    public var bytes: [UInt8] {
        if let ct = type {
            return [UInt8(ct.rawValue)] + count.bytes
        } else {
            return count.bytes
        }
    }
    
    public var description: String { "\(String(describing: self.type)):\(self.count)"}
    
    public init(bytes: [UInt8]) throws {
        switch bytes.count {
        case 5:
            if let type = CountType(rawValue: bytes[0]) {
                self.type = type
                self.count = UInt32(bytes[1])
                + (UInt32(bytes[2]) << 8)
                + (UInt32(bytes[3]) << 16)
                + (UInt32(bytes[4]) << 24)
            } else {
                throw ValueError.encodingValueError
            }
        case 4:
            self.type = nil
            self.count = UInt32(bytes[0])
            + (UInt32(bytes[1]) << 8)
            + (UInt32(bytes[2]) << 16)
            + (UInt32(bytes[3]) << 24)
        default:
            throw ValueError.incorrectNumberOfBytesError
        }
        
    }
    
    public init(type: CountType, bytes: [UInt8]) throws {
        if bytes.count != 4 { throw ValueError.incorrectNumberOfBytesError }
        self.count = UInt32(bytes: bytes)
        self.type = type
    }
    
    public init(type: CountType, count: UInt32) {
        self.type = type
        self.count = count
    }
}

// MARK: Set Reverse Message 0x0B
public struct ReverseMessage: Equatable, CustomStringConvertible {
    public enum Orientation {
        case normal
        case flipped
        
        public func isNormal() -> Bool {
            switch self {
            case .normal:
                return true
            case .flipped:
                return false
            }
        }
        public func isFlipped() -> Bool {
            switch self {
            case .normal:
                return false
            case .flipped:
                return true
            }
        }
    }
    
    public let horizontal: Orientation
    public let vertical: Orientation
    
    public var bytes: [UInt8] { return [horizontal.isNormal() ? 0 : 1, vertical.isNormal() ? 0 : 1] }
    public var description: String { return "\(horizontal.isNormal() ? "➡️" : "⬅️")\(vertical.isNormal() ? "⬆️" : "⬇️")"}
    
    public init(horizontal: Orientation, vertical: Orientation) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public init(horizontalFlipped: Bool, verticalFlipped: Bool) {
        self.horizontal = horizontalFlipped ? .flipped : .normal
        self.vertical = verticalFlipped ? .flipped : .normal
    }
    
    public init(flipped: Bool) {
        self.horizontal = flipped ? .normal : .flipped
        self.vertical = flipped ? .flipped : .normal
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 2 { throw ValueError.incorrectNumberOfBytesError }
        switch bytes[0] {
        case 0:
            self.horizontal = .normal
        case 1:
            self.horizontal = .flipped
        default:
            throw ValueError.encodingValueError
        }
        
        switch bytes[1] {
        case 0:
            self.vertical = .normal
        case 1:
            self.vertical = .flipped
        default:
            throw ValueError.encodingValueError
        }
    }
    
    public func toggle() -> ReverseMessage {
        return ReverseMessage(horizontal: self.horizontal.isFlipped() ? .normal : .flipped,
                              vertical: self.vertical.isFlipped() ? .normal : .flipped)
    }
}

// MARK: Get Trigger Repeat 0x0E
// 1 byte Trigger repetition number (minimum 1)
public struct TriggerRepeat: CustomStringConvertible {
    public let count: UInt8
    public var bytes: [UInt8] { return [count] }
    public var description: String { return "\(count)" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        if bytes[0] < 1 { throw ValueError.encodingValueError }
        self.count = bytes[0]
    }
    public init(count: UInt8) {
        self.count = count
    }
}

// MARK: Get Printer Status 0x0F
// The 5-byte data structure is as follows:
// [Working Status] 1 byte
//      - 1 jet stop
//      - 2 jet start
//      - 4 printing
// [Warning Status] 4 bytes Warning message
// 4 bytes total 32 bits, from 0 to 31 bits for warning messages 3.00 to 3.31 respectively
// For example,
// - 0001h means there is a warning message 3.00
// - 0002h indicates that there is a warning message 3.01
// - 0003h indicates that there are warning messages 3.00 and 3.01

public enum Warning: UInt32, Identifiable {
    //public var id: ObjectIdentifier
    public var id: Self { return self }
    
    case noVODAdjustments
    case jetShutDownIncomplete
    case overSpeedPrintGo
    case inkLow
    case solventLow
    case printGoRemoteData
    case serviceTime
    case printHeadCoverOff
    case printHeadNotFitted
    case newPrintHeadFitted
    case chargeCalibrationRange
    case safetyOverrideDetected
    case lowPressure
    case modulation
    case overSpeedVariableData
    
    struct WarningInformation {
        let name: String
        let code: String
        let explanation: String
        let possibleCauses: [String]
    }
    
    static let definition: [Warning: WarningInformation] =
    [.noVODAdjustments: WarningInformation(name: "No VOD Adjustments",
                                           code: "3.00",
                                           explanation: "This warning can occur when the jet is being started, or when the jet has been running for some time.",
                                           possibleCauses: ["Printhead code values are set incorrectly. Check the Printhead and Modulation values printed on the print head serial number label found on the conduit, with the stored values. (see “hanging the System Setup”)", "Ink viscosity is excessively out of range. Allow the printer to run to bring the viscosity back into range.", "There is a pressure loss in the system. Contact your local EC-JET distributor."]),
     .jetShutDownIncomplete: WarningInformation(name: "Jet Shut Down Incomplete",
                                                code: "3.01",
                                                explanation: "This indicates that the printer was previously switched off while the jet was running or before the printer had completed the shutdown routine. Completion of the shutdown routine is important. EC2000 has the function of automatic outage. The user just need to select “Yes” when “automatic outage” pop up on the screen. The printer will automatically cut off the power after the shutdown delay procedure when the shutdown routine finished. It’s no need to cut off the power manually. The warning does not stop the printer from functioning. If the last time shutdown routine is not executed completely, the warning will appear. The warning will disappear after a complete shutdown routine is finished.",
                                                possibleCauses: ["The printer was previously switched off while the jet was running or before the printer had completed the shutdown routine"]),
     .overSpeedPrintGo: WarningInformation(name: "Over Speed (Print Go)",
                                           code: "3.02",
                                           explanation: "This indicated that the printer may have missed printing at least one pattern or is receiving false triggers from the photocell. When the Photocell Mode is set to Trigger, each print delay is started following the photocell trigger. At the end of the delay a “print go” is issued to start printing. If the printer has not printed the last pattern by this time, the warning is reported and the new pattern is not printed. In effect, this will mean that alternate objects will NOT be printed on. The warning applies to the current printing is reset automatically when printing is restarted.",
                                           possibleCauses: ["The next object has arrived at the print head before the last pattern is complete because: 1. The line speed is too fast. 2. The pattern is too long compared to size of the objects to be printed on.", "The photocell is giving false triggers."]),
     .inkLow: WarningInformation(name: "Ink Low",
                                 code: "3.03",
                                 explanation: "If the ink level sensor indicates that the ink reservoir is low then this warning is given. It is cleared automatically when a sufficient amount of ink is added. Do NOT put in more than one bottle(500ml) each time. If the ink low condition is detected before the jet is started, then the jet cannot be started until the ink tank is replenished. If the condition is detected while the jet is running, the jet will continue to run for several hours until the ink is dangerously low, at which point a failure will occur (see Print Failure “2.06”). NOTE: Please operate according to chapter “8.2 Replenishing Ink and Solvent” of the manual.",
                                 possibleCauses: []),
     .solventLow: WarningInformation(name: "Solvent Low",
                                     code: "3.04",
                                     explanation: "If the solvent level sensor indicates that the solvent reservoir is low, then this warning is given. It is cleared automatically when a sufficient amount of solvent is added to the reservoir. Do NOT put in more than one bottle (500ml) each time. If the solvent low condition is detected before the jet is started, then the jet cannot be started until the solvent tank is replenished. If the condition is detected while the jet is running, the jet will continue to run regardless, but no attempt will be made to add solvent. NOTE: Please operate according to chapter “8.2 Replenishing Ink and Solvent” of the manual.",
                                     possibleCauses: []),
     .printGoRemoteData: WarningInformation(name: "Print Go / Remote Data",
                                            code: "3.05",
                                            explanation: "A “print go” has occurred and printing data has not been received from the remote interface. Make sure the transmission cable and the port are right setting.",
                                            possibleCauses: []),
     .serviceTime: WarningInformation(name: "Service Time",
                                      code: "3.06",
                                      explanation: "When the jet is started, the time remaining to the next service is checked. If it exceeds 4000 hours then this warning is reported and the jet is started as normal. This warning will be reported on every jet start up until the service time has been reset. Maintenance should be made when there is warning, otherwise it will affect the machine performance and stability.",
                                      possibleCauses: []),
     .printHeadCoverOff: WarningInformation(name: "Print Head Cover Off",
                                            code: "3.07",
                                            explanation: "This warning is reported if the print head cover is removed. The supply to the EHT plates is switched off (by hardware) when the cover is removed. WARNING: THERE IS A LINK WHICH, WHEN FITTED, DISABLES THIS AUTOMATIC SHUT OFF. THEREFORE, THE PRESENCE OF THIS WARNING IS NOT A GUARANTEE THAT THE EHT IS OFF. Printing is suspended when the cover is removed and is resumed a few seconds after the cover is refitted. The warning supplies to the currently printing pattern - it is reset automatically when printing is restarted.",
                                            possibleCauses: []),
     .printHeadNotFitted: WarningInformation(name: "Print Head Not Fitted",
                                             code: "3.08",
                                             explanation: "At start up the software checks the type of print of print head that is fitted. If it does not recognize the print head type this warning is reported. The system will continue to operate on the assumption that the print head has not been changed, and will continue with the same print head type as used previously (i.e. the currently stored NVR print head type). If a new type of print head has been fitted, but has not been detected correctly, the modulation frequency, voltage, etc., will all be incorrect. Therefore, the jet will not break up properly, and a phase fault (2.02) will probably occur when starting the jet.",
                                             possibleCauses: []),
     .newPrintHeadFitted: WarningInformation(name: "New Print Head Fitted",
                                             code: "3.09",
                                             explanation: "At start up the software checks the type of print head fitted. The last print head type used is stored in the printer is memory.If the currently fitted type is not the same as the type stored in memory then this error is reported and the type in memory is updated. This warning should only ever occur when a new print head is fitted. If it occurs at other times then the memory may be corrupt, or the print head connector faulty. Under normal circumstances this warning just confirms that the print head type has been changed. The defaults for VOD, modulation, etc., will be used, until the user enters a new print head code in the SETUP menu. If the wrong type of print head has been detected for any reason, the modulation frequency, voltage, etc. will all be incorrect. Therefore, the jet will not break up properly, and a phase fault (2.02) may occur when starting the jet, or poor print quality may result.",
                                             possibleCauses: []),
     .chargeCalibrationRange: WarningInformation(name: "Charge Calibration Range",
                                                 code: "3.10",
                                                 explanation: "Contact your local EC-JET distributor if this error is reported.",
                                                 possibleCauses: []),
     .safetyOverrideDetected: WarningInformation(name: "Safety Override Detected",
                                                 code: "3.11",
                                                 explanation: "This warning message alters the user when the safety override link is fitted. WARNING: DO NOT START THE PRINTER WHEN THIS ERROR MESSAGE IS PRESENT. PRINTER SAFETY CIRCUITS AND SENSORS WILL NOT BE FUNCTIONING. IN THE EVENT OF THIS ERROR MESSAGE OCCURRING, SWITCH OFF THE PRINTER AND CONTACT YOUR LOCAL EC-JET DISTRIBUTOR IMMEDIATELY.",
                                                 possibleCauses: []),
     .lowPressure: WarningInformation(name: "Low Pressure",
                                      code: "3.12",
                                      explanation: "When starting the jet the printer has detected a loss of ink pressure, which will affect the printer’s performance.",
                                      possibleCauses: ["The main ink filter is blocked.", "Pump output is low. (Contact your local EC-JET distributor.)"]),
     .modulation: WarningInformation(name: "Modulation",
                                     code: "3.13",
                                     explanation: "",
                                     possibleCauses: []),
     .overSpeedVariableData: WarningInformation(name: "Over Speed Variable Data",
                                                code: "3.14",
                                                explanation: "This indicates that the printer has missed at least one pattern because it cannot generate the pattern’s variable data (e.g. sequential numbers) at the required rate - i.e. the printer was still generating pixel data for the next “print go” when the “print go” occurred. The warning applies to the current pattern - it is reset automatically when printing is restarted. NOTE: This warning indicates the printer cannot generate pixels fast enough, whereas System Warning 3.02 indicates the printer cannot print the rasters fast enough.. This warning is only likely to occur for fast rasters (e.g. rasters smaller than 16 drops for Micro print head), where pixel generation by the software is slower than the rate at which the hardware can print rasters.",
                                                possibleCauses: ["The amount of variable data in the pattern is too long for the current rate of print triggers. Reduce the amount of variable data, if possible."])]
    
    public var name: String {
        return Warning.definition[self]!.name
    }
    
    public var code: String {
        return Warning.definition[self]!.code
    }
    
    public var explanation: String {
        return Warning.definition[self]!.explanation
    }
    
    public var possibleCauses: [String] {
        return Warning.definition[self]!.possibleCauses
    }
    
    public static func from(status: UInt32) -> Set<Warning> {
        var result: Set<Warning> = []
        
        var mask: UInt32 = 1
        for i in 0..<32 {
            if status & mask != 0 {
                if let warning = Warning(rawValue: UInt32(i)) {
                    result.insert(warning)
                }
            }
            mask <<= 1
        }
        return result
    }
    
    public static func status(from warnings: Set<Warning>) -> UInt32 {
        var result: UInt32 = 0
        
        for warning in warnings {
            result |= (1 << warning.rawValue)
        }
        
        return result
    }
}

public struct PrinterStatus: CustomStringConvertible {
    
    public enum WorkingStatus: UInt8 {
        case jetStop = 1
        case jetStart = 2
        case printing = 4
        
        func description() -> String {
            switch self {
            case .jetStop:
                return "Jet Stopped"
            case .jetStart:
                return "Jet Started"
            case .printing:
                return "Printing"
            }
        }
    }
    
    public let status: WorkingStatus
    public let warningStatus: UInt32
    //public let warnings: [Warning]
    
    public var bytes: [UInt8] { [status.rawValue] + warningStatus.bytes }
    
    public var description: String { return "\(self.status.description()), \(warningStatus)" } // TODO: warningStatus in human readable form.
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        if let status = WorkingStatus(rawValue: UInt8(bytes[0])) {
            self.status = status
            self.warningStatus = UInt32(bytes:[UInt8](bytes[1...4]))
        } else {
            throw ValueError.encodingValueError
        }
    }
    
    public init(status: WorkingStatus, bytes: [UInt8]) throws {
        if bytes.count != 4 { throw ValueError.incorrectNumberOfBytesError }
        self.warningStatus = UInt32(bytes: bytes)
        self.status = status
    }
}

// MARK: Get Print Head Code 0x11
// 14 bytes print head code ASCII value For example, the print head code is
// "12108010001701"
// The data is 31h 32h 31h 30h 38h 30h 31h 30h 30h 30h 31h 37h 30h 31h

public struct PrintHeadCode: CustomStringConvertible {
    public let code: String
    public var description: String { return "\(self.code)" }
    public var bytes: [UInt8] { return self.code.asciiValues }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 14 { throw ValueError.incorrectNumberOfBytesError }
        if let string = String(bytes: bytes, encoding: .utf8) {
            self.code = string
        } else {
            throw ValueError.encodingValueError
        }
    }
    public init(code: String) {
        self.code = code
    }
}

// MARK: Get Photocell Mode 0x13
// 1byte
//      - 0 interior trigger
//      - 1 photocell edge trigger
//      - 2 photocell level trigger
//      - 3 remote
public struct PhotocellMode: CustomStringConvertible {
    public enum Mode: UInt8, CustomStringConvertible {
        case interiorTrigger = 0
        case edgeTrigger = 1
        case levelTrigger = 2
        case remote = 3
        
        public var description: String {
            switch self {
            case .interiorTrigger:
                return "Interior Trigger"
            case .edgeTrigger:
                return "Edge Trigger"
            case .levelTrigger:
                return "Level Trigger"
            case .remote:
                return "Remote"
            }
        }
    }
    
    public let mode: Mode
    public var description: String { return self.mode.description }
    public var bytes: [UInt8] { return [UInt8(self.mode.rawValue)] }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        if let m = Mode(rawValue: bytes[0]) {
            self.mode = m
        } else {
            throw ValueError.encodingValueError
        }
    }
    public init(mode: Mode) {
        self.mode = mode
    }
}

// MARK: Get Jet Status 0x14
// The 10 bytes of data structure are as follows:
// [RefPress] 1 byte Reference pressure
// [Press] 1 byte Set pressure
// [ReadPress] 1 byte read pressure
// [SolventAddtion] 1 byte Solvent addition pressure
// [Modulation] 1 byte modulation
// [Phase] 1 byte Phase
// [RefVOD] 2 bytes reference ink speed
// [VOD] 2 bytes ink speed

public struct JetStatus: CustomStringConvertible {
    public let referencePressure: UInt8
    public let setPressure: UInt8
    public let readPressure: UInt8
    public let solventAddition: UInt8
    public let modulation: UInt8
    public let phase: UInt8
    public let referenceInkSpeed: UInt16
    public let inkSpeed: UInt16
    
    public var bytes: [UInt8] { [referencePressure,
                                 setPressure,
                                 readPressure,
                                 solventAddition,
                                 modulation,
                                 phase,
                                 referenceInkSpeed.lowerByte,
                                 referenceInkSpeed.upperByte,
                                 inkSpeed.lowerByte,
                                 inkSpeed.upperByte] }
    
    public var description: String { return "{refp:\(referencePressure),sp:\(setPressure),rp:\(readPressure),sa:\(solventAddition),m:\(modulation),ph:\(phase),ris:\(referenceInkSpeed),is:\(inkSpeed)}" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 10 { throw ValueError.incorrectNumberOfBytesError }
        self.referencePressure = bytes[0]
        self.setPressure = bytes[1]
        self.readPressure = bytes[2]
        self.solventAddition = bytes[3]
        self.modulation = bytes[4]
        self.phase = bytes[5]
        self.referenceInkSpeed = UInt16(upper: bytes[7], lower: bytes[6])
        self.inkSpeed = UInt16(upper: bytes[9], lower: bytes[8])
    }
}

// MARK: Get System Times 0x15
// 32 bytes of data structure are as follows
// [PowerOnHour] 4 bytes Boot hours
// [PowerOnMinute] 4 bytes Power on minutes
// [JetRunningHour] 4 bytes Jet running hours
// [JetRunningMinute] 4 bytes Jet running minutes
// [FilterChangeHour] 4 bytes Main filter replacement remaining hours
// [FilterChangeMinute] 4 bytes Main filter replacement remaining minutes
// [ServiceHour] 4 bytes Service time remaining hours
// [ServiceMinue] 4 bytes Service time remaining minutes

public struct SystemTimes: CustomStringConvertible {
    public var description: String { "on:\(poweredOn),running:\(jetRunning),filter:\(filterChangeRemaining),service:\(serviceHoursRemaining)" }
    
    public let poweredOn: ServiceTime
    public let jetRunning: ServiceTime
    public let filterChangeRemaining: ServiceTime
    public let serviceHoursRemaining: ServiceTime
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 32 { throw ValueError.incorrectNumberOfBytesError }
        self.poweredOn = try ServiceTime(bytes: [UInt8](bytes[0...7]))
        self.jetRunning = try ServiceTime(bytes: [UInt8](bytes[8...15]))
        self.filterChangeRemaining = try ServiceTime(bytes: [UInt8](bytes[16...23]))
        self.serviceHoursRemaining = try ServiceTime(bytes: [UInt8](bytes[24...31]))
    }
}

public struct ServiceTime: CustomStringConvertible, Equatable {
    public let hours: UInt32
    public let minutes: UInt32
    
    public var description: String { return "\(hours)hr \(minutes)min"}
    public var totalHours: Double { return Double(self.hours) + (Double(self.minutes) / 60) }
    public var totalMinutes: Int { return (Int(self.hours) * 60) + Int(self.minutes) }
    public var totalSeconds: Int { return self.totalMinutes * 60 }
    
    @available(iOS 16, macOS 13.0, *)
    public var duration: Duration { return Duration.seconds(self.totalSeconds) }
    
    public init(hours: UInt32, minutes: UInt32) {
        self.hours = hours
        self.minutes = minutes
    }
    
    public init(h: UInt32, m: UInt32) {
        self = ServiceTime(hours: h, minutes: m)
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 8 { throw ValueError.incorrectNumberOfBytesError }
        self.hours = UInt32(bytes[0])
        + (UInt32(bytes[1]) << 8)
        + (UInt32(bytes[2]) << 16)
        + (UInt32(bytes[3]) << 24)
        self.minutes = UInt32(bytes[4])
        + (UInt32(bytes[5]) << 8)
        + (UInt32(bytes[6]) << 16)
        + (UInt32(bytes[7]) << 24)
    }
}

// MARK: Get Date Time 0x1C
// 20bytes format is “yyyy.MM.dd-hh:mm:ss” for example “2017.06.30-17:30:00”
public struct DateTime {
    public let date: Date
    
    public var bytes: [UInt8] { return [UInt8](self.dateString.utf8) + [0] }
    public var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd-HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "AEST")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self.date)
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 20 { throw ValueError.incorrectNumberOfBytesError }
        let byteString = [UInt8](bytes[0..<19]) // Removes the null termination
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd-HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "AEST")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let dateString = String(bytes: byteString, encoding: .utf8), let d = formatter.date(from: dateString) {
            print(dateString)
            self.date = d
        } else {
            throw ValueError.encodingValueError
        }
    }
    
    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int) throws {
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.timeZone = TimeZone(identifier: "AEST")
        
        if let d = calendar.date(from: dateComponents) {
            self.date = d
        } else {
            throw ValueError.encodingValueError
        }
    }
}

// MARK: Get Font List 0x1D
// [FontCount] 1 byte Number of fonts
// [FontNameList] An array of font names, each font name occupies 16 bytes

public struct FontList {
    public let list: [String]
    
    public init(bytes: [UInt8]) throws {
        var buffer = bytes
        if bytes.count < 1 { throw ValueError.incorrectNumberOfBytesError }
        let fontListCount: UInt8 = bytes[0]
        print(bytes.count)
        print(((Int(fontListCount) * 16) + 1))
        if bytes.count != ((Int(fontListCount) * 16) + 1) { throw ValueError.incorrectNumberOfBytesError }
        buffer = [UInt8](buffer.dropFirst())
        let fontBytes = buffer.chunked(into: 16)
        precondition(fontBytes.count == fontListCount)
        
        let fontList = fontBytes.map{ bytes in
            var font = ""
            if let f = String(bytes: bytes, encoding: .utf8) {
                font = f.sanitized().whitespaceCondenced()
            }
            return font
        }
        self.list = fontList
    }
}

// MARK: Get Message List 0x1E
// [FileCount] 2 bytes Number of message
// [FilleNameList] array of file names, each file name occupies 32 bytes
public struct MessageList {
    public let list: [String]
    
    public init(bytes: [UInt8]) throws {
        var buffer = bytes
        let messageCount: UInt16 = UInt16(upper: buffer[1], lower: buffer[0])
        
        if bytes.count != ((messageCount * 32) + 2) { throw ValueError.incorrectNumberOfBytesError }
        buffer = [UInt8](buffer.dropFirst(2))
        
        let messageBytes = buffer.chunked(into: 32)
        if messageBytes.count != messageCount { throw ValueError.incorrectNumberOfBytesError }
        
        let messageList = messageBytes.map{ bytes in
            var message = ""
            if let m = String(bytes: bytes, encoding: .utf8) {
                message = m.sanitized().whitespaceCondenced()
            }
            return message
        }
        self.list = messageList
    }
}

// MARK: Download Remote Buffer 0x20
// TODO: Decode the return value from the DownloadRemoteBuffer command. According the the documentation this should simply be a single byte to indicate if the buffer is full or not. The function I have written below though indicates that there might be other data returned. Not sure if this is right or not, needs to be tested onsite.
public struct RemoteBuffer {
    public let buffer: String
    
    public init(bytes: [UInt8]) throws {
        if bytes.count < 3 { throw ValueError.incorrectNumberOfBytesError }
        
        let messageCount = UInt16(upper: bytes[1], lower: bytes[0])
        if bytes.count != messageCount + 2 { throw ValueError.incorrectNumberOfBytesError }
        
        if let m = String(bytes: bytes[2...], encoding: .utf8) {
            self.buffer = m
        } else {
            throw ValueError.encodingValueError
        }
    }
    
    public var bytes: [UInt8] {
        let data: [UInt8] = Array(buffer.utf8)
        let count: UInt16 = UInt16(data.count)
        return [count.lowerByte] + [count.upperByte] + data
    }
}



/*
public static func decodeDownloadRemoteBuffer(_ data: [UInt8]) -> String? {
    switch data.count {
    case 2:
        return ""
    case 0, 1:
        return nil
    default:
        //let count = UInt16(upper: data[1], lower: data[0])
        let bytes = [UInt8](data.dropFirst(2))
        return String(bytes: bytes, encoding: .utf8)
    }
}
*/

// MARK: Set Current Message 0x23

// MARK: Get AUX Mode 0x25
// [Mode] 1 byte.
// 0 Turn off the auxiliary eye function 1 serial number reset
// 2 horizontal reversal
// 3 vertical reversal
// 4 horizontal and vertical reversal


/*
// MARK: - Decoding data inside frames
// You should have a valid frame and know what type it is. Then you can use a function from here to
// reliably decode the data.


// MARK: Get AUX Mode 0x25
// MARK: Get Shaft Encoder Mode 0x27
// MARK: Get Reference Modulation 0x29

*/
