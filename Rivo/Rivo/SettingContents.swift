
import WebKit
import SwiftUI

struct SettingContents: View {
    var menutitle: String
    var body: some View {
        switch menutitle {
        case "설정" :
            Set()
        case "업데이트":
            Update()
        case "My리보":
            MyRibo()
        case "도움말":
            Help()
        default:
            Set()
        }
    }
}

struct Set: View {
    @State private var Toggle = true
    
    var functions = ["iOS VoiceOver", "Android TalkBack", "WatchOS"]
    var L3 = ["영어"]
    var inputL3 = ["EWQ", "ABC"]
    var L4 = ["한글", "숫자"]
    var inputL4K = ["disable"]
    var inputL4N = ["리보", "나랏글", "천지인"]
    @State var selectedfunc = 0
    @State var selectedL3L = 0
    @State var selectedL3I = 0
    @State var selectedL4L = 0
    @State var selectedL4I = 0
    
    var body: some View {
        
        ScrollView {
            HStack{
                Text("설정")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding(10)
                    .frame(width: 555 , height: 25, alignment: .leading)
            }
                .padding(10)
            Divider()
                .padding(-10)

            VStack(spacing: 15) {
                Group {
                    HStack {
                        Text("날짜/시간")
                            .font(.title2.bold())
                            .padding(15)
                        Spacer()
                    }
                    HStack {
                        Text("날짜/시간 동기화")
                            .padding(15)
                        Spacer()
                        SwiftUI.Toggle("", isOn: $Toggle)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .padding(15)
                    }
                }
    
                Divider()
                
                Group {
                    HStack {
                        Text("언어/입력")
                            .font(.title2.bold())
                            .padding(15)
                        Spacer()
                        Button(action: {
                            //저장
                        }) {
                            Text("저장")
                        }
                        .padding(15)
                    }
                    HStack {
                        Picker (selection: $selectedL3L,label: Text("L3")){
                            ForEach(0 ..< L3.count) {
                                Text(self.L3[$0])
                            }
    
                        }
                        
                        Picker (selection: $selectedL3I,label: Text("입력방식")){
                            ForEach(0 ..< inputL3.count) {
                                Text(self.inputL3[$0])
                            }
                        }
                    }
                    HStack {
                        Picker (selection: $selectedL4L,label: Text("L4")){
                            ForEach(0 ..< L4.count) {
                                Text(self.L4[$0])
                            }
                        }
                        Picker (selection: $selectedL4I,label: Text("입력방식")){
                            if(selectedL4L == 0){
                                ForEach(0 ..< inputL4K.count) {
                                    Text(self.inputL4K[$0])
                                }
                            }
                            else{
                                ForEach(0 ..< inputL4N.count) {
                                    Text(self.inputL4N[$0])
                                }
                            }
                        }
                    }
                }
                Divider()
                
                Group {
                    HStack{
                        Text("OS/스크린리더")
                            .font(.title2.bold())
                            .padding(15)
                        Spacer()
                    }

                    Picker (selection: $selectedfunc,label: Text("choose")){
                        ForEach(0 ..< functions.count) {
                            Text(self.functions[$0])
                        }
                    }
                    .pickerStyle(InlinePickerStyle())
                }
                Spacer()
            } //VStack
        }//ScrollView
    }//Body
}

