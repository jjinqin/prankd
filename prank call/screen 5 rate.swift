//
//  RateView.swift
//  prankd
//
//  Created by jody on 24/04/26.
//

import SwiftUI

let prankdGreen = PrankdTheme.background
let prankdGreenDark = PrankdTheme.text

struct RateTheCall: View {
    let caller: ContactModel
    let victim: ContactModel
    let prank: cardModel
    @Binding var players: [ContactModel]
    let victims: [ContactModel]
    @Binding var callResults: [CallResult]

    enum Phase {
        case recap
        case rating
        case reveal
    }

    @State var phase: Phase = .recap
    @State var raterIndex = 0
    @State var currentRating = 0
    @State var collectedRatings: [Int] = []

    var raters: [ContactModel] {
        players.filter { $0.id != caller.id }
    }

    var averageRating: Double {
        guard !collectedRatings.isEmpty else { return 0 }
        return Double(collectedRatings.reduce(0, +)) / Double(collectedRatings.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch phase {
                case .recap:
                    recapView
                case .rating:
                    ratingView
                case .reveal:
                    revealView
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            switch phase {
            case .recap:
                Button {
                    withAnimation { phase = .rating }
                } label: {
                    Text("Rate The Prank")
                }
                .buttonStyle(PixelButtonStyle())
                .padding()
            case .rating:
                EmptyView()
            case .reveal:
                HStack(spacing: 12) {
                    NavigationLink {
                        RoundRecap(callResults: callResults, players: $players, victims: victims)
                    } label: {
                        Text("End Round")
                    }
                    .buttonStyle(PixelButtonStyle(fill: PrankdTheme.buttonLightFill, textColor: PrankdTheme.darkest))

                    NavigationLink {
                        Screen2(players: $players, victims: .constant(victims), callResults: $callResults)
                    } label: {
                        Text("New Call")
                    }
                    .buttonStyle(PixelButtonStyle())
                }
                .padding()
            }
        }
    }

    ///the caller/victim/prank card — shown on all three phases so nobody has to remember it
    @ViewBuilder
    var recapCard: some View {
        VStack(spacing: 6) {
            Text(caller.firstName)
                .font(.pixel(22).bold())
            Text("pranks")
                .font(.pixel(13))
                .foregroundColor(prankdGreenDark.opacity(0.85))
            Text(victim.firstName)
                .font(.pixel(22).bold())
            if let phone = victim.phoneNumber {
                Text(phone)
                    .font(.pixel(12))
            }
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity)
        .pixelCard()

        VStack(alignment: .center, spacing: 8) {
            Text("Prank")
                .font(.pixel(12))
                .foregroundColor(prankdGreenDark.opacity(0.6))
            Text(prank.header)
                .font(.pixel(20).bold())
            Text(prank.prank)
                .font(.pixel(17))
                .multilineTextAlignment(.center)
            Text(prank.emoji)
                .font(.system(size: 60))
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity)
        .pixelCard()
    }

    @ViewBuilder
    var recapView: some View {
        VStack(spacing: 6) {
            Text("Prank Time!")
                .font(.pixel(28).bold())
            Text("⟨•ᴗ•⟩✧")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.7))
            Text("Get into character")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.6))
        }
        .foregroundColor(prankdGreenDark)

        recapCard
    }

    ///the compact caller/victim/prank card — used on both the rating and reveal screens
    @ViewBuilder
    var simpleRecapCard: some View {
        VStack(spacing: 6) {
            Text(caller.firstName)
                .font(.pixel(22).bold())
            Text("pranks")
                .font(.pixel(13))
                .foregroundColor(prankdGreenDark.opacity(0.85))
            Text(victim.firstName)
                .font(.pixel(22).bold())
            Text(prank.prank)
                .font(.pixel(18))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity)
        .pixelCard()
    }

    @ViewBuilder
    var ratingView: some View {
        VStack(spacing: 6) {
            Text("How's The Prank?")
                .font(.pixel(28).bold())
            Text("⟨•ᴗ•⟩✧")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.7))
            Text("Rate your friend's call")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.6))
        }
        .foregroundColor(prankdGreenDark)

        simpleRecapCard

        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("What did you think of the prank")
                    .font(.pixel(17))
                Text("\(raters[raterIndex].firstName)?")
                    .font(.pixel(22).bold())
            }

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    AssetStarRating(fill: star <= currentRating ? 1 : 0)
                        .frame(width: 54, height: 54)
                        .onTapGesture { currentRating = star }
                }
            }
            HStack {
                VStack(spacing: 4) {
                    Image("meh").resizable()
                        .frame(width: 32, height: 32)
                    Text("Erm...")
                }
                Spacer()
                Text("\(currentRating) Stars")
                Spacer()
                VStack(spacing: 4) {
                    Image("laugh").resizable()
                        .frame(width: 32, height: 32)
                    Text("HAHAHA")
                }
            }
            .font(.pixel(12))
            .foregroundColor(prankdGreenDark.opacity(0.6))

            Button {
                collectedRatings.append(currentRating)
                currentRating = 0
                if raterIndex + 1 < raters.count {
                    raterIndex += 1
                } else {
                    callResults.append(CallResult(caller: caller, victim: victim, prank: prank, ratings: collectedRatings))
                    withAnimation { phase = .reveal }
                }
            } label: {
                Text(raterIndex + 1 < raters.count ? "Next Person" : "Reveal")
            }
            .buttonStyle(PixelButtonStyle())
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity)
        .pixelCard()
    }

    var ratingLabel: String {
        switch Int(averageRating.rounded()) {
        case 5: return "Hilarious!"
        case 4: return "Pretty Good!"
        case 3: return "Decent"
        case 2: return "Meh..."
        default: return "Erm..."
        }
    }

    var ratingKaomoji: String {
        switch Int(averageRating.rounded()) {
        case 5: return "{≧▽≦}"
        case 4: return "⟨^‿^⟩"
        case 3: return "⟨•ᴗ•⟩"
        case 2: return "⟨._.⟩"
        default: return "⟨×_×⟩"
        }
    }

    @ViewBuilder
    var revealView: some View {
        VStack(spacing: 6) {
            Text("The Prank Was...")
                .font(.pixel(28).bold())
            Text("⟨•ᴗ•⟩✧")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.7))
            Text("What did everyone think")
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.6))
        }
        .foregroundColor(prankdGreenDark)

        simpleRecapCard

        VStack(spacing: 16) {
            Text("Everyone thought it was...")
                .font(.pixel(15))
                .foregroundColor(prankdGreenDark.opacity(0.85))
            Text(ratingLabel)
                .font(.pixel(24).bold())
            Text(ratingKaomoji)
                .font(.pixel(17))
                .foregroundColor(prankdGreenDark.opacity(0.7))
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    AssetStarRating(fill: min(max(averageRating - Double(star - 1), 0), 1))
                        .frame(width: 54, height: 54)
                }
            }
            HStack {
                VStack(spacing: 4) {
                    Image("meh").resizable()
                        .frame(width: 32, height: 32)
                    Text("Erm...")
                }
                Spacer()
                Text(String(format: "%.1f Stars", averageRating))
                Spacer()
                VStack(spacing: 4) {
                    Image("laugh").resizable()
                        .frame(width: 32, height: 32)
                    Text("HAHAHA")
                }
            }
            .font(.pixel(12))
            .frame(maxWidth: .infinity)
            .foregroundColor(prankdGreenDark.opacity(0.6))
        }
        .foregroundColor(prankdGreenDark)
        .frame(maxWidth: .infinity)
        .pixelCard()
    }
}

