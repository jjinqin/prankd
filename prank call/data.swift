//
//  data.swift
//  prank call
//
//  Created by Aileen Jane on 20/04/26.
//

import Foundation

enum Role {
    case player
    case victim
}

struct ContactModel: Identifiable, Equatable {
    var id = UUID()
    var firstName: String
    var phoneNumber: String?
    var imageName: String?
    var role: Role
}

struct CallResult: Identifiable {
    let id = UUID()
    var caller: ContactModel
    var victim: ContactModel
    var prank: cardModel
    var ratings: [Int] = []

    var averageRating: Double {
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
}

var chandra = ContactModel (firstName: "Chandra", phoneNumber: "08999999999", imageName: "Frame 318", role: .player)
var jody: ContactModel = ContactModel(firstName: "Jody", phoneNumber: "0811111111", imageName: "Frame 319", role: .player)
var sam = ContactModel(firstName: "Sam", phoneNumber: "0822222222", imageName: "Frame 320", role: .player)
var virel = ContactModel (firstName: "Virel", phoneNumber: "0833333333", imageName: "Frame 321", role: .player)
var ish = ContactModel (firstName: "Ish", phoneNumber: "0844444444", imageName: "Frame 322", role: .player)
var nathan = ContactModel (firstName: "Nathan", phoneNumber: "0855555555", imageName: "Frame 323", role: .victim)
var baeni = ContactModel (firstName: "Baeni", phoneNumber: "0866666666", imageName: "Frame 324", role: .victim)
var javi = ContactModel (firstName: "Javier", phoneNumber: "0877777777", imageName: "Frame 325", role: .victim)
