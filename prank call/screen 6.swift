//
//  screen 6.swift
//  prank call
//
//  Created by Aileen Jane on 23/04/26.
//

import SwiftUI

struct Screen6: View {
    @State private var showSheet = true
    var top3: [RankedPlayer]
    var players: [RankedPlayer]
    
    var body: some View {
        ZStack {
            VStack {
                TopLeaderboardView(top3: top3)
                    .padding (.top, 30)
                Spacer ()
            }
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                BottomLeaderboardList(players: players)
                    .presentationDetents([.fraction(0.5), .large])
//                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                Spacer()
            }
            .presentationBackgroundInteraction(.enabled)
        }
        .preferredColorScheme(.dark)
    }
}

struct RankedPlayer {
    var contact: ContactModel
    var score: Int
}


// PODIUM PROFILE AND NAME AND NUMBER
struct PodiumItem: View {
    var player: RankedPlayer
    var rank: Int
    var color: Color
    var height: CGFloat
    var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var body: some View {
        VStack (spacing: 10) {
            Image(player.contact.imageName)
                .resizable()
                .frame (width: rank == 1 ? 120:90,
                        height: rank == 1 ? 120:90)
                .clipShape(.circle)
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(medalEmoji)
                        .font(.system(size: 31))
                )
                .offset(y: -height/5)
            Text(player.contact.firstName)
                .font(.title2)
                .offset(y: -height/5)
            
        }
        
    }
}

// PODIUM NUMBER AND LAYOUT
struct TopLeaderboardView: View {
    var top3: [RankedPlayer]
    
    var body: some View {
        VStack (spacing: 30){
            Text("Leaderboard 🏆")
                .font(.title.bold())
                .padding(.leading, 30)
            if top3.count >= 3 {
                HStack(alignment: .bottom, spacing: 30) {
                    
                    // 2ND PLACE
                    PodiumItem(
                        player: top3[1],
                        rank: 2,
                        color: .yellow,
                        height: 120
                    )
                    .offset(x: 20, y: 50)
                    
                    // 1ST PLACE
                    PodiumItem(
                        player: top3[0],
                        rank: 1,
                        color: .green,
                        height: 180
                    )
                    
                    // 3RD PLACE
                    PodiumItem(
                        player: top3[2],
                        rank: 3,
                        color: .pink,
                        height: 120
                    )
                    .offset(x: -20, y: 50)
                    
                }
            }
        }
    }
}

// LEADERBOARD LIST VIEW ALL PLAYER
struct BottomLeaderboardList: View {
    var players: [RankedPlayer]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Leaderboard")
                    .font(.title3.bold())
                ForEach(Array(players.enumerated()), id: \.offset) { index, item in
                    LeaderboardRow(
                        rank: index + 1,
                        name: item.contact.firstName,
                        score: "\(item.score)",
                        color: index == 0 ? .green : index == 1 ? .yellow : .pink,
                        image: item.contact.imageName
                    )
                }
            }
            .padding(40)
        }
    }
}

// LEADERBOARD PER PLAYER
struct LeaderboardRow: View {
    var rank: Int
    var name: String
    var score: String
    var color: Color
    var image: String
    
    var body: some View {
        HStack (spacing: 16){
            
            // NUMBER
            Text("\(rank)")
                .font(.title2.bold())
                .frame (width: 30)
                .foregroundColor(.secondary)
            
            // PROFILE
            Image(image)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            // NAME
            Text(name)
//                .foregroundColor(.black)
            Spacer()
            
            // SCORE
            Text(score)
                .bold()
//                .foregroundColor(.black)
        }
    }
}

#Preview {
    Screen6(top3: [
        RankedPlayer(contact: jody, score: 5400),
        RankedPlayer(contact: sam, score: 5000),
        RankedPlayer(contact: virel, score: 4800),
        RankedPlayer(contact: nathan, score: 3000),
        RankedPlayer(contact: baeni, score: 2000),
        RankedPlayer(contact: ish, score: 1000)
    ],
            players: [
                RankedPlayer(contact: jody, score: 5400),
                RankedPlayer(contact: sam, score: 5000),
                RankedPlayer(contact: virel, score: 4800),
                RankedPlayer(contact: nathan, score: 3000),
                RankedPlayer(contact: baeni, score: 2000),
                RankedPlayer(contact: ish, score: 1000)
            ])
}
