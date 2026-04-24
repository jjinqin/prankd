//
//  data.swift
//  prank call
//
//  Created by Aileen Jane on 20/04/26.
//

import Foundation

struct ContactModel: Identifiable {
    var id = UUID()
    var firstName: String
    var phoneNumber: String
    var imageName: String
}

var chandra = ContactModel (firstName: "Chandra", phoneNumber: "08999999999", imageName: "women 5")
var jody: ContactModel = ContactModel(firstName: "Jody", phoneNumber: "0811111111", imageName: "women 1")
var sam = ContactModel(firstName: "Sam", phoneNumber: "0822222222", imageName: "women 2")
var virel = ContactModel (firstName: "Virel", phoneNumber: "0833333333", imageName: "women 3")
var ish = ContactModel (firstName: "Ish", phoneNumber: "0844444444", imageName: "men 1")
var nathan = ContactModel (firstName: "Nathan", phoneNumber: "0855555555", imageName: "men 2")
var baeni = ContactModel (firstName: "Baeni", phoneNumber: "0866666666", imageName: "women 4")
var javi = ContactModel (firstName: "Javier", phoneNumber: "0877777777", imageName: "men 3")
