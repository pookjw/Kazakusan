import Foundation

public struct NasaAsset: Codable, Hashable, Equatable {
    public let collection: Collection?
    
    private enum CodingKeys: String, CodingKey {
        case collection
    }
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.collection = try? container.decode(Collection.self, forKey: .collection)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(collection, forKey: .collection)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(collection?.hashValue)
    }
    
    public static func ==(lhs: NasaAsset, rhs: NasaAsset) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public extension NasaAsset {
    struct Collection: Codable, Hashable, Equatable {
        public let version: String?
        public let href: URL?
        public let items: [Item]?
        public let metadata: MetaData?
        public let links: [Link]?
        
        private enum CodingKeys: String, CodingKey {
            case version, href, items, metadata, links
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.version = try? container.decode(String?.self, forKey: .version)
            
            if let hrefString: String = try container.decode(String?.self, forKey: .href),
               let href: URL = .init(string: hrefString) {
                self.href = href
            } else {
                self.href = nil
            }
            
            self.items = try? container.decode([Item]?.self, forKey: .items)
            self.metadata = try? container.decode(MetaData?.self, forKey: .metadata)
            self.links = try? container.decode([Link]?.self, forKey: .links)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(version, forKey: .version)
            try container.encode(href, forKey: .href)
            try container.encode(items, forKey: .items)
            try container.encode(metadata, forKey: .metadata)
            try container.encode(links, forKey: .links)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(version.hashValue)
            hasher.combine(href.hashValue)
            hasher.combine(items.hashValue)
            hasher.combine(metadata?.hashValue)
        }
        
        public static func ==(lhs: Collection, rhs: Collection) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}

public extension NasaAsset {
    struct Item: Codable, Hashable, Equatable {
        public let href: URL?
        public let data: [Item.Data]?
        public let links: [Link]?
        
        private enum CodingKeys: String, CodingKey {
            case href, data, links
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            if let hrefString: String = try? container.decode(String?.self, forKey: .href),
                let href: URL = .init(string: hrefString) {
                self.href = href
            } else {
                self.href = nil
            }
            
            self.data = try? container.decode([Item.Data]?.self, forKey: .data)
            self.links = try? container.decode([Link]?.self, forKey: .links)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(href, forKey: .href)
            try container.encode(data, forKey: .data)
            try container.encode(links, forKey: .links)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(href.hashValue)
            hasher.combine(data.hashValue)
        }
        
        public static func ==(lhs: Item, rhs: Item) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}

public extension NasaAsset.Item {
    struct Data: Codable, Hashable, Equatable {
        public enum MediaType: String {
            case image, video, audio
        }
        
        public let description: String?
        public let title: String?
        public let photographer: String?
        public let keywords: [String]?
        public let location: String?
        public let nasaId: String?
        public let mediaType: MediaType?
        public let dateCreated: Date?
        public let center: String?
        
        private enum CodingKeys: String, CodingKey {
            case description, title, photographer, keywords, location, nasa_id, media_type, date_created, center
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.description = try? container.decode(String?.self, forKey: .description)
            self.title = try? container.decode(String?.self, forKey: .title)
            self.photographer = try? container.decode(String?.self, forKey: .photographer)
            self.keywords = try? container.decode([String]?.self, forKey: .keywords)
            self.location = try? container.decode(String?.self, forKey: .location)
            self.nasaId = try? container.decode(String?.self, forKey: .nasa_id)
            
            if let mediaTypeString: String = try? container.decode(String?.self, forKey: .media_type),
               let mediaType: MediaType = .init(rawValue: mediaTypeString) {
                self.mediaType = mediaType
            } else {
                self.mediaType = nil
            }
            
            if let dateCreatedString: String = try? container.decode(String?.self, forKey: .date_created),
               let dateCreated: Date = ISO8601DateFormatter().date(from: dateCreatedString) {
               self.dateCreated = dateCreated
            } else {
                self.dateCreated = nil
            }
            
            self.center = try? container.decode(String?.self, forKey: .center)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(description, forKey: .description)
            try container.encode(title, forKey: .title)
            try container.encode(photographer, forKey: .photographer)
            try container.encode(keywords, forKey: .keywords)
            try container.encode(location, forKey: .location)
            try container.encode(nasaId, forKey: .nasa_id)
            try container.encode(mediaType?.rawValue, forKey: .media_type)
            try container.encode(dateCreated, forKey: .date_created)
            try container.encode(center, forKey: .center)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(description.hashValue)
            hasher.combine(title.hashValue)
            hasher.combine(photographer.hashValue)
            hasher.combine(keywords.hashValue)
            hasher.combine(location.hashValue)
            hasher.combine(nasaId.hashValue)
            hasher.combine(mediaType.hashValue)
        }
        
        public static func ==(lhs: Data, rhs: Data) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}

public extension NasaAsset.Item {
    struct Link: Codable, Hashable, Equatable {
        public let href: URL?
        public let rel: String?
        public let render: String?
        
        private enum CodingKeys: String, CodingKey {
            case href, rel, render
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            if let hrefString: String = try? container.decode(String?.self, forKey: .href),
               let href: URL = .init(string: hrefString) {
                self.href = href
            } else {
                self.href = nil
            }
            
            self.rel = try? container.decode(String?.self, forKey: .rel)
            self.render = try? container.decode(String?.self, forKey: .render)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(href, forKey: .href)
            try container.encode(rel, forKey: .rel)
            try container.encode(render, forKey: .render)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(href)
            hasher.combine(rel)
            hasher.combine(render)
        }
    }
}

public extension NasaAsset {
    struct MetaData: Codable, Hashable, Equatable {
        public let totalHits: UInt?
        
        private enum CodingKeys: String, CodingKey {
            case total_hits
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.totalHits = try? container.decode(UInt?.self, forKey: .total_hits)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(totalHits, forKey: .total_hits)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(totalHits?.hashValue)
        }
        
        public static func ==(lhs: MetaData, rhs: MetaData) -> Bool {
            return lhs.totalHits == rhs.totalHits
        }
    }
}

public extension NasaAsset {
    struct Link: Codable, Hashable, Equatable {
        public let rel: String?
        public let prompt: String?
        public let href: URL?
        
        private enum CodingKeys: String, CodingKey {
            case rel, prompt, href
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.rel = try? container.decode(String?.self, forKey: .rel)
            self.prompt = try? container.decode(String?.self, forKey: .prompt)
            
            if let hrefString: String = try? container.decode(String?.self, forKey: .href),
               let href: URL = .init(string: hrefString) {
                self.href = href
            } else {
                self.href = nil
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(rel, forKey: .rel)
            try container.encode(prompt, forKey: .prompt)
            try container.encode(href, forKey: .href)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rel.hashValue)
            hasher.combine(prompt.hashValue)
            hasher.combine(href.hashValue)
        }
        
        public static func ==(lhs: Link, rhs: Link) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}
