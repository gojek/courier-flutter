//
//  MQTTChuckViewModel.swift
//  CourierE2EApp
//
//  Created by Alfian Losari on 10/04/23.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Combine
#endif

@available(iOS 15.0, *)
class MQTTChuckViewModel: ObservableObject, MQTTChuckLoggerDelegate {
    
    let logger: MQTTChuckLogger
    @Published var logs = [MQTTChuckLog]()
    @Published var searchText = ""
    @Published var filteredLogs = [MQTTChuckLog]()
    var cancellables = Set<AnyCancellable>()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss.SSS"
        return df
    }()
    
    init(logger: MQTTChuckLogger) {
        self.logger = logger
        self.logs = logger.logs.reversed()
        self.logger.delegate = self
        self.$searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            
            .sink { [weak self] text in
                guard let self = self, !text.isEmpty, text == self.searchText else { return }
                self.filteredLogs = self.logs.filter({ log in
                    if log.commandType.localizedCaseInsensitiveContains(text) {
                        return true
                    }
                    if let dataString = log.dataString, dataString.localizedCaseInsensitiveContains(text) {
                        return true
                    }
                    return false
                })
            }.store(in: &cancellables)
        
        
        self.$searchText
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                self?.filteredLogs = []
            }.store(in: &cancellables)
    }
    
    func mqttChuckLoggerDidUpdateLogs(_ logs: [MQTTChuckLog]) {
        DispatchQueue.main.async { [weak self] in
            self?.logs = logs.reversed()
        }
    }
    
    func clearLogs() {
        logger.clearLogs()
    }
}
