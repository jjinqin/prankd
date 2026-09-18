//
//  screen 1 combined.swift
//  prank call
//
//  "Who's Playing?" — one screen replacing the old separate Players/Victims list
//  screens. A master contact pool up top (clean, searchable, alphabetical —
//  no overlap, since it needs to stay scannable as it grows), and two drag
//  targets below (Victims / Players) where dropped contacts pile up with a
//  loose scattered look, since those stay small by nature.
//

import SwiftUI
import UniformTypeIdentifiers

//MARK: - stable "random" look for scattered tags (same contact always lands the same way)
func stableRotation(for id: UUID) -> Double {
    var hasher = Hasher()
    hasher.combine(id)
    let hash = abs(hasher.finalize())
    return Double(hash % 17) - 8
}

func stableJitter(for id: UUID) -> CGSize {
    var hasher = Hasher()
    hasher.combine(id)
    let hash = abs(hasher.finalize())
    let dx = Double(hash % 21) - 10
    let dy = Double((hash / 21) % 17) - 8
    return CGSize(width: dx, height: dy)
}

///a stable pseudo-random point inside a fixed-size box, so N contacts always fit — overlapping if there's too many
func stablePosition(for id: UUID, index: Int, in size: CGSize) -> CGPoint {
    var hasher = Hasher()
    hasher.combine(id)
    let hash: Int = abs(hasher.finalize())
    let indexPart1: Int = index * 977
    let indexPart2: Int = index * 613
    let fx = Double((hash + indexPart1) % 1000) / 1000.0
    let fy = Double((hash / 1000 + indexPart2) % 1000) / 1000.0
    let padX: CGFloat = 55
    let padY: CGFloat = 26
    let x = padX + CGFloat(fx) * max(size.width - padX * 2, 1)
    let y = padY + CGFloat(fy) * max(size.height - padY * 2, 1)
    return CGPoint(x: x, y: y)
}

///a fixed-size area where tags sit wherever they were last dropped, falling back to a stable
///scatter position for anyone who's never been placed there yet
struct ScatterZone: View {
    let contacts: [ContactModel]
    let chip: (ContactModel) -> AnyView
    let positionFor: (ContactModel, Int, CGSize) -> CGPoint

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(contacts.enumerated()), id: \.element.id) { index, contact in
                    chip(contact)
                        .position(positionFor(contact, index, geo.size))
                }
            }
        }
    }
}

///tracks each zone's on-screen frame, in a shared coordinate space, so a drag's end point can be tested against them
struct ZoneFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func trackZoneFrame(_ zone: String) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(key: ZoneFrameKey.self, value: [zone: geo.frame(in: .named("dragArea"))])
            }
        )
    }
}

struct WhosPlayingView: View {
    @State var allContacts: [ContactModel] = [chandra, jody, sam, virel, ish, nathan, baeni, javi]
    @State var playerIDs: Set<UUID> = []
    @State var victimIDs: Set<UUID> = []
    @State var searchText = ""
    @State var showAddContact = false

    @State var zoneFrames: [String: CGRect] = [:]
    @State var draggingID: UUID? = nil
    @State var dragLocation: CGPoint = .zero
    ///remembers exactly where a chip was dropped, per zone — key is "zone:contactID"
    @State var chipPositions: [String: CGPoint] = [:]

    func position(for contact: ContactModel, zone: String, index: Int, in size: CGSize) -> CGPoint {
        if let stored = chipPositions["\(zone):\(contact.id)"] {
            let clampedX = min(max(stored.x, 20), max(size.width - 20, 20))
            let clampedY = min(max(stored.y, 16), max(size.height - 16, 16))
            return CGPoint(x: clampedX, y: clampedY)
        }
        return stablePosition(for: contact.id, index: index, in: size)
    }

    var poolContacts: [ContactModel] {
        allContacts
            .filter { !playerIDs.contains($0.id) && !victimIDs.contains($0.id) }
            .filter { searchText.isEmpty || $0.firstName.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.firstName < $1.firstName }
    }

