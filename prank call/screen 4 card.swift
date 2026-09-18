//
//  Card.swift
//  prankd
//
//  Created by jody on 22/04/26.
//

import SwiftUI

//MARK: - the data i want inside the card view
struct cardModel: Identifiable {
    let id = UUID()
    let header: String
    let prank: String
    let emoji: String
}

let prankCards: [cardModel] = [
    cardModel(header: "can i call you back?", prank: "call your ex and pretend that they called you. start the conversation by saying: hey, sorry. i'm really busy, can i call you later?", emoji: "☎️"),
    cardModel(header: "fake pizza", prank: "tell the person you ordered pizza two hours ago and that you checked the entire neighbourhood but it's nowhere to be seen.", emoji: "🍕"),
    cardModel(header: "time traveler", prank: "insist you are them from the future and warn them about what is coming.", emoji: "⏰"),
    cardModel(header: "congratulations!", prank: "pretend to be their favourite celebrity, youtuber, influencer, or brand.", emoji: "🥳"),
    cardModel(header: "selamat malam :p", prank: "wait till 3 am, use a voice changer and just say hello and stay silent. \n(can't wait to hear them scream!)", emoji: "😈"),
]

//MARK: - card view
struct Card: View {
    ///creates a state property called flip that allows the view to manage its state
    @State var flip = false
    @Binding var value: Double

    var body: some View {
        ZStack {
            /// rotates by 90 degrees when the card is not flipped and returns to 0 degrees when it is flipped
            CardFrontView(flip: $flip)
                .rotation3DEffect(.degrees(flip ? 90: 0), axis: (x: 0, y: -1, z: 0))
            /// controls the timing of the animation, so that there is a smooth transition between both sides
                .animation(flip ? .linear : .linear.delay(0.35), value: flip)
            /// behaves the opposite way to the front view
            CardBackView(flip: $flip, value: $value)
                .rotation3DEffect(.degrees(flip ? 0 : -90), axis: (x: 0, y: -1, z: 0))
                .animation(flip ? .linear.delay(0.35) : .linear, value: flip)
        }
        /// when the user taps the screen the flip state toggles between true and false, triggering the animation
        .onTapGesture {
            flip.toggle()
        }
    }
}

//MARK: - front view
struct CardFrontView: View {
    ///passing the flip state from the parent view (top) and the child views
    @Binding var flip: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text("🎴")
                .font(.system(size: 48))
            Text("Tap To Flip")
                .font(.pixel(22).bold())
            Text("⟨•ᴗ•⟩✧")
                .font(.pixel(15))
                .opacity(0.6)
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity, minHeight: 320)
        .pixelCard()
    }
}


//MARK: - back view/poop
struct CardBackView: View {

    let cards: [cardModel] = prankCards

    @Binding var flip: Bool
    @Binding var value: Double ///to 'link' the slider values to one of the arrays

    var card: cardModel { cards[Int(value)] }

    var body: some View {
        VStack(spacing: 12) {
            Text(card.emoji)
                .font(.system(size: 60))
            Text(card.header)
                .font(.pixel(22).bold())
            Text(card.prank)
                .font(.pixel(15))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity, minHeight: 320)
        .pixelCard()
    }
}

//#Preview {
//    PrankView()
//        .preferredColorScheme(.dark)
//}
