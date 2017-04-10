import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.preparations += Human.self
drop.preparations += Event.self
drop.preparations.append(Human.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

func getDbConnection() -> PostgreSQLDriver? {
    if let db = drop.database?.driver as? PostgreSQLDriver {
        return db
    }else {
        return nil
    }
}

drop.get("version") { req in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    }else {
        return "No db connection"
    }
}

drop.get("/id",":id") { request in
    if let db = getDbConnection() {
        if let id = request.parameters["id"]?.string {
            let user = try db.raw("SELECT * FROM person WHERE id=\(id)")
            let name = user["name"]
            return "Hello \(name)!"
        }
        return "Error retrieving parameters."
    }else {
        return "Error"
    }
    
}


drop.get("humans") { request in
    let humans = try Human.query().all()
    return try humans.makeJSON()
}

drop.get("aloha") { req in
    return try JSON(node: ["privet": "Andrey"])
}

// MARK: - Views endpoints

drop.get("addUser") { req in
    return try drop.view.make("addUser")
}

// MARK: - human endpoints

let humans = HumanController()
drop.get("users", handler:humans.index)
drop.post("users/add", handler:humans.create)

drop.resource("posts", PostController())

drop.run()
