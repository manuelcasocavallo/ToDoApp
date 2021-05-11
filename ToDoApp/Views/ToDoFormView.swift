//
//  ToDoFormView.swift
//  ToDoApp
//
//  Created by Manuel Casocavallo on 10/05/21.
//

import SwiftUI

struct ToDoFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var formVM: ToDoFormViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading) {
                    TextField("ToDo", text: $formVM.name)
                    
                    if formVM.updating {
                        Toggle("Completed", isOn: $formVM.completed)
                    }
                    
                }
            }
            .navigationBarItems(leading: cancelButton, trailing: updateSaveButton)
        }
        .navigationTitle("ToDo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ToDoFormView {
    func updateToDo() {
        let toDo = ToDo(id: formVM.id!, name: formVM.name, completed: formVM.completed)
        dataStore.updateToDo.send(toDo)
        presentationMode.wrappedValue.dismiss()
    }
    
    func addToDo() {
        let toDo = ToDo(name: formVM.name)
        dataStore.addToDo.send(toDo)
        presentationMode.wrappedValue.dismiss()
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var updateSaveButton: some View {
        Button(formVM.updating ? "Update" : "Save") {
            formVM.updating ? updateToDo() : addToDo()
        }
        .disabled(formVM.isDisabled)
    }
    
}








struct ToDoFormView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoFormView(formVM: ToDoFormViewModel())
            .environmentObject(DataStore())
    }
}
