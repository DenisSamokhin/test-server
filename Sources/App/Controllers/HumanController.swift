//
//  HumanController.swift
//  test-server
//
//  Created by Denis on 31.03.17.
//
//

import Foundation
import Vapor
import HTTP

final class HumanController {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Human.all().makeNode().converted(to: JSON.self)
    }
    
    func show(_ request: Request, _ human: Human) throws -> ResponseRepresentable {
        return human
    }
    
    func create(_ request: Request) throws -> ResponseRepresentable {
        if request.isContentTypeAcceptable() {
            guard let name = request.json?["name"]?.string, let age = request.json?["age"]?.int, let email = request.json?["email"]?.string else {
                    throw Abort.custom(status: .badRequest, message: "Some parameters are missed.")
            }
            var person = Human(name: name, email: email, age: age)
            try person.save()
            return try person.makeJSON()
        }else {
            return "Wrong Content-Type. Must be \"application/json\""
        }
    }

}

extension Request {
    func isContentTypeAcceptable() -> Bool {
        if let contentType = self.headers["Content-Type"], contentType.contains("application/json") {
            return true
        }else {
            return false
        }
    }
}
