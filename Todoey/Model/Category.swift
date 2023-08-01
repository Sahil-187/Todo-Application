//
//  Category.swift
//  Todoey
//
//  Created by Sahil  on 22/06/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var backGroundColor : String = ""
    let items = List<Item>()
}
