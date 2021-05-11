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
    var loadToDos = Just(FileManager.docDirURL.appendingPathComponent(fileName))
    
    var subscription = Set<AnyCancellable>()
    
    init() {
        print(FileManager.docDirURL.path)
        addSubscriptions()
        
    }
    
    func addSubscriptions() {
        loadToDos
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .tryMap { url in
                try Data(contentsOf: url)
            }
            .decode(type: [ToDo].self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue(label: "background queue"))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] (completion) in
                switch completion {
                case .finished:
                    print("Loading")
                    toDoSubscription()
                case .failure(let error):
                    if error is ToDoError {
                        appError = ErrorType(error: error as! ToDoError)
                    } else {
                        appError = ErrorType(error: ToDoError.decodingError)
                        toDoSubscription()
                    }
                }
            } receiveValue: { (toDos) in
                self.toDos = toDos
            }
            .store(in: &subscription)
        
        addToDo
            .sink { [unowned self] toDo in
                toDos.append(toDo)
            }
            .store(in: &subscription)
        
        updateToDo
            .sink { [unowned self] toDo in
                guard let index = toDos.firstIndex(where: { $0.id == toDo.id }) else { return }
                toDos[index] = toDo
            }
            .store(in: &subscription)
        
        deleteToDo
            .sink { [unowned self] indexSet in
                toDos.remove(atOffsets: indexSet)
            }
            .store(in: &subscription)
    }
    
    func toDoSubscription() {
        $toDos
            .subscribe(on: DispatchQueue(label: "background queue"))
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .encode(encoder: JSONEncoder())
            .tryMap { data in
                try data.write(to: FileManager.docDirURL.appendingPathComponent(fileName))
            }
            .sink { [unowned self] (completion) in
                switch completion {
                case .finished:
                    print("Saving completed")
                case .failure(let error):
                    if error is ToDoError {
                        appError = ErrorType(error: error as! ToDoError)
                    } else {
                        appError = ErrorType(error: ToDoError.encodingError)
                    }
                }
            } receiveValue: { _ in
                print("Saving file was successful")
            }
            .store(in: &subscription)
    }
    
}
