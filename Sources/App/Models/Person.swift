//
//  Person.swift
//  test-server
//
//  Created by Denis on 28.03.17.
//
//

import Foundation
import Vapor
import Fluent

final class Human: Model {
    var name: String
    var email: String
    var id: Node?
    var age: Int
    var imageURL: String
    var exists: Bool = false
    
    init(name:String, email:String, age:Int, imageURL:String) {
        self.name = name
        self.email = email
        self.age = age
        self.imageURL = imageURL
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
        age = try node.extract("age")
        imageURL = try node.extract("image_url")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "age": age,
            "image_url":imageURL
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("test_users") { (person) in
            person.id()
            person.string("name")
            person.string("email")
            person.int("age")
            person.string("image_url")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("test_users")
    }
}

struct AddImageUrlToHumans: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify("humans", closure: { bar in
            bar.string("image_url", length: 250, optional: false, unique: false, default: nil)
        })
    }
    
    static func revert(_ database: Database) throws {
        
    }
}
