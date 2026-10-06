//
//  CreateRule.swift
//  hh_backend
//
//  Created by Morgan Jones on 06/10/2026.
//

import Fluent
import FluentSQL

struct CreateRule: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("rules")
            .id()
            .field("title", .string, .required)
            .field("description", .sql(unsafeRaw: "TEXT"), .required)
            .field("additional_notes", .json)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("rules").delete()
    }
}
