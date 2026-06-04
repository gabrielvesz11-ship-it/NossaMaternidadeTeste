import Foundation

enum LocalPhotoStore {
    static func saveJPEGData(_ data: Data, entryID: String) throws -> URL {
        let directory = try journalDirectory()
        let url = directory.appendingPathComponent("\(entryID).jpg")
        try data.write(to: url, options: [.atomic])
        return url
    }

    static func url(from uri: String?) -> URL? {
        guard let uri else { return nil }
        return URL(string: uri) ?? URL(fileURLWithPath: uri)
    }

    private static func journalDirectory() throws -> URL {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = root.appendingPathComponent("JournalPhotos", isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}
