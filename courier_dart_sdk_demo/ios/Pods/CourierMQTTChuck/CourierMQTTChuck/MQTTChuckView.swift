//
//  MQTTChuckView.swift
//  CourierE2EApp
//
//  Created by Alfian Losari on 10/04/23.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 15.0, *)
public struct MQTTChuckView: View {
    
    @StateObject var vm: MQTTChuckViewModel
    @State var selectedLog: MQTTChuckLog?
    
    public init(logger: MQTTChuckLogger) {
        _vm = .init(wrappedValue: MQTTChuckViewModel(logger: logger))
    }
    
    public var body: some View {
        List {
            if vm.searchText.isEmpty {
                forEachLogsView(logs: vm.logs)
            } else {
                forEachLogsView(logs: vm.filteredLogs)
            }
        }
        .searchable(text: $vm.searchText)
        .sheet(item: $selectedLog) { log in
            if #available(iOS 16.0, *) {
                NavigationStack {
                    MQTTChuckLogView(log: log, dateFormatter: vm.dateFormatter)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    selectedLog = nil
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                }
            } else {
                NavigationView {
                    MQTTChuckLogView(log: log, dateFormatter: vm.dateFormatter)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    selectedLog = nil
                                } label: {
                                    Image(systemName: "xclose")
                                }
                            }
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.clearLogs()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .navigationTitle("Courier MQTT Chuck")
    }
    
    func forEachLogsView(logs: [MQTTChuckLog]) -> some View {
        ForEach(logs) { log in
            HStack {
                MQTTChuckLogHeaderView(log: log, dateFormatter: vm.dateFormatter)
                Image(systemName: "chevron.right")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.accentColor)
            }
            .containerShape(Rectangle())
            .contentShape(Rectangle())
            .onTapGesture { selectedLog = log }
        }
    }
}

@available(iOS 15.0, *)
struct MQTTChuckLogHeaderView: View {
    
    let log: MQTTChuckLog
    let dateFormatter: DateFormatter
    
    var body: some View {
        HStack(alignment: .top) {
            if log.sending {
                Image(systemName: "arrow.up.message.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "arrow.down.message.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
                    .foregroundColor(Color(uiColor: .systemGreen))
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(log.commandType.uppercased())
                    Spacer()
                    Text("QOS: \(log.qos)")
                }
                .font(.headline)
                
                HStack(alignment: .top) {
                    Text(dateFormatter.string(from: log.timestamp))
                    Spacer()
                    if let dataLength = log.dataLength {
                        Text("\(dataLength) B")
                    } else {
                        Text("-")
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct MQTTChuckLogView: View {
    
    let log: MQTTChuckLog
    let dateFormatter: DateFormatter
    @State var isConnectionInfoExpanded = true
    @State var isPayloadExpanded = true
    
    var body: some View {
        List {
            Section { MQTTChuckLogHeaderView(log: log, dateFormatter: dateFormatter) }
            
            if log.isConnectOptionsAvailable {
                Section {
                    DisclosureGroup("Connection Info", isExpanded: $isConnectionInfoExpanded) {
                        if let host = log.host { TitleDetailHView(title: "Host", detail: host) }
                        if let port = log.port { TitleDetailHView(title: "Port", detail: String(port)) }
                        if let scheme = log.scheme { TitleDetailHView(title: "Scheme", detail: scheme) }
                        if let clientId = log.clientId { TitleDetailHView(title: "ClientID", detail: clientId) }
                        if let keepAlive = log.keepAlive { TitleDetailHView(title: "Keep Alive", detail: String(keepAlive)) }
                        if let isCleanSession = log.isCleanSession { TitleDetailHView(title: "Clean Session", detail: String(isCleanSession)) }
                        
                        if let alpn = log.alpn {
                            VStack(alignment: .leading) {
                                Text("ALPN")
                                ForEach(alpn, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        
                        if let userProperties = log.userProperties {
                            VStack {
                                Text("User Properties")
                                ForEach(userProperties.map({ ($0, $1)}), id: \.0) {
                                    TitleDetailHView(title: $0.0, detail: $0.1)
                                }
                            }
                        }
                        
                    }
                }
            }
            
            Section {
                DisclosureGroup("Payload", isExpanded: $isPayloadExpanded) {
                    TitleDetailHView(title: "MessageID", detail: String(log.messageId))
                    TitleDetailHView(title: "Dup", detail: String(log.dup))
                    TitleDetailHView(title: "Retained", detail: String(log.retained))
                    if let dataString = log.dataString {
                        TitleDetailHView(title: "Bytes", detail: dataString.debugDescription)
                    } else {
                        Text("data: N/A")
                    }
                }
            }
        }
        .textSelection(.enabled)
        .navigationTitle("Log Detail")
    }
}

@available(iOS 15.0, *)
struct TitleDetailHView: View {
    
    let title: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(detail)
                .multilineTextAlignment(.trailing)
        }
    }
}

@available(iOS 15.0, *)
struct MQTTChuckView_Previews: PreviewProvider {
    static var previews: some View {
        MQTTChuckView(logger: MQTTChuckLogger())
    }
}
