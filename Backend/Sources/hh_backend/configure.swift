import Vapor
import Fluent
import FluentMySQLDriver

/// Configures your application
func configure(_ app: Application) async throws {
    let config = try AppConfiguration.load(logger: app.logger)
    app.config = config

    app.logger.logLevel = config.server.logLevel

    let tlsConfig: TLSConfiguration? = config.server.isDev ? nil : .makeClientConfiguration()

    app.databases.use(.mysql(
        hostname: config.database.hostname,
        username: config.database.username,
        password: config.database.password,
        database: config.database.database,
        tlsConfiguration: tlsConfig
    ),
    as: .mysql)

    app.migrations.add(CreateRule())

    if app.environment == .development {
        try await app.autoMigrate()
    }

    // Register routes
    try routes(app)
}
