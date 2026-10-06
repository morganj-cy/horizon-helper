import Vapor
import Foundation

/// Manages and validates all environment configuration
struct AppConfiguration {
    let database: DatabaseConfiguration
    let server: ServerConfiguration

    /// Environment variables to connect to the database
    struct DatabaseConfiguration {
        let hostname: String
        let port: Int
        let username: String
        let password: String
        let database: String

        var isValid: Bool {
            !hostname.isEmpty && !username.isEmpty && !database.isEmpty
        }
    }

    struct ServerConfiguration {
        let logLevel: Logger.Level
        let environment: String

        var isDev: Bool {
            environment.lowercased() != "production"
        }
    }

    // The required environment variable keys
    private static let requiredKeys: Set<String> = [
        "DB_HOST",
        "DB_PORT",
        "DB_USER",
        "DB_PASSWORD",
        "DB_NAME",
        "LOG_LEVEL",
        "ENV"
    ]

    /// Load and validate configuration from environment variables
    static func load(logger: Logger) throws -> AppConfiguration {
        logger.info("Loading and validating environment configuration...")

        // Validate that all required variables exist
        try validateEnvironment(logger: logger)

        // Database configuration
        guard let dbHost = Environment.get("DB_HOST") else {
            throw ConfigurationError.missingEnvironmentVariable("DB_HOST")
        }

        guard let dbUser = Environment.get("DB_USER") else {
            throw ConfigurationError.missingEnvironmentVariable("DB_USER")
        }

        guard let dbPassword = Environment.get("DB_PASSWORD") else {
            throw ConfigurationError.missingEnvironmentVariable("DB_PASSWORD")
        }

        guard let dbName = Environment.get("DB_NAME") else {
            throw ConfigurationError.missingEnvironmentVariable("DB_NAME")
        }

        guard let dbPortString = Environment.get("DB_PORT"),
              let dbPort = Int(dbPortString) else {
            throw ConfigurationError.invalidEnvironmentVariable("DB_PORT", "Must be a valid integer")
        }

        let databaseConfig = DatabaseConfiguration(
            hostname: dbHost,
            port: dbPort,
            username: dbUser,
            password: dbPassword,
            database: dbName
        )

        guard databaseConfig.isValid else {
            throw ConfigurationError.invalidConfiguration("Database configuration is invalid")
        }

        // Server configuration
        let environment = Environment.get("ENV") ?? "development"
        let logLevelString = Environment.get("LOG_LEVEL") ?? "info"
        let logLevel = Logger.Level(rawValue: logLevelString) ?? .info

        let serverConfig = ServerConfiguration(
            logLevel: logLevel,
            environment: environment
        )

        logger.info("Environment loaded.")

        return AppConfiguration(
            database: databaseConfig,
            server: serverConfig
        )
    }

    /// Validate that all required environment variables are present
    private static func validateEnvironment(logger: Logger) throws {
        var missingKeys: [String] = []

        for key in requiredKeys {
            if Environment.get(key) == nil {
                missingKeys.append(key)
            }
        }

        if !missingKeys.isEmpty {
            let plural = missingKeys.count != 1
            let message = "Missing environment variable\(plural ? "s" : ""): \(missingKeys.joined(separator: ", "))"
            logger.critical("\(message)")
            throw ConfigurationError.missingEnvironmentVariables(missingKeys)
        }
    }
}

/// Errors related to ApplicationConfiguration
enum ConfigurationError: Error, CustomStringConvertible {
    case missingEnvironmentVariable(String)
    case missingEnvironmentVariables([String])
    case invalidEnvironmentVariable(String, String)
    case invalidConfiguration(String)

    var description: String {
        switch self {
            case .missingEnvironmentVariable(let key):
                return "Missing required environment variable: \(key)"
            case .missingEnvironmentVariables(let keys):
                return "Missing required environment variables: \(keys.joined(separator: ", "))"
            case .invalidEnvironmentVariable(let key, let reason):
                return "Invalid environment variable '\(key)': \(reason)"
            case .invalidConfiguration(let message):
                return "Invalid configuration: \(message)"
        }
    }
}

// Extension to store config in Application
extension Application {
    struct ConfigurationKey: StorageKey {
        typealias Value = AppConfiguration
    }

    var config: AppConfiguration {
        get {
            guard let config = self.storage[ConfigurationKey.self] else {
                fatalError("AppConfiguration not set. Call app.config = try AppConfiguration.load(logger:) in configure.swift")
            }
            return config
        }
        set {
            self.storage[ConfigurationKey.self] = newValue
        }
    }
}