    var playerContacts: [ContactModel] {
        allContacts.filter { playerIDs.contains($0.id) }
    }

    var victimContacts: [ContactModel] {
        allContacts.filter { victimIDs.contains($0.id) }
    }

    func assign(id: UUID, to zone: String) {
        playerIDs.remove(id)
        victimIDs.remove(id)
        if zone == "players" { playerIDs.insert(id) }
        if zone == "victims" { victimIDs.insert(id) }
        // zone == "pool" leaves it unassigned
    }

    ///used to make a matching tag pop out of an overlapping stack while searching, without hiding
    ///the others — someone assigned to Victims/Players should still visibly be there during a search
    func matchesSearch(_ contact: ContactModel) -> Bool {
        searchText.isEmpty || contact.firstName.localizedCaseInsensitiveContains(searchText)
    }

    ///just the visual — no gesture, no drag-hiding. Used both for placed chips and the dragged overlay copy.
    @ViewBuilder
    func chipContent(_ contact: ContactModel, scattered: Bool) -> some View {
        HStack(spacing: 8) {
            if let avatar = contact.imageName {
                Image(avatar)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.firstName)
                    .font(.pixel(15).bold())
                if let phone = contact.phoneNumber {
                    Text(phone)
                        .font(.pixel(11))
                }
            }
        }
        .foregroundColor(prankdGreenDark)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(PrankdTheme.pale)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .rotationEffect(.degrees(scattered ? stableRotation(for: contact.id) : 0))
        .offset(scattered ? stableJitter(for: contact.id) : .zero)
    }

    ///a chip placed in a zone — draggable, hides itself while being dragged (the overlay copy shows instead)
    @ViewBuilder
    func chip(_ contact: ContactModel, scattered: Bool) -> some View {
        chipContent(contact, scattered: scattered)
            .opacity(draggingID == contact.id ? 0 : (matchesSearch(contact) ? 1 : 0.2))
            .zIndex(matchesSearch(contact) && !searchText.isEmpty ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: searchText)
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .named("dragArea"))
                    .onChanged { value in
                        draggingID = contact.id
                        dragLocation = value.location
                    }
                    .onEnded { value in
                        for (zone, rect) in zoneFrames where rect.contains(value.location) {
                            let localPoint = CGPoint(x: value.location.x - rect.minX, y: value.location.y - rect.minY)
                            chipPositions["\(zone):\(contact.id)"] = localPoint
                            assign(id: contact.id, to: zone)
                            break
                        }
                        draggingID = nil
                    }
            )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let headerH: CGFloat = 95
                let controlsH: CGFloat = 40
                let searchH: CGFloat = 38
                let labelH: CGFloat = 22
                let spacing: CGFloat = 10
                let fixedTotal = headerH + controlsH + searchH + labelH * 3 + spacing * 6
                let remaining = max(geo.size.height - fixedTotal, 180)
                let poolH = remaining * 0.42
                let zoneH = remaining * 0.29

                VStack(spacing: spacing) {
                    VStack(spacing: 4) {
                        Text("Who's Playing?")
                            .font(.pixel(24).bold())
                        Text("⟨• ᴗ •⟩✧")
                            .font(.pixel(14))
                            .opacity(0.7)
                        Text("Who's pranking and getting pranked")
                            .font(.pixel(13))
                            .opacity(0.7)
                    }
                    .foregroundColor(prankdGreenDark)
                    .frame(height: headerH)

                    HStack {
                        Text("Contacts")
                            .font(.pixel(17).bold())
                        Spacer()
                        Button {
                            showAddContact = true
                        } label: {
                            Image("plus button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(prankdGreenDark)
                    .frame(height: controlsH)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(prankdGreenDark.opacity(0.6))
                        TextField("Search contacts", text: $searchText)
                            .font(.pixel(14))
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: searchH)
                    .background(PrankdTheme.cardFill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    ScatterZone(contacts: poolContacts, chip: { contact in
                        AnyView(chip(contact, scattered: true))
                    }, positionFor: { contact, index, size in
                        position(for: contact, zone: "pool", index: index, in: size)
                    })
                    .frame(maxWidth: .infinity)
                    .frame(height: poolH)
                    .trackZoneFrame("pool")

                    VStack(spacing: 2) {
                        Text("Victims")
                            .font(.pixel(14).bold())
                            .foregroundColor(prankdGreenDark.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: labelH)
                        ScatterZone(contacts: victimContacts, chip: { contact in
                            AnyView(chip(contact, scattered: true))
                        }, positionFor: { contact, index, size in
                            position(for: contact, zone: "victims", index: index, in: size)
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: zoneH)
                        .background(PrankdTheme.dark.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .trackZoneFrame("victims")
                    }

                    VStack(spacing: 2) {
                        Text("Players")
                            .font(.pixel(14).bold())
                            .foregroundColor(prankdGreenDark.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: labelH)
                        ScatterZone(contacts: playerContacts, chip: { contact in
                            AnyView(chip(contact, scattered: true))
                        }, positionFor: { contact, index, size in
                            position(for: contact, zone: "players", index: index, in: size)
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: zoneH)
                        .background(PrankdTheme.dark.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .trackZoneFrame("players")
                    }
                }
                .padding(16)
                .frame(width: geo.size.width, height: geo.size.height)
                .coordinateSpace(name: "dragArea")
                .onPreferenceChange(ZoneFrameKey.self) { zoneFrames = $0 }
                .overlay {
                    if let draggingID, let contact = allContacts.first(where: { $0.id == draggingID }) {
                        chipContent(contact, scattered: false)
                            .scaleEffect(1.1)
                            .position(dragLocation)
                            .allowsHitTesting(false)
                    }
                }
            }
            .background(StripedBackground())
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    Screen2(players: .constant(playerContacts), victims: .constant(victimContacts), callResults: .constant([]))
                } label: {
                    Text("Next")
                }
                .buttonStyle(PixelButtonStyle())
                .disabled(playerContacts.isEmpty || victimContacts.isEmpty)
                .opacity(playerContacts.isEmpty || victimContacts.isEmpty ? 0.5 : 1)
                .padding()
            }
            .sheet(isPresented: $showAddContact) {
                AddContactSheet { newContact in
                    allContacts.append(newContact)
                }
            }
        }
    }
}

//MARK: - simple wrap layout for scattered tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

//MARK: - add a new contact to the pool
struct AddContactSheet: View {
    @State var name = ""
    @State var phone = ""
    @State var selectedImage = profileImages.randomElement()!
    @Environment(\.dismiss) var dismiss
    let onAdd: (ContactModel) -> Void

    let showAvatarPicker = true

    var body: some View {
        VStack(spacing: 28) {
            Text("New Contact")
                .font(.pixel(24).bold())
                .foregroundColor(prankdGreenDark)

            if showAvatarPicker {
                Image(selectedImage)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())

                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(profileImages, id: \.self) { img in
                            Image(img)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(selectedImage == img ? prankdGreenDark : .clear, lineWidth: 3))
                                .onTapGesture { selectedImage = img }
                        }
                    }
                }
                .safeAreaPadding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("name").font(.pixel(12)).opacity(0.6)
                    TextField("Name", text: $name).font(.pixel(17)).textFieldStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("phone (optional)").font(.pixel(12)).opacity(0.6)
                    TextField("Phone", text: $phone).font(.pixel(17)).textFieldStyle(.plain)
                }
            }
            .foregroundColor(prankdGreenDark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .pixelCard()

            Button {
                onAdd(ContactModel(firstName: name, phoneNumber: phone.isEmpty ? nil : phone, imageName: selectedImage, role: .player))
                dismiss()
            } label: {
                Text("Save")
            }
            .buttonStyle(PixelButtonStyle())
            .disabled(name.isEmpty)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StripedBackground())
    }
}

#Preview {
    WhosPlayingView()
}