//MARK: - end of round recap
struct RoundRecap: View {
    let callResults: [CallResult]
    @Binding var players: [ContactModel]
    let victims: [ContactModel]
    @Environment(\.dismiss) var dismiss
    @State var selectedTab: RecapTab = .calls
    @State var freshCallResults: [CallResult] = []

    enum RecapTab {
        case calls, players
    }

    struct PlayerSummary: Identifiable {
        let id: UUID
        let name: String
        let imageName: String?
        let average: Double
    }

    var bestCall: CallResult? {
        callResults.max { $0.averageRating < $1.averageRating }
    }

    var overallAverage: Double {
        guard !callResults.isEmpty else { return 0 }
        return callResults.map(\.averageRating).reduce(0, +) / Double(callResults.count)
    }

    var roundLabel: String {
        switch Int(overallAverage.rounded()) {
        case 5: return "Hilarious Round"
        case 4: return "Pretty Good Round"
        case 3: return "Decent Round"
        case 2: return "Meh Round"
        default: return "Rough Round"
        }
    }

    var roundKaomoji: String {
        switch Int(overallAverage.rounded()) {
        case 5: return "))≧{^w^}≦(("
        case 4: return "⟨^‿^⟩"
        case 3: return "⟨•ᴗ•⟩"
        case 2: return "⟨._.⟩"
        default: return "⟨×_×⟩"
        }
    }

    var playerSummaries: [PlayerSummary] {
        let grouped = Dictionary(grouping: callResults, by: { $0.caller.id })
        return grouped.map { _, results in
            PlayerSummary(
                id: results[0].caller.id,
                name: results[0].caller.firstName,
                imageName: results[0].caller.imageName,
                average: results.map(\.averageRating).reduce(0, +) / Double(results.count)
            )
        }.sorted { $0.average > $1.average }
    }

