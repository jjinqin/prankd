//
//  PrankView.swift
//  prankd
//
//  Created by jody on 22/04/26.
//


import SwiftUI

//MARK: - state and environment properties
struct PrankView: View {
    @Environment(\.dismiss) var dismiss
    @State var value: Double = 0
    @State var isConfirmed = false

    let chosen: ContactModel
    let caller: ContactModel
    @Binding var players: [ContactModel]
    let victims: [ContactModel]
    @Binding var callResults: [CallResult]

    var chosenPrank: cardModel {
        prankCards[Int(value)]
    }

    let severityEmojis = ["💩", "🫢", "🫣", "🤪", "😈"]

    //MARK: - whole view
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Choose Your Prank")
                        .font(.pixel(28).bold())
                    Text("⟨•ᴗ•⟩✧")
                        .font(.pixel(17))
                        .foregroundColor(prankdGreenDark.opacity(0.7))
                    Text("Calling \(chosen.firstName)")
                        .font(.pixel(17))
                        .foregroundColor(prankdGreenDark.opacity(0.6))
                }
                .foregroundColor(prankdGreenDark)

                ///how bad is the prank
                VStack(spacing: 16) {
                    Slider(value: $value, in: 0...4, step: 1)
                        .tint(PrankdTheme.dark)
                        .disabled(isConfirmed)

                    HStack {
                        ForEach(Array(severityEmojis.enumerated()), id: \.offset) { index, emoji in
                            Text(emoji)
                                .font(.system(size: 24))
                                .opacity(Int(value) == index ? 1 : 0.3)
                            if index != severityEmojis.count - 1 {
                                Spacer()
                            }
                        }
                    }

                    ///to include a done button to activate flip the card
                    if !isConfirmed {
                        Button {
                            withAnimation { isConfirmed = true }
                        } label: {
                            Text("Lock It In")
                        }
                        .buttonStyle(PixelButtonStyle())
                    }
                }
                .foregroundColor(prankdGreenDark)
                .frame(maxWidth: .infinity)
                .pixelCard()

                //MARK: - start of card
                if isConfirmed {
                    Card(flip: false, value: $value)
                }
                //MARK: end of card -
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            if isConfirmed {
                NavigationLink {
                    RateTheCall(caller: caller, victim: chosen, prank: chosenPrank, players: $players, victims: victims, callResults: $callResults)
                } label: {
                    Text("Next")
                }
                .buttonStyle(PixelButtonStyle())
                .padding()
            }
        }
    }
}

//#Preview {
//    PrankView(chosen: chosen?.val)
//        .preferredColorScheme(.dark)
//}
