import Foundation
import CoreBluetooth

let rivoCharacteristic = CBUUID(string: "3FD0DA8D-74C2-461C-9963-B6F6EFB8BC13")

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}

var myCentral: CBCentralManager!
var selectedPeripheral: CBPeripheral!

class CBController: NSObject, ObservableObject, CBCentralManagerDelegate{


    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var detectedPeripherals: [CBPeripheral] = []
    @Published var isConnected = false
    
    private var writetype: CBCharacteristicWriteType = .withoutResponse
    var rivoServieUUID = CBUUID(string: "00001100-D102-11E1-9B23-00025B00A5A5")
    var rivoCharacteristic = CBUUID(string: "00001101-D102-11E1-9B23-00025B00A5A5")
    let transferUUID = CBUUID(string: "00001102-D102-11E1-9B23-00025B00A5A5")
    @Published var peripheralName: String = "Not Connected"
    @Published var peripheralversion: String = ""
    @Published var serialnumber: String = ""
    
    var writeCharacteristic: CBCharacteristic?
    var rivoserviceuuid = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    
    var UUID_GATT_NUS_COMMAND_ENDPOINT: CBCharacteristic?
    var UUID_GATT_NUS_RESPONSE_ENDPOINT: CBCharacteristic?
    var UUID_GATT_NUS_DATA_ENDPOINT: CBCharacteristic?
    
    var commandCharacteristicuuid = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    var ResponseCharacteristicuuid = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    var DataCharacteristicuuid = CBUUID(string: "6E400004-B5A3-F393-E0A9-E50E24DCCA9E")
    
    var writeType: CBCharacteristicWriteType = .withoutResponse


    var peripheralManager: CBPeripheralManager!
    
    var device = UDPDevice()
    
    var ID: String = ""
    var isCheck: Bool = false
    var payloadlen = 0
    var temp : [UInt8] = []
    var payloadvalue : [UInt8] = []
    var totallen = 0

    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(value: false)]
    func startScanning () {
        print ("startScanning")
        myCentral.scanForPeripherals (withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.stopScanning()
        }
    }
    func stopScanning () {
        print ("stopScanning")
        myCentral.stopScan()
    }
    
    func findPeripheral (_ count : Int) -> CBPeripheral {
        return detectedPeripherals[count]
    }
    
    func alreadyDetectedPeripheral (_ peripheral: CBPeripheral) -> Bool {
        for p in detectedPeripherals {
            if p.identifier == peripheral.identifier{
                return false
            }
        }
        return true
    }
    func connect(_ peripheral: Peripheral){
        print("connecting")
        selectedPeripheral = findPeripheral(peripheral.id)
        myCentral.connect(selectedPeripheral)
        selectedPeripheral.delegate = self
        print(selectedPeripheral!)
    }
    
    func disconnect(_ peripheral: Peripheral) {
        print("disconnecting")
        let selectedPeripheral = findPeripheral(peripheral.id)
        myCentral.cancelPeripheralConnection(selectedPeripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let rssi = RSSI.intValue
        if isSwitchedOn && alreadyDetectedPeripheral(peripheral) {
            if rssi > -100 && peripheral.name != nil {
                //print(peripheral)
                let newPeripheral = Peripheral(id: peripherals.count, name: peripheral.name ?? "Unkown", rssi: RSSI.intValue)
                peripheral.delegate = self
                detectedPeripherals.append(peripheral)
                //print(newPeripheral)
                peripherals.append(newPeripheral)
            }
        }
        
    }
    
    func sendprotocolRV(){
        //let name: [UInt8] = Array(rivoName.utf8)
        //let len : Int = name.count
        //MYRIVO 6 +  op 1 = len -> 7
        let ATID: [UInt8] = [0x41, 0x54, 0x52, 0x56,0x07, 0x00,0x01, 0x4d, 0x59, 0x52, 0x49, 0x56, 0x4f,  0xF0, 0x1E, 0x0D, 0x0A]

        let getfirmdata = NSData(bytes: ATID, length: ATID.count)
        print("SET_RIVO_NAME_ACK")
        print(selectedPeripheral!)
        print(UUID_GATT_NUS_COMMAND_ENDPOINT!)
        selectedPeripheral!.writeValue(getfirmdata as Data, for: UUID_GATT_NUS_COMMAND_ENDPOINT!, type: CBCharacteristicWriteType.withResponse)
    }
    func sendprotocolFV(){
        let getfirm: [UInt8] = [0x41, 0x54, 0x46, 0x56, 0x01, 0x00, 0x00, 0xF0, 0x1E, 0x0D, 0x0A]
        let getfirmdata = NSData(bytes: getfirm, length: getfirm.count)
        print("GET_FIRMWARE_VERSION")
        print(selectedPeripheral!)
        print(UUID_GATT_NUS_COMMAND_ENDPOINT!)
        selectedPeripheral!.writeValue(getfirmdata as Data, for: UUID_GATT_NUS_COMMAND_ENDPOINT!, type: CBCharacteristicWriteType.withResponse)
    }
    func sendprotocolIF(){
        let getfirm: [UInt8] = [0x41, 0x54, 0x49, 0x46, 0x01, 0x00, 0x00, 0xF0, 0x1E, 0x0D, 0x0A]
        let getfirmdata = NSData(bytes: getfirm, length: getfirm.count)
        print("GET_DEVICE_INFO")
        print(selectedPeripheral!)
        print(UUID_GATT_NUS_COMMAND_ENDPOINT!)
        selectedPeripheral!.writeValue(getfirmdata as Data, for: UUID_GATT_NUS_COMMAND_ENDPOINT!, type: CBCharacteristicWriteType.withResponse)
    }


    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected with \(peripheral)")
        isConnected = true
        selectedPeripheral = peripheral
        myCentral.stopScan()
        peripheral.discoverServices(nil)
        peripheralName = selectedPeripheral.name!
        print("max write value length: \(peripheral.maximumWriteValueLength(for: .withResponse))")
    }

}

