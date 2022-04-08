import Foundation

struct NasaMetadata: Codable, Hashable, Equatable {
    let location: URL?
    
    private enum CodingKeys: String, CodingKey {
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        
        if let locationString: String = try? container.decode(String?.self, forKey: .location),
           let location: URL = .init(string: locationString) {
            self.location = location
        } else {
            self.location = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location)
    }
    
    static func ==(lhs: NasaMetadata, rhs: NasaMetadata) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
