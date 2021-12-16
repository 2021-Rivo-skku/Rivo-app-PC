//
//  RivoDevice.swift
//  mac_protocol
//
//  Created by sunwoo Kim on 2021/11/07.
//
import Network
import Foundation
import IOKit

class RivoDevice {
        
    func CRC16(data: [UInt8]) -> UInt16
    {
        var crc: UInt16 = 0xffff;
        for i in 0...data.count-1 {
            //crc = UInt16(((crc>>8) | (crc<<8))&0xff)
            crc = UInt16((crc>>8)&0xff | (crc<<8))
            crc ^= UInt16(data[i])
            crc ^= UInt16(UInt8(crc & 0xff) >> 4)
            crc ^= (crc<<8)<<4
            crc ^= ((crc & 0xff)<<4)<<1
        }

        return crc
    }
    
    /*
     func CRC32(data: [UInt8]) -> UInt32
     {
         var crc: UInt32 = 0xffffffff
         for i in 0...data.count-1 {
             crc ^= UInt32(data[i])
             for j in stride(from: 8, to: 0, by: -1) {
                 crc = (crc>>1)^(0xedb88320u & ((crc&1) ? 0xffffffff : 0))
             }
             
         }
         return ~crc
         
         // let crc = crc32(uLong(0), UnsafePointer<Bytef>(data!.bytes), uInt(data!.length))
     }
     */
    
    func write(cmd: String, data: [UInt8]) {
        // do nothing
        print("something")
    }
    func read(sentCmd: String, onResponse: @escaping (String?) -> ()){
        // do nothing
    }
    
