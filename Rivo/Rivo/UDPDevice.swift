//
//  protocol.swift
//  mac_protocol
//
//  Created by sunwoo Kim on 2021/11/07.
//

import Network
import Foundation
import IOKit
import CoreBluetooth




class UDPDevice : RivoDevice {
    
    var connection: CBPeripheral!
    var UUID_GATT_NUS_COMMAND_ENDPOINT: CBCharacteristic?
    var UUID_GATT_NUS_RESPONSE_ENDPOINT: CBCharacteristic?
    
    var ID: String = ""
    var isCheck: Bool = false
    var payloadlen = 0
    var temp : [UInt8] = []
    var payloadvalue : [UInt8] = []
    var totallen = 0
    
    override init() {

    }
    
    init(_ peripheral : CBPeripheral, _ commandCharacteristic : CBCharacteristic) {
        self.connection = peripheral
        self.UUID_GATT_NUS_COMMAND_ENDPOINT = commandCharacteristic
    }
    func setRead(datapath: CBCharacteristic){
        self.UUID_GATT_NUS_RESPONSE_ENDPOINT = datapath
    }

   
    // return type string ?
    override func write(cmd: String, data: [UInt8]) {
        /* Big endian
        var sendframe = ("AT"+cmd).utf8.map{ UInt8($0) } // convert string into byte array
        sendframe.append(UInt8(data.count>>8))
        sendframe.append(UInt8(data.count&0xff))
        sendframe.append(contentsOf: data)
        let crc = self.CRC16(data: data)
        sendframe.append(UInt8(crc>>8))
        sendframe.append(UInt8(crc&0xff))
        sendframe.append(0x0d)
        sendframe.append(0x0a)
        */
        
        //Little endian
        var sendframe = ("AT"+cmd).utf8.map{ UInt8($0) } // convert string into byte array
        sendframe.append(UInt8(data.count&0xff))
        sendframe.append(UInt8((data.count>>8)&0xff))
        sendframe.append(contentsOf: data)
        let crc = RivoDevice().CRC16(data: data)
    
        sendframe.append(UInt8(crc&0xff))
        sendframe.append(UInt8((crc>>8)&0xff))
        sendframe.append(0x0d)
        sendframe.append(0x0a)
        let data = Data(sendframe) // convert byte array to Data
        
        connection!.writeValue(data as Data, for: UUID_GATT_NUS_COMMAND_ENDPOINT!, type: CBCharacteristicWriteType.withResponse)
        
        // in emulation mode
//        self.connection?.send(content: sendframe, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
//            print(NWError?.debugDescription ?? "sent OK")
//            print(sendframe);
//        })))
    }

    override func read(sentCmd: String, onResponse: @escaping (String?) -> ())
    {
//..
//    let count = characteristic.value!.count
//    temp.append(contentsOf: characteristic.value![0...count-1])
//    totallen += count
//    if(temp.count >= 6 && !isCheck){
//        let STXID = temp[2...3]
//        ID = String(decoding: STXID, as: UTF8.self)
//
//        let len = characteristic.value![4...5]
//        var value : Int = 0
//        for byte in len {
//            value = value << 8
//            value = value | Int(byte)
//        }
//        payloadlen = value>>8
//
//        isCheck = true
//    }
//    //device.read(sentCmd: ID, onResponse: <#T##(String?) -> ()#>)
//    
//    if(temp.count == 10 + payloadlen){
//
//
//        for i in 6...5+payloadlen{
////                payloadvalue.append(contentsOf: temp[6...5+payloadlen])
//            payloadvalue.append(temp[i])
//        }
//        //print(payloadvalue)
//
//        switch ID {
//            case "FV": // getFirmware version
//                let value = payloadvalue
//                print(String(decoding: value, as: UTF8.self))
//            case "IF":
//                let value = payloadvalue
//                var str = String(decoding: value, as: UTF8.self)
//                var lower = str.index(str.startIndex, offsetBy: 25)
//                var upper = str.index(str.startIndex, offsetBy: 32)
//                peripheralversion = String(str[lower...upper])
//                lower = str.index(str.startIndex, offsetBy: 42)
//                upper = str.index(str.startIndex, offsetBy: 45)
//                serialnumber = String(str[lower...upper])
//                print(ID)
//                print(payloadlen)
//                print(String(decoding: value, as: UTF8.self))
//            default:
//                print("default")
//        }
//
//        isCheck = false
//        temp = []
//        payloadvalue = []
//        payloadlen = 0
//        ID = ""
//
//    }
        let data = UUID_GATT_NUS_RESPONSE_ENDPOINT!.value
        if (data != nil){
            print("sent cmd was " + sentCmd) // should be compared to received data

            // command error checking
            let len = data!.count
            let bytes = [UInt8](data!);

            if (!(bytes[0] == UInt8(ascii:"a") &&
                  bytes[1] == UInt8(ascii:"t") &&
                  
                  bytes[len-2] == 0x0d &&
                  bytes[len-1] == 0x0a)) {
                // error
                print("Invalid frame")
                return
            }
            //data[2...3] == sentCmd.data(using: String.Encoding.utf8) &&

            //crc error checking
            let payload = [UInt8](data![6...(len-5)])
            let readCRC = UInt16(bytes[len-4]) + UInt16(bytes[len-3])<<8
            if( self.CRC16(data: payload) != readCRC) {
                print("Data corrupted")
                return
            }

            //convert data -> String
            let str = String(bytes: [UInt8](payload), encoding: String.Encoding.utf8)
            onResponse(str)

        } else {
            print("Data == nil")
            return
        }


    
    
    
//        print("to receive")
//        self.connection?.receiveMessage { (data, context, isComplete, error) in
//            if (isComplete){
//                print("Received it")
//
//            }
//        }
    }
}

