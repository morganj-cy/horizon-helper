import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: RulesController())
    try app.register(collection: DefinitionsController())

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
