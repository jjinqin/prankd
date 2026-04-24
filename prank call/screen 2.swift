//
//  screen 2.swift
//  prank call
//
//  Created by Aileen Jane on 21/04/26.
//

import SwiftUI

struct Screen2: View {
    @GestureState var isLongPressed = false
    @State private var isPressed = false
    @State private var isFinished = false
    @Binding var players: [ContactModel]
    @Binding var victims: [ContactModel]
    
    @State var winnerIndex: Int? = nil
    @State var pressedStates: [Bool]
    
    func isLeftColumn(index: Int) -> Bool {
        return index % 2 == 0
    }

    func textRotation(index: Int) -> Angle {
        return isLeftColumn(index: index) ? .degrees(90) : .degrees(-90)
    }
    
    @State var holdStartTime: Date?
    init(players: Binding<[ContactModel]>, victims: Binding<[ContactModel]>) {
        self._players = players
        self._victims = victims
        self._pressedStates = State(initialValue: Array(repeating: false, count: players.wrappedValue.count))
    }
    @State var touchPoints: [CGPoint] = []
    var allPressed: Bool {
        pressedStates.allSatisfy { $0 }
    }
    
    func circleSize(for screenWidth: CGFloat) -> CGFloat{
        let count = players.count
        
        if count <= 5 {
            return 80
        } else if count <= 8 {
            return 80
        } else if count <= 12 {
            return 70
        } else {
            return 50
        }
    }

// CIRCLE INTERACTION
@ViewBuilder
func playerView(index: Int, size: CGFloat) -> some View {
    VStack (spacing: 10){
        Circle()
            .fill(pressedStates[index] ? Color.green : Color.white)
            .frame(width: size, height: size)
            .scaleEffect(pressedStates[index] ? 1.2 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        pressedStates[index] = true
                    }
                    .onEnded { _ in
                        pressedStates[index] = false
                    }
            )
        Text(players[index].firstName)
    }
    .opacity(isFinished && index != winnerIndex ? 0 : 1)
    .animation(.easeInOut, value: isFinished)
}

// GRID LAYOUT
func generateTouchPoints(screenSize: CGSize) {
    let count = players.count
    
    let columns = Int(ceil(sqrt(Double(count)))) // dynamic grid
    let rows = Int(ceil(Double(count) / Double(columns)))
    
    // dynamic circle size
    let circleSize: CGFloat = max(60, min(100, screenSize.width / CGFloat(columns + 1)))
    
    let spacingX = circleSize + 20
    let spacingY = circleSize + 20
    
    // total grid size
    let totalWidth = spacingX * CGFloat(columns - 1)
    let totalHeight = spacingY * CGFloat(rows - 1)
    
    // center offset
    let startX = (screenSize.width - totalWidth) / 2
    let startY = (screenSize.height - totalHeight) / 2
    
    for i in 0..<count {
        let col = i % columns
        let row = i / columns
        
        let x = startX + CGFloat(col) * spacingX
        let y = startY + CGFloat(row) * spacingY
        
        touchPoints.append(CGPoint(x: x, y: y))
    }
    pressedStates = Array(repeating: false, count: players.count)
}

//CIRCLE LAYOUT
func circlePositions(in size: CGSize) -> [CGPoint] {
    let count = players.count
    let radius: CGFloat = min(size.width, size.height) / 3
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    
    return (0..<count).map { i in
        let angle = (2 * .pi / CGFloat(count)) * CGFloat(i)
        let x = center.x + cos(angle) * radius
        let y = center.y + sin(angle) * radius
        return CGPoint(x: x, y: y)
    }
}

// LAZYVGRID
var gridColumns: [GridItem] {
    let columnCount = min(2, players.count) // max 2 columns
    
    return Array(
        repeating: GridItem(.flexible(), spacing: 20),
        count: columnCount
    )
}

var body: some View {
    NavigationStack {
        GeometryReader { geo in
            let size = circleSize(for: geo.size.width)
            VStack {
                VStack(spacing: 6) {
                    Text("Who's Calling? ☎️")
                        .font(.title.bold())
                    
                    Text("place fingers on screen")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 20)
                Spacer ()
            }
            .frame(maxWidth: .infinity)
            ZStack {
                if players.count <= 5 {
                    // CIRCLE LAYOUT
                    let positions = circlePositions(in: geo.size)
                    ForEach(players.indices, id: \.self) { index in
                        playerView(index: index, size: size)
                            .position(positions[index])
                    }
                    
                } else {
                    // GRID LAYOUT
                    VStack {
                        Spacer ()
                        // VERTICAL SPACING
                        LazyVGrid(columns: gridColumns, spacing: 30) {
                            ForEach(players.indices, id: \.self) { index in
                                playerView(index: index, size: size)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .preferredColorScheme(.dark)
                        .onChange(of: pressedStates) { oldValue, newValue in
                            if allPressed && !isFinished && winnerIndex == nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    winnerIndex = Int.random(in: 0..<players.count)
                                    withAnimation {
                                        isFinished = true
                                    }
                                }
                            }
                        }
                        Spacer ()
                    }
                }
            }
            // STATE LOGIC
            .onAppear {
                generateTouchPoints(screenSize: geo.size)
                pressedStates = Array(repeating: false, count: players.count)
            }
            .onChange(of: pressedStates) {
                if allPressed && !isFinished && winnerIndex == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        winnerIndex = Int.random(in: 0..<players.count)
                        
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isFinished = true
                        }
                    }
                }
            }
        }
    }
}
}

#Preview {
    Screen2(
        players: .constant([
            ContactModel(firstName: "Jody", phoneNumber: "123", imageName: "men 1"),
            ContactModel(firstName: "Sam", phoneNumber: "456", imageName: "men 2"),
            ContactModel(firstName: "Virel", phoneNumber: "789", imageName: "men 3"),
            ContactModel(firstName: "Ish", phoneNumber: "000", imageName: "women 1"),
            ContactModel(firstName: "Chandra", phoneNumber: "111", imageName: "women 2"),
            ContactModel(firstName: "Alex", phoneNumber: "222", imageName: "women 3")
        ]),
        victims: .constant([
            ContactModel(firstName: "Nathan", phoneNumber: "999", imageName: "men 1")
        ])
    )
}
