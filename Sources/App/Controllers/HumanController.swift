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
import Storage

final class HumanController {

    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Human.all().makeNode().converted(to: JSON.self)
    }
    
    func show(_ request: Request, _ human: Human) throws -> ResponseRepresentable {
        return human
    }
    
    func create(_ request: Request) throws -> ResponseRepresentable {
        if request.isContentTypeAcceptable() {
            guard let name = request.data["fullname"]?.string, let age = request.data["age"]?.int, let email = request.data["email"]?.string else {
                    throw Abort.custom(status: .badRequest, message: "Some parameters are missed.")
            }
            let imageURL = try request.saveImage()
            var person = Human(name: name, email: email, age: age, imageURL: imageURL)
            try person.save()
            return try person.makeJSON()
        }else {
            throw Abort.custom(status: .badRequest, message: "Wrong Content-Type. Must be \"multipart/form-data\"")
        }
    }

}

extension Request {
    func isContentTypeAcceptable() -> Bool {
        if let contentType = self.headers["Content-Type"], contentType.contains("multipart/form-data") {
            return true
        }else {
            return false
        }
    }
    
    func saveImage() throws -> String {
        guard let fileData = self.formData?["image"]?.part.body, let fileName = self.formData?["image"]?.filename else {
            throw Abort.custom(status: .badRequest, message: "No file in request")
        }
        let name = UUID().uuidString + "_" + fileName.replacingOccurrences(of: " ", with: "_")
        let imageFolder = "content/event-images"
        
        
        do {
            let path = try Storage.upload(bytes: fileData, fileName: name, folder: imageFolder)
            return path
        } catch {
            throw Abort.custom(status: .internalServerError, message: "Unable to write multipart form data to file. Underlying error \(error)")
        }
    }
}
