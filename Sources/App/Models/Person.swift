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
    var exists: Bool = false
    
    init(name:String, email:String, age:Int) {
        self.name = name
        self.email = email
        self.age = age
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
        age = try node.extract("age")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "age": age
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("humans") { (person) in
            person.id()
            person.string("name")
            person.string("email")
            person.int("age")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("humans")
    }
}
