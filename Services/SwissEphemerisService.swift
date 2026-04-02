import Foundation

class SwissEphemerisService {
    static let shared = SwissEphemerisService()
    
    private var ephePath: String = ""
    
    private init() {
        setupEphemerisPath()
    }
    
    private func setupEphemerisPath() {
        if let bundlePath = Bundle.main.resourcePath {
            ephePath = bundlePath + "/ephe"
        } else {
            ephePath = "./ephe"
        }
        
        let result = swe_set_ephe_path(ephePath)
        if result == 0 {
            print("Swiss Ephemeris path set to: \(ephePath)")
        } else {
            print("Warning: Failed to set ephemeris path")
        }
    }
    
    func calculatePlanetPosition(planet: Planet, date: Date) -> PlanetPosition? {
        var tjd = dateToJulianDay(date)
        
        var xx: [Double] = [0, 0, 0, 0, 0, 0]
        var speed: [Double] = [0, 0, 0, 0, 0, 0]
        
        let iflag: Int32 = Int32(SEFLG_SPEED | SEFLG_EQUATORIAL | SEFLG_TOPOCENTRIC)
        
        var errorMessage: UnsafeMutablePointer<CChar>?
        
        let result = swe_calc_ut(tjd, planet.swissEphemerisIndex, iflag, &xx, &errorMessage)
        
        if result < 0 {
            if let error = errorMessage {
                print("Swiss Ephemeris error: \(String(cString: error))")
            }
            return nil
        }
        
        let longitude = xx[0]
        let latitude = xx[1]
        let speedValue = speed[0]
        
        return PlanetPosition(
            name: planet.name,
            longitude: longitude,
            latitude: latitude,
            speed: speedValue
        )
    }
    
    func calculateAllPlanetPositions(date: Date) -> [PlanetPosition] {
        var positions: [PlanetPosition] = []
        
        for planet in Planet.allCases {
            if let position = calculatePlanetPosition(planet: planet, date: date) {
                positions.append(position)
            }
        }
        
        return positions
    }
    
    func calculateAscendantMC(latitude: Double, longitude: Double, date: Date) -> (ascendant: Double, mc: Double)? {
        var tjd = dateToJulianDay(date)
        
        var ascmc: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        let hSys: Int32 = Int32(SE_HOUSE_PLACIDIUS)
        
        let result = swe_houses(tjd, latitude, longitude, hSys, &ascmc)
        
        if result < 0 {
            print("Failed to calculate houses")
            return nil
        }
        
        let asc = ascmc[0]
        let mc = ascmc[1]
        
        return (ascendant: asc, mc: mc)
    }
    
    private func dateToJulianDay(_ date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        var year = Int32(calendar.component(.year, from: date))
        var month = Int32(calendar.component(.month, from: date))
        var day = Int32(calendar.component(.day, from: date))
        
        let hour = Double(calendar.component(.hour, from: date))
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        
        let dayFraction = (hour + minute / 60.0 + second / 3600.0) / 24.0
        
        var tjd: Double = 0
        var errorMessage: UnsafeMutablePointer<CChar>?
        
        swe_julday(year, month, day, dayFraction, &tjd, &errorMessage)
        
        return tjd
    }
}