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
                        Text(vm.dateFormatter.string(from: log.timestamp))
                        Spacer()

                        if let dataLength = log.dataLength {
                            Text("\(dataLength) B")
                        } else {
                            Text("-")
                        }
                    }
                    
                    DisclosureGroup("Details") {
                        Text("Message ID: \(log.messageId)")
                        
                        Text("Dup: \(String(log.dup)) - retained: \(String(log.retained))")
                        
                        if let dataString = log.dataString {
                            Text("data: \(dataString.debugDescription)")
                        } else {
                            Text("data: N/A")
                        }
                    }
                    .font(.caption)
                }
            }
            .textSelection(.enabled)
        }
    }
}

@available(iOS 15.0, *)
struct MQTTChuckView_Previews: PreviewProvider {
    static var previews: some View {
        MQTTChuckView(logger: MQTTChuckLogger())
    }
}
