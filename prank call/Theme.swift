//
//  Theme.swift
//  prank call
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

enum PrankdTheme {
    static let darkest = Color(hex: "5B6F5A")
    static let dark = Color(hex: "6F856E")
    static let mid = Color(hex: "81AB83")
    static let light = Color(hex: "A9D4AD")
    static let bright = Color(hex: "93E2A0")
    static let pale = Color(hex: "B4FEBF")

    static let background = bright
    static let text = darkest
    static let cardFill = pale
    static let buttonLightFill = pale
    static let buttonDarkFill = dark
}

extension Font {
    static func pixel(_ size: CGFloat) -> Font {
        .custom("PixelifySans-Regular", size: size)
    }
}

//MARK: - pixelated circle (blocky stepped edge, not a smooth curve)
struct PixelCircle: Shape {
    var resolution: Int = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let diameter = min(rect.width, rect.height)
        let cell = diameter / CGFloat(resolution)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = diameter / 2

        for row in 0..<resolution {
            let cellCenterY = rect.minY + cell * (CGFloat(row) + 0.5)
            let dy = cellCenterY - center.y
            guard abs(dy) < radius else { continue }
            let halfWidth = sqrt(max(radius * radius - dy * dy, 0))
            let cellsAcross = (halfWidth / cell).rounded()
            let snappedHalf = cellsAcross * cell
            guard snappedHalf > 0 else { continue }
            path.addRect(CGRect(x: center.x - snappedHalf, y: cellCenterY - cell / 2, width: snappedHalf * 2, height: cell))
        }
        return path
    }
}

//MARK: - pixel arrow (blocky triangle pointing left, flat back edge)
struct PixelArrow: Shape {
    var resolution: Int = 6

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cell = rect.height / CGFloat(resolution)
        let halfHeight = rect.height / 2

        for row in 0..<resolution {
            let cellCenterY = rect.minY + cell * (CGFloat(row) + 0.5)
            let dy = abs(cellCenterY - rect.midY)
            let fraction = 1 - (dy / halfHeight)
            guard fraction > 0 else { continue }
            let cellsAcross = ((fraction * rect.width) / cell).rounded()
            let width = max(cellsAcross * cell, cell)
            path.addRect(CGRect(x: rect.maxX - width, y: cellCenterY - cell / 2, width: width, height: cell))
        }
        return path
    }
}

//MARK: - pixel speech bubble (notched rounded rect with a small tail)
struct PixelSpeechBubble: Shape {
    var notch: CGFloat = 6

    func path(in rect: CGRect) -> Path {
        let tailSize = rect.height * 0.22
        let bodyRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailSize)
        var path = PixelBorder(notch: notch).path(in: bodyRect)

        let tailStartX = bodyRect.minX + bodyRect.width * 0.22
        path.move(to: CGPoint(x: tailStartX, y: bodyRect.maxY))
        path.addLine(to: CGPoint(x: tailStartX + tailSize, y: bodyRect.maxY))
        path.addLine(to: CGPoint(x: tailStartX, y: bodyRect.maxY + tailSize))
        path.closeSubpath()

        return path
    }
}

//MARK: - pixel star (rasterized 5-point star; outlineOnly keeps just the border blocks, hollow)
struct PixelStar: Shape {
    var resolution: Int = 12
    var outlineOnly: Bool = false

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.42
        var vertices: [CGPoint] = []
        for i in 0..<10 {
            let angle = (Double(i) * .pi / 5) - .pi / 2
            let r = i % 2 == 0 ? outerRadius : innerRadius
            vertices.append(CGPoint(x: center.x + CGFloat(cos(angle)) * r, y: center.y + CGFloat(sin(angle)) * r))
        }

        func isInside(_ point: CGPoint) -> Bool {
            var inside = false
            var j = vertices.count - 1
            for i in 0..<vertices.count {
                let vi = vertices[i], vj = vertices[j]
                if ((vi.y > point.y) != (vj.y > point.y)) &&
                    (point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x) {
                    inside.toggle()
                }
                j = i
            }
            return inside
        }

        let cell = min(rect.width, rect.height) / CGFloat(resolution)

        func filledAt(_ row: Int, _ col: Int) -> Bool {
            guard row >= 0, row < resolution, col >= 0, col < resolution else { return false }
            let cx = rect.minX + cell * (CGFloat(col) + 0.5)
            let cy = rect.minY + cell * (CGFloat(row) + 0.5)
            return isInside(CGPoint(x: cx, y: cy))
        }

