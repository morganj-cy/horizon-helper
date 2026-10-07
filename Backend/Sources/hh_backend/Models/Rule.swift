//
//  Rule.swift
//  hh_backend
//
//  Created by Morgan Jones on 06/10/2026.
//

import Fluent
import Vapor

final class Rule: Model, Content, @unchecked Sendable {
    static let schema = "rules"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @OptionalField(key: "additional_notes")
    var additionalNotes: [String]?

    init() { }

    init(title: String, description: String, additionalNotes: [String]? = nil) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if let notes = additionalNotes {
            for note in notes {
                self.additionalNotes = []
                self.additionalNotes?
                    .append(note.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    func validate() throws {
        // Title validation
        guard !title.isEmpty else {
            throw Abort(.badRequest, reason: "`title` cannot be empty")
        }

        guard title.count >= 6 else {
            throw Abort(.badRequest, reason: "`title` must be at least 6 characters")
        }

        guard title.count <= 100 else {
            throw Abort(.badRequest, reason: "`title` cannot exceed 100 characters")
        }

        // Description validation
        guard !description.isEmpty else {
            throw Abort(.badRequest, reason: "`description` cannot be empty")
        }

        guard description.count >= 30 else {
            throw Abort(.badRequest, reason: "`description` must be at least 30 characters")
        }

        guard description.count <= 750 else {
            throw Abort(.badRequest, reason: "`description` cannot exceed 750 characters")
        }

        // Additional notes validation
        if let notes = additionalNotes {
            guard notes.count <= 6 else {
                throw Abort(.badRequest, reason: "`additionalNotes` cannot contain more than 6 elements")
            }

            for (idx, note) in notes.enumerated() {
                guard !note.isEmpty else {
                    throw Abort(.badRequest, reason: "`additionalNotes[\(idx)]` cannot be empty")
                }

                guard note.count >= 10 else {
                    throw Abort(.badRequest, reason: "`additionalNotes[\(idx)]` must be at least 10 characters")
                }

                guard note.count <= 300 else {
                    throw Abort(.badRequest, reason: "`additionalNotes[\(idx)]` cannot exceed 300 characters")
                }
            }
        }
    }
}
