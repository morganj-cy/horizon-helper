//
//  Rules.swift
//  hh_backend
//
//  Created by Morgan Jones on 06/10/2026.
//

import Vapor
import Fluent

struct RuleSummary: Content {
    let id: UUID
    let title: String
}

struct RulesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let rules = routes.grouped("rules")
        rules.get(use: getAll)
        rules.get("summary", use: getSummary)
        rules.get(":id", use: getOne)

        rules.post(use: create)
        rules.post("bulk", use: createMany)

        rules.put(":id", use: updateOne)

        rules.delete("bulk", use: deleteMany)
        rules.delete(":id", use: delete)
    }

    /// Gets all rules
    func getAll(req: Request) async throws -> [Rule] {
        try await Rule.query(on: req.db).all()
    }

    /// Gets one rule (by path ID)
    func getOne(req: Request) async throws -> Rule {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let rule = try await Rule.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Rule with ID \(id) does not exist")
        }

        return rule
    }

    /// Update one rule (get path ID, update based on JSON body)
    func updateOne(req: Request) async throws -> Rule {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let existingRule = try await Rule.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Rule with ID \(id) does not exist")
        }

        let updatedData = try req.content.decode(Rule.self)
        try updatedData.validate()

        existingRule.title = updatedData.title
        existingRule.description = updatedData.description
        existingRule.additionalNotes = updatedData.additionalNotes

        try await existingRule.update(on: req.db)
        return existingRule
    }

    /// Get a summary of all rules (the ID and Name of each rule, returned as an array)
    func getSummary(req: Request) async throws -> [RuleSummary] {
        let rules = try await Rule.query(on: req.db).all()
        return rules.compactMap { rule in
            guard let id = rule.id else { return nil }
            return RuleSummary(id: id, title: rule.title)
        }
    }

    /// Create one rule based off of a JSON body object
    func create(req: Request) async throws -> Rule {
        let rule = try req.content.decode(Rule.self)
        try rule.validate()
        try await rule.save(on: req.db)
        return rule
    }

    /// Create multiple rules based off of a JSON body array of objects
    func createMany(req: Request) async throws -> [Rule] {
        let rules = try req.content.decode([Rule].self)

        guard !rules.isEmpty else {
            throw Abort(.badRequest, reason: "You must create at least 1 rule")
        }

        guard rules.count < 100 else {
            throw Abort(.badRequest, reason: "You cannot create more than 100 rules at once")
        }

        for (idx, rule) in rules.enumerated() {
            do {
                try rule.validate()
            } catch {
                throw Abort(.badRequest, reason: "Validation failed for rule at index \(idx): \(error)")
            }
        }

        try await rules.create(on: req.db)
        return rules
    }

    /// Deletes one rule (by path ID)
    func delete(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let rule = try await Rule.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Rule with ID \(id) does not exist")
        }

        try await rule.delete(on: req.db)
        return .noContent
    }

    /// Delete multiple rules based off of a JSON body array of UUID strings
    func deleteMany(req: Request) async throws -> HTTPStatus {
        let toDelete = try req.content.decode([UUID].self)

        guard !toDelete.isEmpty else {
            throw Abort(.badRequest, reason: "Please provide at least 1 ID to delete")
        }

        guard toDelete.count <= 100 else {
            throw Abort(.badRequest, reason: "You cannot delete more than 100 rules at once")
        }

        try await Rule.query(on: req.db)
            .filter(\.$id ~~ toDelete)
            .delete()

        return .noContent
    }
}
