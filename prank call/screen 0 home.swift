//
//  screen 0 home.swift
//  prank call
//

import SwiftUI

struct SplashView: View {
    @State var isActive = false
    @State var logoScale: CGFloat = 0.6
    @State var logoOpacity: Double = 0
    @State var textOpacity: Double = 0

    var body: some View {
        if isActive {
            WhosPlayingView()
        } else {
            VStack(spacing: 20) {
                Spacer()

                Image("logo prankd")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("⟨• ᴗ •⟩✧")
                        .font(.pixel(18))
                        .opacity(0.7)
                    Text("call your friends, prank your enemies")
                        .font(.pixel(15))
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(prankdGreenDark)
                .opacity(textOpacity)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(StripedBackground())
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                    logoScale = 1
                    logoOpacity = 1
                }
                withAnimation(.easeIn.delay(0.4)) {
                    textOpacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