        var path = Path()
        for row in 0..<resolution {
            for col in 0..<resolution {
                guard filledAt(row, col) else { continue }
                if outlineOnly {
                    let isBoundary = !filledAt(row - 1, col) || !filledAt(row + 1, col) || !filledAt(row, col - 1) || !filledAt(row, col + 1)
                    guard isBoundary else { continue }
                }
                path.addRect(CGRect(x: rect.minX + cell * CGFloat(col), y: rect.minY + cell * CGFloat(row), width: cell, height: cell))
            }
        }
        return path
    }
}

//MARK: - one rating star built from the real "star"/"start filled" assets, partial-fill left-to-right
struct AssetStarRating: View {
    var fill: Double

    var body: some View {
        ZStack {
            Image("star").resizable()
            GeometryReader { geo in
                Image("start filled").resizable()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle().frame(width: geo.size.width * min(max(fill, 0), 1))
                            Spacer(minLength: 0)
                        }
                    )
            }
        }
    }
}

//MARK: - one rating star, filled left-to-right by `fill` (0...1) for partial-star averages
struct PixelStarRating: View {
    var fill: Double
    var color: Color = PrankdTheme.text

    var body: some View {
        ZStack {
            PixelStar(outlineOnly: true).fill(color)
            GeometryReader { geo in
                PixelStar(outlineOnly: false)
                    .fill(color)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle().frame(width: geo.size.width * min(max(fill, 0), 1))
                            Spacer(minLength: 0)
                        }
                    )
            }
        }
    }
}

//MARK: - per-player pixel icon (idle/pressed/chosen), mapped from a contact's stored "Frame NNN" avatar
enum PixelIconState { case idle, pressed, chosen }

///the "idle" set's 12 frames aren't in the same face order as "pressed"/"chosen" (those two share
///the same order, 13 apart) — this maps a pressed-set frame number to its matching idle frame number
private let idleFrameForPressedFrame: [Int: Int] = [
    318: 306, 319: 310, 320: 314, 321: 308, 322: 311, 323: 315,
    324: 307, 325: 312, 326: 316, 327: 309, 328: 313, 329: 317
]

func pixelIcon(for imageName: String?, state: PixelIconState) -> String {
    guard let imageName, imageName.hasPrefix("Frame "), let num = Int(imageName.dropFirst(6)),
          let idleNum = idleFrameForPressedFrame[num] else {
        switch state {
        case .idle: return "circle idle"
        case .pressed: return "circle pressed"
        case .chosen: return "circle chosen"
        }
    }
    switch state {
    case .idle: return "Frame \(idleNum)"
    case .pressed: return "Frame \(num)"
    case .chosen: return "Frame \(num + 13)"
    }
}

//MARK: - back/forward nav button, using the real uploaded pixel-art assets
struct PixelIconButton: View {
    enum Direction { case back, forward }
    let direction: Direction
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(direction == .back ? "back button" : "forward button")
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
        }
        .buttonStyle(.plain)
    }
}

//MARK: - pixel border shape (stepped/notched corners instead of rounded)
struct PixelBorder: Shape {
    var notch: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let n = notch
        path.move(to: CGPoint(x: rect.minX + n, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - n, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - n, y: rect.minY + n))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + n))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - n))
        path.addLine(to: CGPoint(x: rect.maxX - n, y: rect.maxY - n))
        path.addLine(to: CGPoint(x: rect.maxX - n, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + n, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + n, y: rect.maxY - n))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - n))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + n))
        path.addLine(to: CGPoint(x: rect.minX + n, y: rect.minY + n))
        path.closeSubpath()
        return path
    }
}

//MARK: - pixel button style
struct PixelButtonStyle: ButtonStyle {
    var fill: Color = PrankdTheme.buttonDarkFill
    var textColor: Color = PrankdTheme.pale

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pixel(17))
            .foregroundColor(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(fill)
            .clipShape(PixelBorder(notch: 8))
            .overlay(
                PixelBorder(notch: 8)
                    .stroke(PrankdTheme.darkest, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

//MARK: - pixel card style
struct PixelCard: ViewModifier {
    var fill: Color = PrankdTheme.cardFill

    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(fill)
            .clipShape(PixelBorder(notch: 10))
    }
}

extension View {
    func pixelCard(fill: Color = PrankdTheme.cardFill) -> some View {
        modifier(PixelCard(fill: fill))
    }
}

//MARK: - striped "old phone screen" background
struct StripedBackground: View {
    var base: Color = PrankdTheme.background
    var stripe: Color = PrankdTheme.pale
    var stripeHeight: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                base
                VStack(spacing: stripeHeight) {
                    ForEach(0..<Int(geo.size.height / (stripeHeight * 2)) + 1, id: \.self) { _ in
                        stripe.opacity(0.35)
                            .frame(height: stripeHeight)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
