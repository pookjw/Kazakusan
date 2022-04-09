//
//  File.swift
//  
//
//  Created by Jinwoo Kim on 4/9/22.
//

import CoreData

final class DataCache: NSManagedObject {
    @NSManaged var identity: String
    @NSManaged var data: Data
}
