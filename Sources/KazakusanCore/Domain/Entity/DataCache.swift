import CoreData

@objc(DataCache)
public final class DataCache: NSManagedObject {
    @NSManaged public internal(set) var identity: String?
    @NSManaged public internal(set) var data: Data?
}