struct Update: View {
    @ObservedObject var bleManager = CBController()
    var body: some View{
        ScrollView {
            HStack{
                Text("업데이트")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding(5)
                    .frame(width: 555 , height: 25, alignment: .leading)
            }
                .padding(10)
            Divider()
                .padding(-10)
            
            VStack(spacing: 15){
                Text("업데이트 확인 중 입니다.")
                    .font(.title3)
                    .padding(15)
                Spacer()
                Button (action: {
//                    let getfirm: [UInt8] = [0x65, 0x84, 0x70, 0x86, 0x01, 0x00, 0x00,0x24,0x30, 0x13, 0x10]
//                    let data = NSData(bytes: getfirm, length: getfirm.count)
                    //bleManager.sendProtocol(data)
                    
                }) {
                    Text("버전 확인")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct MyRibo: View {
    @State private var Toggle_vibration = false
    @State private var Toggle_sound = false
    @ObservedObject var bleManager = CBController()
    
    @State var rivoName: String = ""
    @State var isConnected: Bool = false
    
    
    var body: some View{
            ScrollView {
                HStack{
                    Text("My리보")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(10)
                        .frame(width: 555 , height: 25, alignment: .leading)
                }
                    .padding(10)
                Divider()
                    .padding(-10)
                VStack(spacing: 15){
                    Group {

                        HStack{
                            Text("리보3 등록")
                                .font(.title2.bold())
                                .padding(15)
                            Spacer()
                            Button (action: {
                                self.bleManager.startScanning()
                            }) {
                                Text("검색")
                                    .foregroundColor(.black)
                            }
                            .padding(15)
                        }
                        List(bleManager.peripherals) { peripheral in
                            VStack {
                                HStack {
                                    Text(peripheral.name)
                                    Spacer()
                                    Text(String(peripheral.rssi))
                                    Button (action: {
                                        print("select \(peripheral)")
                                        bleManager.connect(peripheral)
//                                        if(bleManager.isConnected){
//                                            self.peripheralName = bleManager.peripheralName
//                                        }


                                    }) {
                                        Text("등록")
                                            .foregroundColor(.blue)
                                    }
                                }
                                Divider()
                            }
                        }
                        .frame(width: 500, height: 200)

                    }
                    Divider()
                    
                    Group {
                        HStack{
                            Text("이름 변경")
                                .font(.title2.bold())
                                .padding(15)
                            Spacer()
                        }
                        TextField("Enter device Name", text:$rivoName)
                            .frame(width: 300, height: 80, alignment: .center)
                        HStack{
                            Button (action: {
                                //let name: [UInt8] = Array(rivoName.utf8)
                                //let len : Int = name.count
                                //MYRIVO 6 +  op 1 = len -> 7
//                                let op: [UInt8] = [0x01]
//                                var name: [UInt8] = [0x4d, 0x59, 0x52, 0x49, 0x56, 0x4f]
                               var sendpayload: [UInt8] = [0x01, 0x4d, 0x59, 0x52, 0x49, 0x56, 0x4f]
////                                sendpayload.append(contentsOf: op)
////                                sendpayload.append(contentsOf: name)
//                                
                                bleManager.device.write(cmd: "RV", data: sendpayload)
                                //bleManager.sendprotocolRV()
                                
                            }) {
                                Text("저장")
                                    .foregroundColor(.blue)
                            }
                            Button (action: {

                            }) {
                                Text("삭제")
                                    .foregroundColor(.black)
                            }
                            
                        }
                    }
                    Divider()
                    
                    Group {
                        HStack{
                            Text("장치 정보")
                                .font(.title2.bold())
                                .padding(15)
                            Spacer()
                        }

                        if(bleManager.isConnected){
                            Text("이름: " + bleManager.peripheralName)
                            
                            Spacer()
                            Text("버전: \(bleManager.peripheralversion)")
                            Spacer()
                            Text("시리얼: \(bleManager.serialnumber)")
                        }
                        else{
                            Text(bleManager.peripheralName)
                        }

                    }
                    Spacer()

                    Group{
                        HStack{
                            Text("내 리보 찾기")
                                .font(.title2.bold())
                                .padding(15)
                            Spacer()
                        }
                        
                        HStack{
                            Text("진동")
                            SwiftUI.Toggle("", isOn: $Toggle_vibration)
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        }
                        HStack{
                            Text("소리")
                            SwiftUI.Toggle("", isOn: $Toggle_sound)
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                
                        }
                        Spacer()
                    }
                    Spacer()
                    
                }//Vstack
            }//ScrollView
    }//Body
}
struct WebView: NSViewRepresentable {
    let url: URL
    func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView { let webView: WKWebView = WKWebView()
        let request = URLRequest(url: self.url)
        webView.customUserAgent = "Safari/605"
        webView.load(request)
        return webView
    }
    func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<WebView>) {}
}



struct Help: View {
    let url : String = "https://rivo.me/ko/quickmanual"
    var body: some View{
        GeometryReader { g in
            ScrollView {
                HStack{
                    Text("도움말")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(10)
                        .frame(width: 555 , height: 25, alignment: .leading)
                }
                    .padding(10)
                Divider()
                    .padding(-10)
                WebView(url: URL(string: url)!)
                    .frame(height: g.size.height)
                Spacer()
            }.frame(height: g.size.height)//Scroll
        }//Geometry
    }//Body
}


