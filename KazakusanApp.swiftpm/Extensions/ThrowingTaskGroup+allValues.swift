import Foundation

extension ThrowingTaskGroup {
    var allValues: [Element] {
        get async throws {
            try await reduce(into: [Element]()) { partialResult, element in
                partialResult.append(element)
            }
        }
    }
}
