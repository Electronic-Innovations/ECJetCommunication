# ECJetCommunication

A Swift library for communicating with EC-JET2000 industrial inkjet printers using the EC-JET Communication Protocol v3.3. This library provides a type-safe, high-level API for creating and parsing communication frames, handling protocol details like CRC16 checksums, byte escaping, and data encoding/decoding.

## Features

- ✅ **Complete Protocol Support**: Implements all commands from EC-JET Communication Protocol v3.3
- ✅ **Type-Safe API**: Strongly typed enums and structs for commands and data structures
- ✅ **Frame Creation & Parsing**: Create frames from high-level types or parse raw byte arrays
- ✅ **Automatic CRC16 Validation**: Built-in CRC-16/X25 checksum calculation and verification
- ✅ **Byte Escaping**: Automatic handling of protocol byte escaping (0x7D, 0x7E, 0x7F)
- ✅ **Data Encoding/Decoding**: Helper functions for encoding/decoding print parameters (width, delay, interval, etc.)
- ✅ **Comprehensive Test Coverage**: Extensive test suite covering frame creation, parsing, and data structures

## Requirements

- Swift 5.8+
- macOS 10.15+ or iOS 13.0+
- No external dependencies

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/electronic-innovations/ECJetCommunication.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the version you want to use

## Quick Start

### Creating a Frame

```swift
import ECJetCommunication

// Create a simple command frame
let startPrintFrame = Frame(command: .startPrint)
let frameBytes = startPrintFrame.bytes  // [UInt8] ready to send

// Create a frame with data
let printHeight = try PrintHeight(value: 150)
let setHeightFrame = Frame(
    address: 0,
    command: .setPrintHeight,
    data: printHeight.bytes
)
```

### Parsing a Response Frame

```swift
// Parse a response from the printer
let responseBytes: [UInt8] = [0x7E, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x06, ...]
if let frame = Frame(bytes: responseBytes, verificationMethod: .crc16) {
    print("Command: \(frame.command)")
    print("Status: \(frame.information.acknowledge)")
    
    // Decode the response data
    if frame.command == .getPrintHeight {
        let height = try PrintHeight(bytes: frame.data)
        print("Print Height: \(height.value)")
    }
}
```

### Using Helper Functions

```swift
// Create frames using convenience methods
let getCountFrame = Frame.getPrintCount(countType: .editing)
let reverseFrame = Frame.setReverse(horizontal: true, vertical: false)
let remoteBufferFrame = Frame.downloadRemoteBuffer(address: 0, message: "Hello, World!")

// Encode/decode print parameters
let widthBytes = try Frame.encodePrintWidth(mm: 0.5)
let width = Frame.decodePrintWidth(data: widthBytes)
```

## Usage Examples

### Basic Communication Flow

```swift
import ECJetCommunication

// 1. Create a request frame
let requestFrame = Frame(command: .getPrintHeight)
let requestBytes = requestFrame.bytes

// 2. Send bytes to printer (via serial port, network, etc.)
// sendBytes(requestBytes)

// 3. Receive response bytes
// let responseBytes = receiveBytes()

// 4. Parse the response
if let responseFrame = Frame(bytes: responseBytes, verificationMethod: .crc16) {
    // Check if command was successful
    if responseFrame.information.acknowledge == .complete {
        // Decode the data
        if let height = try? PrintHeight(bytes: responseFrame.data) {
            print("Current print height: \(height.value)")
        }
    }
}
```

### Setting Print Parameters

```swift
// Set print width (in mm)
let width = try PrintWidth(mm: 0.5)
let setWidthFrame = Frame(
    command: .setPrintWidth,
    data: width.bytes
)

// Set print delay (in mm)
let delay = try PrintDelay(mm: 100.0)
let setDelayFrame = Frame(
    command: .setPrintDelay,
    data: delay.bytes
)

// Set print interval (in mm)
let interval = try PrintInterval(mm: 50.0)
let setIntervalFrame = Frame(
    command: .setPrintInterval,
    data: interval.bytes
)
```

### Working with Print Count

