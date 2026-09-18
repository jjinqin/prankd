//
//  screen 1.swift
//  prank call
//
//  Created by Aileen Jane on 20/04/26.
//

import SwiftUI

let profileImages = ["Frame 318", "Frame 319", "Frame 320", "Frame 321", "Frame 322", "Frame 323", "Frame 324", "Frame 325", "Frame 326", "Frame 327", "Frame 328", "Frame 329"]

struct Screen1Player: View {
    @State var players : [ContactModel]
    @State var victims : [ContactModel]
    func deletePlayerById(_ id: UUID) {
        players.removeAll { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                Text("Players 😈")
                    .font(.pixel(28).bold())
                    .foregroundColor(prankdGreenDark)
                    .padding(.top, 16)

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
                                Image(x.imageName ?? "women 1")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                Text(x.firstName)
                                    .font(.pixel(18))
                                    .foregroundColor(prankdGreenDark)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(StripedBackground())
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    FormPlayer(contactList: $players)
                } label: {
                    Text("Add New Player")
                }
                .buttonStyle(PixelButtonStyle())
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Screen1Victim(
                        victims: $victims,
                        players: $players
                    )){
                        Image(systemName: "chevron.right")
                            .foregroundColor(prankdGreenDark)
                    }
                }
            }
        }
    }
}

#Preview {
    let samplePlayers = [
        ContactModel(firstName: "Alex", phoneNumber: "", imageName: "men 1", role: .player),
        ContactModel(firstName: "Bella", phoneNumber: "", imageName: "women 1", role: .player)
    ]
    let sampleVictims = [
        ContactModel(firstName: "Chris", phoneNumber: "09887655443", imageName: "men 2", role: .victim)
    ]
    Screen1Player(players: samplePlayers, victims: sampleVictims)
}

// MARK: - CHANGE DETAILS
struct DetailPlayer: View {
    @Binding var contactModel: ContactModel
    @State var selectedImage = ""
    let onDelete: () -> Void
    @State var isOn = false
    @State var temporaryTextFieldData = ""
    @State var temporaryNumberFieldData = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(selectedImage)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                Text(contactModel.firstName)
                    .font(.pixel(26).bold())
                    .foregroundColor(prankdGreenDark)

                VStack {
                    Text("Select Icon")
                        .font(.pixel(14))
                        .foregroundStyle(prankdGreenDark.opacity(0.6))
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
                                            .stroke(selectedImage == img ? prankdGreenDark : Color.clear, lineWidth: 3)
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("change name")
                        .font(.pixel(13))
                        .foregroundColor(prankdGreenDark.opacity(0.6))
                    TextField("Change Name", text: $temporaryTextFieldData)
                        .font(.pixel(17))
                        .foregroundColor(prankdGreenDark)
                        .textFieldStyle(.plain)
                        .onAppear {
                            temporaryTextFieldData = contactModel.firstName
                            selectedImage = contactModel.imageName ?? "women 1"
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .pixelCard()

                HStack {
                    // CANCEL
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    .buttonStyle(PixelButtonStyle(fill: PrankdTheme.buttonLightFill, textColor: PrankdTheme.darkest))

                    // DELETE
                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        Text("Delete")
                    }
                    .buttonStyle(PixelButtonStyle(fill: PrankdTheme.dark, textColor: PrankdTheme.pale))

                    // SAVE
                    Button {
                        contactModel.firstName = temporaryTextFieldData
                        contactModel.imageName = selectedImage
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(PixelButtonStyle())
                }
            }
            .padding(20)
        }
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(prankdGreenDark)
                }
            }
        }
    }
}

//MARK: - NEW PLAYER
struct FormPlayer: View {
    @Binding var contactList: [ContactModel]
    @State var selectedImage = profileImages.randomElement()!
    @State var temporaryFirstName = ""
    @State var temporaryPhoneNumber = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack (spacing: 20) {
                Image(selectedImage)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                Text("New Player")
                    .font(.pixel(26).bold())
                    .foregroundColor(prankdGreenDark)

                VStack {
                    Text("Select Icon")
                        .font(.pixel(14))
                        .foregroundStyle(prankdGreenDark.opacity(0.6))
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
                                            .stroke(selectedImage == img ? prankdGreenDark : Color.clear, lineWidth: 3)
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("add name")
                        .font(.pixel(13))
                        .foregroundColor(prankdGreenDark.opacity(0.6))
                    TextField("Name", text: $temporaryFirstName)
                        .font(.pixel(17))
                        .foregroundColor(prankdGreenDark)
                        .textFieldStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .pixelCard()

                Button {
                    contactList.append(
                        ContactModel(firstName: temporaryFirstName,
                                     phoneNumber: temporaryPhoneNumber,
                                     imageName: selectedImage,
                                     role: .player
                                    )
                    )
                    dismiss()
                } label: {
                    Text("Save")
                }
                .buttonStyle(PixelButtonStyle())
            }
            .padding(20)
        }
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(prankdGreenDark)
                }
            }
        }
    }
}
