import Foundation

extension TaskGroup {
    var allValues: [Element] {
        get async {
            await reduce(into: [Element]()) { partialResult, element in
                partialResult.append(element)
            }
        }
    }
}