extension CBController: CBPeripheralDelegate {
    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %s", error.localizedDescription)
            return
        }
        
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            peripheral.setNotifyValue(true, for: characteristic)

            if characteristic.uuid == commandCharacteristicuuid{
                UUID_GATT_NUS_COMMAND_ENDPOINT = characteristic
                device = UDPDevice(selectedPeripheral, UUID_GATT_NUS_COMMAND_ENDPOINT!)
                let getfirm: [UInt8] = [0x00]
                device.write(cmd: "IF", data: getfirm)
            }
//            if characteristic.uuid == ResponseCharacteristicuuid{
//                UUID_GATT_NUS_RESPONSE_ENDPOINT = characteristic
//            }
//            if characteristic.uuid == DataCharacteristicuuid{
//                UUID_GATT_NUS_DATA_ENDPOINT = characteristic
//            }
        }
        

    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
        }
        else{
            print("success")
        }

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //peripheral이 새로운 데이터를 보낼 때 마다 콜백 호출
        print("didupdatevaluefor")
        if let error = error {
            print("error \(characteristic.uuid): ",error)
        }
        if(characteristic.value == nil){
            print("NULL")
        }
        print("\(characteristic.uuid): \(characteristic.value!.count) bytes")
        print(characteristic)
        
        
        device.setRead(datapath: characteristic)
        
        let count = characteristic.value!.count
        temp.append(contentsOf: characteristic.value![0...count-1])
        totallen += count
        if(temp.count >= 6 && !isCheck){
            let STXID = temp[2...3]
            ID = String(decoding: STXID, as: UTF8.self)

            let len = characteristic.value![4...5]
            var value : Int = 0
            for byte in len {
                value = value << 8
                value = value | Int(byte)
            }
            payloadlen = value>>8

            isCheck = true
        }
        
//        device.read(sentCmd: ID, onResponse: {(str)->() in
//            print("data received: " + str!)
//        })
//
        if(temp.count == 10 + payloadlen){


            for i in 6...5+payloadlen{
//                payloadvalue.append(contentsOf: temp[6...5+payloadlen])
                payloadvalue.append(temp[i])
            }
            //print(payloadvalue)

            switch ID {
                case "FV": // getFirmware version
                    let value = payloadvalue
                    print(String(decoding: value, as: UTF8.self))
                case "IF":
                    let value = payloadvalue
                    var str = String(decoding: value, as: UTF8.self)
                    var lower = str.index(str.startIndex, offsetBy: 25)
                    var upper = str.index(str.startIndex, offsetBy: 32)
                    peripheralversion = String(str[lower...upper])
                    lower = str.index(str.startIndex, offsetBy: 42)
                    upper = str.index(str.startIndex, offsetBy: 45)
                    serialnumber = String(str[lower...upper])
                    print(ID)
                    print(payloadlen)
                    print(String(decoding: value, as: UTF8.self))
                default:
                    print("default")
            }

            isCheck = false
            temp = []
            payloadvalue = []
            payloadlen = 0
            ID = ""

        }

        
//        guard let characteristicData = characteristic.value,
//        let stringFromData = String(data: characteristicData, encoding: .utf8) else {
//                  print("nil")
//                return }
//        print("\(characteristic.uuid): \(characteristicData.count) bytes: " + stringFromData)
    }



    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: %s", error.localizedDescription)
            return
        }
        //guard characteristic.uuid == TransferService.characteristicUUID else { return }
        if characteristic.isNotifying {
            print("Notification began on %@", characteristic)
            
        } else {
            print("Notification stopped on %@. Disconnecting", characteristic)
        }
        

    }


    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Peripheral is ready, send data")
        
    }
}


