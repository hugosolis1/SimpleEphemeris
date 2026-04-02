import Foundation

struct PlanetPosition: Identifiable {
    let id = UUID()
    let name: String
    let longitude: Double
    let latitude: Double
    let speed: Double
    
    var formattedLongitude: String {
        let sign = longitude < 0 ? "-" : ""
        let deg = Int(abs(longitude))
        let min = Int((abs(longitude) - Double(deg)) * 60)
        let sec = ((abs(longitude) - Double(deg)) * 60 - Double(min)) * 60
        return String(format: "%@%d° %d' %.2f\"", sign, deg, min, sec)
    }
    
    var formattedSpeed: String {
        let sign = speed >= 0 ? "+" : ""
        return String(format: "%@%.4f°/day", sign, speed)
    }
}

enum Planet: Int, CaseIterable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6
    case uranus = 7
    case neptune = 8
    case pluto = 9
    case northNode = 10
    case southNode = 11
    
    var name: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .northNode: return "North Node"
        case .southNode: return "South Node"
        }
    }
    
    var swissEphemerisIndex: Int32 {
        switch self {
        case .sun: return 0
        case .moon: return 1
        case .mercury: return 2
        case .venus: return 3
        case .mars: return 4
        case .jupiter: return 5
        case .saturn: return 6
        case .uranus: return 7
        case .neptune: return 8
        case .pluto: return 9
        case .northNode, .southNode: return 10 // True Node
        }
    }
}