    func getFirmwareVersion() async -> String? {
        write(cmd: "FV", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "FV", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setDateAndTime(type: Int) async -> String? {
        // setting Data/Time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: Date())
        formatter.dateFormat = "MM"
        let mon = formatter.string(from: Date())
        formatter.dateFormat = "dd"
        let day = formatter.string(from: Date())
        formatter.dateFormat = "HH"
        let hour = formatter.string(from: Date())
        formatter.dateFormat = "mm"
        let min = formatter.string(from: Date())
        formatter.dateFormat = "ss"
        let sec = formatter.string(from: Date())
        formatter.dateFormat = "SSSS"
        let millisec = formatter.string(from: Date())
        
        var DTdata = [UInt8]()
        DTdata.append(UInt8(1))
        DTdata.append(UInt8(type))
        DTdata.append(UInt8(year)!)
        DTdata.append(UInt8(mon)!)
        DTdata.append(UInt8(day)!)
        DTdata.append(UInt8(hour)!)
        DTdata.append(UInt8(min)!)
        DTdata.append(UInt8(sec)!)
        DTdata.append(UInt8(millisec)!)
        
        write(cmd: "DT", data: DTdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "DT", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
        
    func getLanguage() async -> String? {
        write(cmd: "LN", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "LN", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    // input == Int
    func setLanguage(language1: Int, input_method1: Int, language2: Int, input_method2: Int) async -> String? {
        var lgcode : String = String(language1)
        lgcode.append(",")
        lgcode.append(String(input_method1))
        lgcode.append(",")
        lgcode.append(String(language2))
        lgcode.append(",")
        lgcode.append(String(input_method2))
        
        var SLdata = [UInt8]()
        SLdata.append(UInt8(1))
        SLdata += lgcode.utf8.map{UInt8($0)};
        
        write(cmd: "LN", data: SLdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "LN", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getScreenReader() async -> String? {
        write(cmd: "SR", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "SR", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setScreenReader(OS: String) async -> String? {
        var SSdata = [UInt8]()
        SSdata.append(UInt8(1))
        switch OS {
        case "IOS":
            SSdata.append(UInt8(11))
        case "watchOS":
            SSdata.append(UInt8(12))
        case "Android":
            SSdata.append(UInt8(21))
        default:
            break;
        }
        
        write(cmd: "SR", data: SSdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "SR", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getVoiceGuidance() async -> String? {
        write(cmd: "VG", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "VG", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setVoiceGuidance(status: Bool) async -> String? {
        var SVGdata = [UInt8]()
        SVGdata.append(UInt8(1))
        if(status){
            //ON
            SVGdata.append(UInt8(1))
        } else {
            //OFF
            SVGdata.append(UInt8(0))
        }
        write(cmd: "VG", data: SVGdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "VG", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getLocaleList() async -> String? {
        write(cmd: "LC", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "LC", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    /* 코드 포맷 정의 필요
    func deleteLocale(onResponse: @escaping ([UInt8]?) -> ()){
        var DLdata = [UInt8]()
        DLdata.append(UInt8(3))
        write(cmd: "LC", data: [0])
        read(sentCmd: "LC", onResponse: onResponse)
    }
    */
    
    func getDictionaryList() async -> String? {
        write(cmd: "DC", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "DC", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    /* 코드 포맷 정의 필요
    func deleteDictionary(onResponse: @escaping ([UInt8]?) -> ()){
        var DDdata = [UInt8]()
        DDdata.append(UInt8(3))
        write(cmd: "DC", data: [0])
        read(sentCmd: "DC", onResponse: onResponse)
    }
    */
    
    func getRivoName() async -> String? {
        write(cmd: "RN", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RN", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setRivoName(name: String) async -> String? {
            var SRNdata = [UInt8]()
            SRNdata.append(UInt8(1))
            SRNdata += name.utf8.map{UInt8($0)};
            write(cmd: "RV", data: SRNdata)
            return await withCheckedContinuation { continuation in
                read(sentCmd: "RV", onResponse: {(str) -> () in
                    print("data received: ", str!.description)
                    continuation.resume(returning: str)
                })
            }
        }
    
    func deleteRivoName() async -> String? {
        write(cmd: "RN", data: [3])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RN", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getDeviceInfo() async -> String? {
        write(cmd: "IF", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "IF", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    // 공장에서만 사용
    func setDeviceInfo(info: String) async -> String? {
        var SDIdata = [UInt8]()
        SDIdata.append(UInt8(1))
        SDIdata.append(UInt8(info)!)
        write(cmd: "IF", data: SDIdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "IF", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    // reserved?
    func findMyRivo() async -> String? {
        write(cmd: "RV", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RV", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    // result?
    func findMyPhone() async -> String? {
        var FMPdata = [UInt8]()
        FMPdata.append(UInt8(2))
        write(cmd: "RV", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RV", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getMTUSize() async -> String? {
        write(cmd: "MT", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "MT", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setMTUSize(MTUSize: Int) async -> String? {
        var SMSdata = [UInt8]()
        SMSdata.append(UInt8(1))
        SMSdata.append(UInt8(MTUSize))
        write(cmd: "MT", data: SMSdata)
        return await withCheckedContinuation { continuation in
            read(sentCmd: "MT", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func getRivoStatus() async -> String? {
        write(cmd: "RS", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RS", onResponse:{(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func setRivoStatus() async -> String? {
        write(cmd: "RS", data: [0])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "RS", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    
    func updateCheck() async -> String? {
        write(cmd: "UM", data: [7])
        return await withCheckedContinuation { continuation in
            read(sentCmd: "UM", onResponse: {(str) -> () in
                print("data received: ", str!.description)
                continuation.resume(returning: str)
            })
        }
    }
    /*
    func updateStart(onResponse: @escaping ([UInt8]?) -> ()) async {
        send(cmd: "UM", data: [])
        receive(sentCmd: "UM", onResponse: onResponse)
    }
     */
}
/*
class UDPDevice: RivoDevice {
    override init() {
        super.init()
        // initialize socket
    }
    override func write(cmd: String, data: [UInt8]) async {
        socket.write ...
    }
    
    func read() {
        
    }
}

class BLEDevice:RivoDevice {
    init() {
        // initialize BLE
        
    }
    func write() {
        
    }
    func read() {
        
    }
}
main() {
 
 //device 는 UDP/BLE 둘다 가능
 var device: RivoDevice
 init(_device: RivoDevice) {
     device = _device
 }

        device = BLEDevice()
        
    //
    device.getFirmwareVersion();
    
    
}
 */
