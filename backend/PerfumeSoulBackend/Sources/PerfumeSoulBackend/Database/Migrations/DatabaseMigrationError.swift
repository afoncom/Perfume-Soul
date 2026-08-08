enum DatabaseMigrationError: Error {
    case sqlDatabaseIsRequired
    case missingEnglishNoteNames([String])
}
