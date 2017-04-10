//
//  Event.swift
//  test-server
//
//  Created by Denis on 31.03.17.
//
//

import Foundation
import Vapor
import Fluent

final class Event: Model {
    
    var exists: Bool = false
    var id: Node?
    var date: String
    var title: String
    var description: String
    var imageURL: String
    
    init(title:String, description:String, date:String, imageURL:String) {
        self.title = title
        self.description = description
        self.date = date
        self.imageURL = imageURL
    }
    
    init(node:Node, in context:Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        description = try node.extract("description")
        date = try node.extract("date")
        imageURL = try node.extract("imageURL")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "description": description,
            "date": date,
            "imageURL": imageURL
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("events") { (event) in
            event.id()
            event.string("title")
            event.string("description")
            event.string("date")
            event.string("imageURL")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("events")
    }

}
