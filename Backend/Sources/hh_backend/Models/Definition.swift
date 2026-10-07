//
//  Definition.swift
//  hh_backend
//
//  Created by Morgan Jones on 07/10/2026.
//

import Fluent
import Vapor

final class Definition: Model, Content, @unchecked Sendable {
    static let schema = "definitions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "words")
    var words: [String]

    @Field(key: "definition")
    var definition: String

    @OptionalField(key: "additional_notes")
    var additionalNotes: [String]?

    init() { }

    init(id: UUID? = nil, words: [String], definition: String, additionalNotes: [String]? = nil) {
        self.id = id
        self.words = words
        self.definition = definition
        self.additionalNotes = additionalNotes
    }

    func validate() throws {
        // Title validation
        guard !words.isEmpty else {
            throw Abort(.badRequest, reason: "`words` array cannot be empty")
        }

        for (idx, word) in words.enumerated() {
            guard word.count >= 2 else {
                throw Abort(.badRequest, reason: "`words[\(idx)]` must be at least 2 characters")
            }

            guard word.count <= 50 else {
                throw Abort(.badRequest, reason: "`words[\(idx)]` cannot exceed 50 characters")
            }
        }

        // Description validation
        guard !definition.isEmpty else {
            throw Abort(.badRequest, reason: "`definition` cannot be empty")
        }

        guard definition.count >= 30 else {
            throw Abort(.badRequest, reason: "`definition` must be at least 30 characters")
        }

        guard definition.count <= 750 else {
            throw Abort(.badRequest, reason: "`definition` cannot exceed 750 characters")
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
