//
//  screen 1.swift
//  prank call
//
//  Created by Aileen Jane on 20/04/26.
//

import SwiftUI

let profileImages = ["men 1", "men 2", "men 3", "women 1", "women 2", "women 3", "women 4", "women 5", "women 6", "women 7", "women 8", "women 9", "women 10"]

struct Screen1Player: View {
    @State var players = [chandra, jody, sam, virel, ish]
    @State var victims = [nathan, baeni, javi]
    func deletePlayerById(_ id: UUID) {
        players.removeAll { $0.id == id }
    }
    
    var body: some View {
        NavigationStack {
            
            // PLAYER LIST
            VStack {
                List {
                    ForEach ($players) { $x in
                        NavigationLink {
                            DetailPlayer(
                                contactModel: $x,
                                onDelete: {
                                    deletePlayerById(x.id)
                                }
                            )
                        } label: {
                            HStack {
                                Image(x.imageName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                Text(x.firstName).font(.title2)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(Text("Players 😈"))
                // ADD NEW PLAYER
                .safeAreaInset(edge: .bottom) {
                    NavigationLink {
                        FormPlayer(contactList: $players)
                    } label: {
                        Text ("Add New Player")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .padding()
                }
            }
            
//            // ADD NEW PLAYER
//            NavigationLink {
//                FormPlayer(contactList: $players)
//            } label: {
//                Text ("Add New Player")
//                    .padding()
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.glass)
//            .padding()
            
            // NEXT SCREEN (CHOOSE VICTIM)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Screen1Victim(
                        victims: $victims,
                        players: $players
                    )){
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    Screen1Player()
}

// CHANGE DETAILS
struct DetailPlayer: View {
    @Binding var contactModel: ContactModel
    @State var selectedImage = ""
    let onDelete: () -> Void
    @State var isOn = false
    @State var temporaryTextFieldData = ""
    @State var temporaryNumberFieldData = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            Image(selectedImage)
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            Text(contactModel.firstName)
                .font(.largeTitle.bold())
            VStack {
                Text("Select Icon")
                    .font(.headline.bold())
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(profileImages, id: \.self) { img in
                            Image(img)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedImage == img ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .opacity(selectedImage == img ? 1 : 0.6)
                                .onTapGesture {
                                    selectedImage = img
                                }
                        }
                    }
                    .frame(height: 63)
                    .padding(.horizontal)
                }
            }
            Form {
                Section (header: Text("change name")){
                    TextField("Change Name", text: $temporaryTextFieldData)
                        .onAppear {
                            temporaryTextFieldData = contactModel.firstName
                            selectedImage = contactModel.imageName
                        }
                }
            }
            HStack {
                // CANCEL
                Button {
                    dismiss()
                } label: {
                    Text ("Cancel")
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
                .tint(.blue)
                
                // DELETE
                Button {
                    onDelete()
                    dismiss()
                } label: {
                    Text ("Delete")
                    Image(systemName: "trash")
                }
                .buttonStyle(.glass)
                .tint(.red)
                
                // SAVE
                Button {
                    contactModel.firstName = temporaryTextFieldData
                    contactModel.imageName = selectedImage
                    dismiss()
                } label: {
                    Text ("Save")
                    Image(systemName: "checkmark")
                }
                .foregroundStyle(.black)
                .buttonStyle(.glassProminent)
                .tint(.green)
            }
        }
    }
}

//NEW PLAYER
struct FormPlayer: View {
    @Binding var contactList: [ContactModel]
    @State var selectedImage = profileImages.randomElement()!
    @State var temporaryFirstName = ""
    @State var temporaryPhoneNumber = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack (spacing: 20) {
            Image(selectedImage)
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            Text("New Player")
                .font(.largeTitle.bold())
            VStack {
                Text("Select Icon")
                    .font(.headline.bold())
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(profileImages, id: \.self) { img in
                            Image(img)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedImage == img ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .opacity(selectedImage == img ? 1 : 0.6)
                                .onTapGesture {
                                    selectedImage = img
                                }
                        }
                    }
                    .frame(height: 63)
                    .padding(.horizontal)
                }
            }
            Form {
                Section (header: Text("add name")) {
                    TextField("Name", text: $temporaryFirstName)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            Button {
                contactList.append(
                    ContactModel(firstName: temporaryFirstName,
                                 phoneNumber: temporaryPhoneNumber,
                                 imageName: selectedImage
                                )
                )
                dismiss()
            } label: {
                Text ("Save")
                Image(systemName: "checkmark")
            }
            .foregroundStyle(.black)
            .buttonStyle(.glassProminent)
            .tint(.green)
        }
    }
}
