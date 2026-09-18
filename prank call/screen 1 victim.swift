//
//  screen 1 victim.swift
//  prank call
//
//  Created by Aileen Jane on 21/04/26.
//

import SwiftUI


struct Screen1Victim: View {
    @Binding var victims : [ContactModel]
    @Binding var players: [ContactModel]
    @State var callResults: [CallResult] = []
    func deletePlayerById(_ id: UUID) {
        victims.removeAll { $0.id == id }
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                Text("Victims 💀")
                    .font(.pixel(28).bold())
                    .foregroundColor(prankdGreenDark)
                    .padding(.top, 16)

                List {
                    ForEach ($victims) { $x in
                        NavigationLink {
                            DetailVictim(contactModel: $x,
                                         onDelete: {
                                             deletePlayerById(x.id)
                                         }
                            )
                        } label: {
                            HStack{
                                Image(x.imageName ?? "women 1")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(x.firstName)
                                        .font(.pixel(18))
                                    Text(x.phoneNumber ?? "08999999999")
                                        .font(.pixel(13))
                                        .opacity(0.7)
                                }
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
                    FormVictim(contactList: $victims)
                } label: {
                    Text("Add New Victim")
                }
                .buttonStyle(PixelButtonStyle())
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Screen2(
                        players: $players,
                        victims: $victims,
                        callResults: $callResults
                    )){
                        Image(systemName: "chevron.right")
                            .foregroundColor(prankdGreenDark)
                    }
                }
            }
        }
    }
}

// CHANGE DETAILS
struct DetailVictim: View {
    @Binding var contactModel: ContactModel
    @State var selectedImage = ""
    @State var isOn = false
    @State var temporaryTextFieldData = ""
    @State var temporaryNumberFieldData = ""
    @Environment(\.dismiss) private var dismiss
    let onDelete: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(selectedImage)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())

                Text(contactModel.firstName)
                    .font(.pixel(26).bold())
                Text(contactModel.phoneNumber ?? "08999999999")
                    .font(.pixel(16))
                    .opacity(0.7)

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
                .onAppear {
                    selectedImage = contactModel.imageName ?? "women 1"
                    temporaryTextFieldData = contactModel.firstName
                    temporaryNumberFieldData = contactModel.phoneNumber ?? "08999999999"
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("change name")
                            .font(.pixel(13))
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                        TextField("Change Name", text: $temporaryTextFieldData)
                            .font(.pixel(17))
                            .textFieldStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("change number")
                            .font(.pixel(13))
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                        TextField("Change Number", text: $temporaryNumberFieldData)
                            .font(.pixel(17))
                            .textFieldStyle(.plain)
                    }
                }
                .foregroundColor(prankdGreenDark)
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
                        contactModel.phoneNumber = temporaryNumberFieldData
                        contactModel.imageName = selectedImage
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(PixelButtonStyle())
                }
            }
            .foregroundColor(prankdGreenDark)
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

// ADD NEW VICTIM
struct FormVictim: View {
    @Binding var contactList: [ContactModel]
    @State var selectedImage = profileImages.randomElement()!
    @State var temporaryFirstName = ""
    @State var temporaryPhoneNumber = ""
    @State var temporaryImageName = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack (spacing: 20) {
                Image(selectedImage)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                Text("New Victim")
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

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add name")
                            .font(.pixel(13))
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                        TextField("Name", text: $temporaryFirstName)
                            .font(.pixel(17))
                            .textFieldStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add phone number")
                            .font(.pixel(13))
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                        TextField("Phone Number", text: $temporaryPhoneNumber)
                            .font(.pixel(17))
                            .textFieldStyle(.plain)
                    }
                }
                .foregroundColor(prankdGreenDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .pixelCard()

                Button {
                    contactList.append(
                        ContactModel(firstName: temporaryFirstName,
                                     phoneNumber: temporaryPhoneNumber,
                                     imageName: selectedImage,
                                     role: .victim))
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
