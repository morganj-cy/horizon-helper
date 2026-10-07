//
//  Definitions.swift
//  hh_backend
//
//  Created by Morgan Jones on 07/10/2026.
//

import Vapor
import Fluent

struct DefinitionSummary: Content {
    let id: UUID
    let words: [String]
}

struct DefinitionsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let definitions = routes.grouped("definitions")
        definitions.get(use: getAll)
        definitions.get("summary", use: getSummary)
        definitions.get(":id", use: getOne)

        definitions.post(use: create)
        definitions.post("bulk", use: createMany)

        definitions.put(":id", use: updateOne)

        definitions.delete("bulk", use: deleteMany)
        definitions.delete(":id", use: delete)
    }

    /// Gets all definitions
    func getAll(req: Request) async throws -> [Definition] {
        try await Definition.query(on: req.db).all()
    }

    /// Gets one definition (by path ID)
    func getOne(req: Request) async throws -> Definition {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let definition = try await Definition.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Definition with ID \(id) does not exist")
        }

        return definition
    }

    /// Update one definition (get path ID, update based on JSON body)
    func updateOne(req: Request) async throws -> Definition {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let existingDefinition = try await Definition.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Definition with ID \(id) does not exist")
        }

        let updatedData = try req.content.decode(Definition.self)
        try updatedData.validate()

        existingDefinition.words = updatedData.words
        existingDefinition.definition = updatedData.definition
        existingDefinition.additionalNotes = updatedData.additionalNotes

        try await existingDefinition.update(on: req.db)
        return existingDefinition
    }

    /// Get a summary of all definition (the ID and Words of each definition, returned as an array)
    func getSummary(req: Request) async throws -> [DefinitionSummary] {
        let definitions = try await Definition.query(on: req.db).all()
        return definitions.compactMap { definition in
            guard let id = definition.id else { return nil }
            return DefinitionSummary(id: id, words: definition.words)
        }
    }

    /// Create one definition based off of a JSON body object
    func create(req: Request) async throws -> Definition {
        let definition = try req.content.decode(Definition.self)
        try definition.validate()
        try await definition.save(on: req.db)
        return definition
    }

    /// Create multiple definitions based off of a JSON body array of objects
    func createMany(req: Request) async throws -> [Definition] {
        let definitions = try req.content.decode([Definition].self)

        guard !definitions.isEmpty else {
            throw Abort(.badRequest, reason: "You must create at least 1 definition")
        }

        guard definitions.count < 100 else {
            throw Abort(.badRequest, reason: "You cannot create more than 100 definitions at once")
        }

        for (idx, definition) in definitions.enumerated() {
            do {
                try definition.validate()
            } catch {
                throw Abort(.badRequest, reason: "Validation failed for definition at index \(idx): \(error)")
            }
        }

        try await definitions.create(on: req.db)
        return definitions
    }

    /// Deletes one definition (by path ID)
    func delete(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let definition = try await Definition.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Definition with ID \(id) does not exist")
        }

        try await definition.delete(on: req.db)
        return .noContent
    }

    /// Delete multiple definitions based off of a JSON body array of UUID strings
    func deleteMany(req: Request) async throws -> HTTPStatus {
        let toDelete = try req.content.decode([UUID].self)

        guard !toDelete.isEmpty else {
            throw Abort(.badRequest, reason: "Please provide at least 1 ID to delete")
        }

        guard toDelete.count <= 100 else {
            throw Abort(.badRequest, reason: "You cannot delete more than 100 definitions at once")
        }

        try await Definition.query(on: req.db)
            .filter(\.$id ~~ toDelete)
            .delete()

        return .noContent
    }
}
