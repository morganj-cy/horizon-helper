//
//  CreateDefinition.swift
//  hh_backend
//
//  Created by Morgan Jones on 07/10/2026.
//

import Fluent
import FluentSQL

struct CreateDefinition: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("definitions")
            .id()
            .field("words", .json, .required)
            .field("definition", .sql(unsafeRaw: "TEXT"), .required)
            .field("additional_notes", .json)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("definitions").delete()
    }
}