```swift
// Get print count for editing data
let getCountFrame = Frame.getPrintCount(countType: .editing)

// Parse response
if let responseFrame = Frame(bytes: responseBytes, verificationMethod: .crc16) {
    let count = Frame.decodePrintCount(responseFrame.data)
    print("Print count: \(count)")
}

// Set print count
let printCount = try PrintCount(type: .editingData, count: 100)
let setCountFrame = Frame(
    command: .setPrintCount,
    data: printCount.bytes
)
```

### Reading Printer Status

```swift
// Get printer status
let statusFrame = Frame(command: .getPrinterStatus)

// Parse response
if let responseFrame = Frame(bytes: responseBytes, verificationMethod: .crc16) {
    let status = try PrinterStatus(bytes: responseFrame.data)
    print("Working status: \(status.status)")
    
    // Parse warnings
    let warnings = Warning.from(status: status.warningStatus)
    for warning in warnings {
        print("Warning: \(warning.name) (\(warning.code))")
    }
}
```

## API Overview

### Core Types

#### `Frame`
The main structure representing a communication frame.

```swift
public struct Frame {
    public let address: UInt8
    public let command: Command
    public let information: CommandInformation
    public let data: [UInt8]
    public let verification: VerificationMode
    
    public var bytes: [UInt8]  // Serialized frame ready to send
}
```

#### `Command`
Enumeration of all supported protocol commands.

```swift
public enum Command: UInt16 {
    case startPrint = 0x0018
    case stopPrint = 0x0019
    case getPrintHeight = 0x0008
    case setPrintHeight = 0x0007
    // ... and many more
}
```

#### `CommandInformation`
Contains acknowledgment status and command execution information.

```swift
public struct CommandInformation {
    public let acknowledge: ReceptionStatus
    public let nr: UInt16
    public let devStatus: UInt16
    public let status: UInt16  // Command execution status
}
```

### Data Structures

The library provides strongly-typed data structures for protocol data:

- `PrintWidth` - Print width in millimeters
- `PrintDelay` - Print delay in millimeters  
- `PrintInterval` - Print interval in millimeters
- `PrintHeight` - Print height (110-230)
- `PrintCount` - Print count with type
- `ReverseMessage` - Message reversal settings
- `TriggerRepeat` - Trigger repeat count
- `PrinterStatus` - Printer working status and warnings
- `JetStatus` - Jet system status
- `SystemTimes` - System service times
- `DateTime` - Date/time information
- `FontList` - Available fonts
- `MessageList` - Available messages
- `RemoteBuffer` - Remote buffer data
- `RemoteBufferSize` - Remote buffer size

### Verification Modes

```swift
public enum VerificationMode {
    case none      // No checksum
    case mod256    // Mod256 checksum (1 byte)
    case crc16     // CRC-16/X25 checksum (2 bytes)
}
```

## Protocol Documentation

This library implements the **EC-JET Communication Protocol v3.3**. For detailed protocol specifications, see:

- `Documentation/Revised from Experience/EC-JET2000 communication protocol V3.3-EN.md` - Updated protocol documentation based on implementation experience
- `Documentation/Official/EC-JET2000 communication protocol V3.3-EN.md` - Original official protocol documentation

### Protocol Features

- **Frame Format**: `[STX][ADDR][CMD-ID][DAT-OFFSET][CMD-INF][DATA][CHECKSUM][ETX]`
- **Checksum**: Supports None, Mod256, or CRC-16/X25 verification
- **Byte Escaping**: Automatic escaping of 0x7D, 0x7E, 0x7F bytes
- **Little-Endian**: Multi-byte values transmitted low byte first

## Testing

The library includes comprehensive tests. Run them with:

```bash
swift test
```

Test coverage includes:
- Frame creation and parsing
- CRC16 checksum calculation
- Byte escaping/capture
- Data structure encoding/decoding
- All major protocol commands

## Architecture

The library is organized into several modules:

- **ECJetCommunication.swift**: Core frame structure, commands, and protocol framing
- **ECJetDataStructures.swift**: Type-safe data structures for protocol data
- **ECJetParser.swift**: Tokenizer for parsing multiple frames from byte streams
- **ECJetProtocolFramer.swift**: Network.framework protocol framer implementation
- **Extensions.swift**: Utility extensions for UInt16, UInt32, Array, String

## License

All Rights Reserved

Copyright (c) 2023 Electronic Innovations Pty. Ltd.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

