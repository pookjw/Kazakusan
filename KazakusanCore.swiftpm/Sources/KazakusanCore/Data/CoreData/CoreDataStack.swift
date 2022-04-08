import Foundation
import CoreData

@globalActor actor CoreDataStack {
    static let shared: CoreDataStack = .init()
}
