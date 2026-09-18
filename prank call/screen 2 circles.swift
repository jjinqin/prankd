//
//  screen 2.swift
//  prank call
//
//  Created by Aileen Jane on 21/04/26.
//

import SwiftUI
import AudioToolbox

struct Screen2: View {
    @Environment(\.dismiss) var dismiss
    @GestureState var isLongPressed = false
    @State private var isPressed = false
    @State private var isFinished = false
    @Binding var players: [ContactModel]
    @Binding var victims: [ContactModel]
    @Binding var callResults: [CallResult]

    @State var winnerIndex: Int? = nil
    @State var pressedStates: [Bool]
    @State var degree = 360.0
    
    func isLeftColumn(index: Int) -> Bool {
        return index % 2 == 0
    }
    
    func textRotation(index: Int) -> Angle {
        return isLeftColumn(index: index) ? .degrees(90) : .degrees(-90)
    }
    
    @State var holdStartTime: Date?
    init(players: Binding<[ContactModel]>, victims: Binding<[ContactModel]>, callResults: Binding<[CallResult]>) {
        self._players = players
        self._victims = victims
        self._callResults = callResults
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
    
    //MARK: - CIRCLE INTERACTION
    @ViewBuilder
    func playerView(index: Int, size: CGFloat) -> some View {
        VStack (spacing: 10){
            let winnerName = players[index].firstName
            
            let iconState: PixelIconState = isFinished && index == winnerIndex ? .chosen : (pressedStates[index] ? .pressed : .idle)
            Image(pixelIcon(for: players[index].imageName, state: iconState))
                .resizable()
                .frame(width: size, height: size)
                .scaleEffect(pressedStates[index] ? 1.2 : 1)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !pressedStates[index] {
                                pressedStates[index] = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                        .onEnded { _ in
                            pressedStates[index] = false
                        }
                )
            Text(winnerName)
                .font(.pixel(16))
                .foregroundColor(prankdGreenDark)
        }
        .opacity(isFinished && index != winnerIndex ? 0 : 1)
        .animation(.easeInOut, value: isFinished)
    }
    
    //MARK: - GRID LAYOUT
    func generateTouchPoints(screenSize: CGSize) {
        let count = players.count
        
        let columns = Int(ceil(sqrt(Double(count)))) // dynamic grid
        let rows = Int(ceil(Double(count) / Double(columns)))
        
        /// dynamic circle size
        let circleSize: CGFloat = max(60, min(100, screenSize.width / CGFloat(columns + 1)))
        
        let spacingX = circleSize + 20
        let spacingY = circleSize + 20
        
        /// total grid size
        let totalWidth = spacingX * CGFloat(columns - 1)
        let totalHeight = spacingY * CGFloat(rows - 1)
        
        /// center offset
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
    
    //MARK: - CIRCLE LAYOUT
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
    
    /// LAZYVGRID
    var gridColumns: [GridItem] {
        let columnCount = min(2, players.count) // max 2 columns

        return Array(
            repeating: GridItem(.flexible(), spacing: 20),
            count: columnCount
        )
    }

    //MARK: - HEADER TEXT PER STATE
    var headerTitle: String {
        if isFinished {
            return "The Lucky Caller!"
        } else if allPressed {
            return "Choosing..."
        } else {
            return "Who's Gonna Call?"
        }
    }

    var headerSubtitle: String {
        if isFinished {
            return "Get your phone ready"
        } else if allPressed {
            return "Hold it!"
        } else {
            return "Place a finger for each caller"
        }
    }

    var headerKaomoji: String {
        if isFinished {
            return "◟(*˘▽˘*)◞"
        } else if allPressed {
            return "( ๑>ᯅ<)"
        } else {
            return "⟨• ᴗ •⟩"
        }
    }

    let prankdGreen = PrankdTheme.background
    let prankdGreenDark = PrankdTheme.text

    //MARK: - view
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let size = circleSize(for: geo.size.width)
                VStack {
                    VStack(spacing: 6) {
                        Text(headerTitle)
                            .font(.pixel(28).bold())
                            .foregroundColor(prankdGreenDark)

                        Text(headerKaomoji)
                            .font(.pixel(17))
                            .foregroundColor(prankdGreenDark.opacity(0.7))

                        Text(headerSubtitle)
                            .font(.pixel(22).weight(.medium))
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                    }
                    .padding(.top, 20)
                    .animation(.easeInOut, value: headerTitle)
                    if !isFinished {
                        Button("skip (test)") {
                            winnerIndex = Int.random(in: 0..<players.count)
                            withAnimation { isFinished = true }
                        }
                        .font(.pixel(13))
                        .foregroundColor(prankdGreenDark.opacity(0.5))
                        .padding(.top, 12)
                    }
                    Spacer ()
                }
                .frame(maxWidth: .infinity)
                ZStack {
                    if players.count <= 5 {
                        /// circle layout
                        let positions = circlePositions(in: geo.size)
                        ForEach(players.indices, id: \.self) { index in
                            playerView(index: index, size: size)
                                .position(positions[index])
                        }
                        
                    } else {
                        /// grid layout
                        VStack {
                            Spacer ()
                            /// vertical spacing
                            LazyVGrid(columns: gridColumns, spacing: 30) {
                                ForEach(players.indices, id: \.self) { index in
                                    playerView(index: index, size: size)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .preferredColorScheme(.dark)
                            Spacer ()
                        }
                    }
                }
                ///state logic
                .onAppear {
                    generateTouchPoints(screenSize: geo.size)
                    pressedStates = Array(repeating: false, count: players.count)
                }
                .onChange(of: pressedStates) {
                    if allPressed && !isFinished && winnerIndex == nil {
                        ///mark the start of the "choosing" suspense window
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        AudioServicesPlaySystemSound(1057)

                        ///suspense ticks that speed up as the reveal gets closer
                        let holdDuration = 2.0
                        let tickCount = 6
                        for k in 1..<tickCount {
                            let t = pow(Double(k) / Double(tickCount), 2) * holdDuration
                            DispatchQueue.main.asyncAfter(deadline: .now() + t) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                AudioServicesPlaySystemSound(1057)
                            }
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                            /// chose a random winner from the players
                            winnerIndex = Int.random(in: 0..<players.count)

                            withAnimation(.easeInOut(duration: 1.0)) {
                                isFinished = true
                            }

                            ///haptic + sound when the caller is revealed
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            AudioServicesPlaySystemSound(1013)
                        }
                    }
                }
            }
            .background(StripedBackground())
            .safeAreaInset(edge: .bottom) {
                if isFinished, let winnerIndex {
                    NavigationLink {
                        WheelView(degree: $degree, victims: victims, circleSize: 615, caller: players[winnerIndex], players: $players, callResults: $callResults)
                    } label: {
                        Text("Choose Victim")
                    }
                    .buttonStyle(PixelButtonStyle())
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PixelIconButton(direction: .back) {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    Screen2(
        players: .constant([
            ContactModel(firstName: "Jody", phoneNumber: "123", imageName: "men 1", role: .player),
            ContactModel(firstName: "Sam", phoneNumber: "456", imageName: "men 2", role: .player),
            ContactModel(firstName: "Virel", phoneNumber: "789", imageName: "men 3", role: .player),
            ContactModel(firstName: "Ish", phoneNumber: "000", imageName: "women 1", role: .player),
            ContactModel(firstName: "Chandra", phoneNumber: "111", imageName: "women 2", role: .player),
            ContactModel(firstName: "Alex", phoneNumber: "222", imageName: "women 3", role: .player)
        ]),
        victims: .constant([
            ContactModel(firstName: "Nathan", phoneNumber: "999", imageName: "men 1", role: .victim)
        ]),
        callResults: .constant([])
    )
}
