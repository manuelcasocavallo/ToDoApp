//
//  ToDoError.swift
//  ToDoApp
//
//  Created by Manuel Casocavallo on 10/05/21.
//

import Foundation

enum ToDoError: Error, LocalizedError {
    case saveError
    case readError
    case decodingError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .saveError:
            return NSLocalizedString("Error while saving ToDos, please reinstall the app", comment: "")
        case .readError:
            return NSLocalizedString("Error while reading ToDos, please reinstall the app", comment: "")
        case .decodingError:
            return NSLocalizedString("There was a problem loading your ToDos, please create a new ToDo to start over.", comment: "")
        case .encodingError:
            return NSLocalizedString("Error while saving ToDos, please reinstall the app", comment: "")
        }
    }
}

struct ErrorType: Identifiable {
    let id = UUID()
    let error: ToDoError
}
