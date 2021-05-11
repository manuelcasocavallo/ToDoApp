//
//  DataStore.swift
//  ToDoApp
//
//  Created by Manuel Casocavallo on 10/05/21.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var toDos = [ToDo]()
    @Published var appError: ErrorType? = nil
    
    var addToDo = PassthroughSubject<ToDo, Never>()
    var updateToDo = PassthroughSubject<ToDo, Never>()
    var deleteToDo = PassthroughSubject<IndexSet, Never>()
    
    var subscription = Set<AnyCancellable>()
    
    init() {
        print(FileManager.docDirURL.path)
        addSubscriptions()
        if FileManager().docExist(named: fileName) {
            loadToDos()
        }
    }
    
    func addSubscriptions() {
        addToDo
            .sink { [unowned self] toDo in
                toDos.append(toDo)
                saveToDos()
            }
            .store(in: &subscription)
        
        updateToDo
            .sink { [unowned self] toDo in
                guard let index = toDos.firstIndex(where: { $0.id == toDo.id }) else { return }
                toDos[index] = toDo
                saveToDos()
            }
            .store(in: &subscription)
        
        deleteToDo
            .sink { [unowned self] indexSet in
                toDos.remove(atOffsets: indexSet)
                saveToDos()
            }
            .store(in: &subscription)
        
    }
    
    func loadToDos() {
        FileManager().readDocument(docName: fileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    toDos = try decoder.decode([ToDo].self, from: data)
                } catch {
                    appError = ErrorType(error: .decodingError)
                }
            case .failure(let error):
                appError = ErrorType(error: error)
            }
        }
    }
    
    func saveToDos() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(toDos)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: fileName) { (error) in
                if let error = error {
                    appError = ErrorType(error: error)
                }
            }
        } catch {
            appError = ErrorType(error: .encodingError)
        }
    }
    
}
