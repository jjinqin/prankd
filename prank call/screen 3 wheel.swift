//
//  WheelView.swift
//  prankd
//
//  Created by jody on 19/04/26.
//

import SwiftUI
import AudioToolbox

//MARK: - the data i want inside the view

enum Direction {
    case down
    case up
}

//MARK: - the view with variables (i.e. my wheel)
struct WheelView: View {
    ///circle radius
    @State var radius: Double = 150
    ///direction of the drag gesture
    @State var direction = Direction.down
    ///used to lock the view of the wheel afterwards, allowing for a single spin
    @State var isSpinning: Bool = false
    ///a property to hold the selected name (or victim)
    @State var chosen: ContactModel? = nil /// no value exists
    ///drives the swiftui navigation to the next view (PrankView)
    @State var navigate: Bool = false
    ///degree of circle
    @Binding var degree : Double

    let victims : [ContactModel]
    let circleSize : Double
    let caller : ContactModel
    @Binding var players : [ContactModel]
    @Binding var callResults : [CallResult]
    
    /// how big is each slice of the wheel
    var segmentAngle : Double { 360 / Double(victims.count) }
    var selectedIndexAtSide: Int {
        /// guard against the condition (!array.isEmpty), so if it fails return 0
        guard !victims.isEmpty else { return 0 }
        /// when degree == 0, index 0 is at the top.
        /// as degree increases (clockwise rotation), the selected index moves backwards, so we negate degree to compensate -> fixes the mismatch
        let raw = Int(round((-degree) / segmentAngle))
        /// safe modulo to handle negative values
        return ((raw % victims.count) + victims.count) % victims.count
    }

    ///schedules one tick (haptic + sound) per wheel segment crossed, timed to the
    ///easeOut deceleration curve so they land fast at first and stretch out near the end
    func scheduleSpinTicks(totalRotation: Double, segment: Double, duration: Double) {
        let tickCount = max(Int((totalRotation / segment).rounded()) - 1, 0)
        guard tickCount > 0 else { return }
        for k in 1...tickCount {
            let progress = min(Double(k) * segment / totalRotation, 1)
            ///invert the easeOut cubic curve to find when this fraction of rotation is reached
            let t = 1 - pow(1 - progress, 1.0 / 3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + t * duration) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                AudioServicesPlaySystemSound(1104)
            }
        }
    }

    //MARK: - function to spin the wheel
    ///take the current rotation and add more spin to it, land at the correct slice
    func spinWheel() {
        ///guard against the condition (!isSpinning), so do nothing if it's spinning
        guard !isSpinning else { return }
        isSpinning = true

        let segment = 360 / Double(victims.count)
        let spins = 8 * 360.0
        let chosenIndex = Int.random(in: 0..<victims.count)
        let totalRotation = spins - Double(chosenIndex) * segment
        let duration = 3.0

        scheduleSpinTicks(totalRotation: totalRotation, segment: segment, duration: duration)

        withAnimation(.easeOut(duration: duration)) {
            degree += totalRotation
        }

        ///wait for the animation to finish before showing the results
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            /// this code runs after the wheel stops spinning
            /// compute the chosen index after the rotation
            let index = selectedIndexAtSide
            chosen = victims[index]
            navigate = true

            ///haptic + sound when the victim is revealed
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AudioServicesPlaySystemSound(1025)
        }
    }
    
    //MARK: - header text per state
    var headerTitle: String {
        navigate ? "The \"Lucky\" Victim" : "Who's The Victim?"
    }
    var headerKaomoji: String {
        navigate ? "•°+✧⟨｡>‿<｡⟩✧+°." : "⟨•ᴗ•⟩✧"
    }
    var headerSubtitle: String {
        navigate ? "Get ready to be Prankd!" : "Spin the wheel"
    }

    //MARK: - gestures for the wheel

    var body: some View {
        GeometryReader { geo in
            /// to separate the names based on their angle
            let anglePerCount = Double.pi * 2.0 / Double(victims.count)
            let drag = DragGesture()
                .onEnded { value in
                    if value.startLocation.x > value.location.x + 10 {
                        direction = .down
                    }
                    else if value.startLocation.x < value.location.x - 10 {
                        direction = .up
                    }
                    spinWheel()
                }
            let headerHeight: CGFloat = 120
            let bottomSpace: CGFloat = 60
            let wheelSize = geo.size.height - headerHeight - bottomSpace
            let rightInset: CGFloat = 55
            let wheelOffsetX = (geo.size.width / 2 - rightInset) - wheelSize / 2

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(headerTitle)
                        .font(.pixel(26).bold())
                    Text(headerKaomoji)
                        .font(.pixel(15))
                        .opacity(0.7)
                    Text(headerSubtitle)
                        .font(.pixel(15))
                        .opacity(0.6)
                }
                .foregroundColor(PrankdTheme.text)
                .animation(.easeInOut, value: navigate)
                .frame(height: headerHeight)

                // MARK: - spinning wheel
                ZStack {
                    Image("wheel")
                        .resizable()
                        .frame(width: wheelSize, height: wheelSize)
                    /// getting the numerical positions of items during a loop
                    ForEach(victims.indices, id: \.self) { index in
                        let angle = Double(index) * anglePerCount
                        ///x- and y-coordinate of the circle
                        let xOffset = CGFloat(radius * cos(angle))
                        let yOffset = CGFloat(radius * sin(angle))
                        ///check if the current item we're looping over is the selected index
                        let isChosen = index == selectedIndexAtSide
                        Text("\(victims[index].firstName)")
                            .rotationEffect(Angle(degrees: -degree))
                            .offset(x: xOffset, y: yOffset )
                            .font(isChosen && navigate ? .pixel(32).bold() : (isChosen ? .pixel(24) : .pixel(16)))
                            .foregroundColor(PrankdTheme.text)
                            .opacity(navigate && !isChosen ? 0.25 : 1)

                        ///to stop it from being spinable + move it to the next screen

                    }
                }
                .rotationEffect(Angle(degrees: degree))
                .gesture(drag)
                .overlay(alignment: .trailing) {
                    Image("pointer")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .offset(x: 40)
                }
                .animation(.easeInOut, value: navigate)
                .frame(width: wheelSize, height: wheelSize)
                .offset(x: wheelOffsetX)
                .onAppear() {
                    let labelPadding : Double = 160
                    radius = wheelSize/2 - labelPadding

                    isSpinning = false
                }

                if navigate, let chosen {
                    NavigationLink {
                        PrankView(chosen: chosen, caller: caller, players: $players, victims: victims, callResults: $callResults)
                    } label: {
                        Text("Choose Prank")
                    }
                    .buttonStyle(PixelButtonStyle())
                    .padding()
                } else {
                    Spacer(minLength: 0).frame(height: bottomSpace)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(StripedBackground())
        .navigationBarBackButtonHidden(true)
    }
}
    
//    #Preview {
//        ContentView()
//    }
    