    @ViewBuilder
    func tabButton(_ tab: RecapTab, title: String) -> some View {
        Text(title)
            .font(.pixel(15).bold())
            .foregroundColor(selectedTab == tab ? PrankdTheme.pale : prankdGreenDark)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(selectedTab == tab ? PrankdTheme.dark : Color.clear)
            .clipShape(Capsule())
            .onTapGesture { withAnimation { selectedTab = tab } }
    }

    @ViewBuilder
    func podiumItem(_ summary: PlayerSummary, rank: Int, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            Image(summary.imageName ?? "women 1")
                .resizable()
                .frame(width: rank == 1 ? 88 : 66, height: rank == 1 ? 88 : 66)
                .clipShape(Circle())
            Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
                .font(.system(size: 26))
            Text(summary.name)
                .font(.pixel(16).bold())
            Text(String(format: "%.1f", summary.average))
                .font(.pixel(13))
        }
        .foregroundColor(prankdGreenDark)
        .frame(height: height, alignment: .bottom)
    }

    @ViewBuilder
    var podium: some View {
        HStack(alignment: .bottom, spacing: 16) {
            podiumItem(playerSummaries[1], rank: 2, height: 160)
            podiumItem(playerSummaries[0], rank: 1, height: 200)
            podiumItem(playerSummaries[2], rank: 3, height: 160)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(roundLabel)
                        .font(.pixel(28).bold())
                    Text(roundKaomoji)
                        .font(.pixel(17))
                        .foregroundColor(prankdGreenDark.opacity(0.7))
                    Text("How did you guys do?")
                        .font(.pixel(15))
                        .foregroundColor(prankdGreenDark.opacity(0.85))
                }
                .foregroundColor(prankdGreenDark)
                .padding(.top, 10)

                HStack(spacing: 4) {
                    tabButton(.calls, title: "Calls")
                    tabButton(.players, title: "Players")
                }
                .padding(4)
                .background(PrankdTheme.cardFill)
                .clipShape(Capsule())

                if selectedTab == .calls {
                    VStack(spacing: 12) {
                        ForEach(callResults) { result in
                            let isBest = result.id == bestCall?.id
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(result.caller.firstName)
                                        .font(.pixel(20).bold())
                                    Spacer()
                                    if isBest {
                                        Text("Best!")
                                            .font(.pixel(13))
                                    }
                                }
                                Text("Pranks \(result.victim.firstName)")
                                    .font(.pixel(13))
                                Text(result.prank.header)
                                    .font(.pixel(16))
                                HStack {
                                    Spacer()
                                    Text(String(format: "%.1f", result.averageRating))
                                        .font(.pixel(16).bold())
                                    Image("start filled")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                }
                            }
                            .foregroundColor(isBest ? PrankdTheme.pale : prankdGreenDark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .pixelCard(fill: isBest ? PrankdTheme.dark : PrankdTheme.cardFill)
                        }
                    }
                } else {
                    if playerSummaries.count >= 3 {
                        podium
                    }
                    VStack(spacing: 12) {
                        let rest = playerSummaries.count >= 3 ? Array(playerSummaries.dropFirst(3)) : playerSummaries
                        ForEach(rest) { summary in
                            HStack {
                                Text(summary.name)
                                    .font(.pixel(20).bold())
                                Spacer()
                                Text(String(format: "%.1f", summary.average))
                                    .font(.pixel(16).bold())
                                Image("start filled")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                            }
                            .foregroundColor(prankdGreenDark)
                            .frame(maxWidth: .infinity)
                            .pixelCard()
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }
                .buttonStyle(PixelButtonStyle(fill: PrankdTheme.buttonLightFill, textColor: PrankdTheme.darkest))

                NavigationLink {
                    Screen2(players: $players, victims: .constant(victims), callResults: $freshCallResults)
                } label: {
                    Text("New Round")
                }
                .buttonStyle(PixelButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    RateTheCall(
        caller: ContactModel(firstName: "Nathan", phoneNumber: "0855555555", imageName: "men 2", role: .player),
        victim: ContactModel(firstName: "Javi", phoneNumber: "0877777777", imageName: "men 3", role: .victim),
        prank: prankCards[1],
        players: .constant([
            ContactModel(firstName: "Nathan", phoneNumber: "0855555555", imageName: "men 2", role: .player),
            ContactModel(firstName: "Jody", phoneNumber: "0811111111", imageName: "women 1", role: .player),
            ContactModel(firstName: "Sam", phoneNumber: "0822222222", imageName: "women 2", role: .player)
        ]),
        victims: [ContactModel(firstName: "Javi", phoneNumber: "0877777777", imageName: "men 3", role: .victim)],
        callResults: .constant([])
    )
}
