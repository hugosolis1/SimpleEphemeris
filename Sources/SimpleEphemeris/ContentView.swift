import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var latitude: Double = 40.7128
    @State private var longitude: Double = -74.0060
    @State private var planetPositions: [PlanetPosition] = []
    @State private var ascendant: Double = 0
    @State private var mc: Double = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                dateSelector
                coordinatesSection
                calculateButton
                if isLoading {
                    ProgressView("Calculating...")
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    resultsList
                }
            }
            .navigationTitle("Simple Ephemeris")
            .onAppear {
                calculatePositions()
            }
        }
    }
    
    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date & Time")
                .font(.headline)
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .onChange(of: selectedDate) { _ in
                    calculatePositions()
                }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var coordinatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("Latitude")
                    TextField("Latitude", value: $latitude, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                VStack(alignment: .leading) {
                    Text("Longitude")
                    TextField("Longitude", value: $longitude, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
            }
            .onChange(of: latitude) { _ in calculatePositions() }
            .onChange(of: longitude) { _ in calculatePositions() }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var calculateButton: some View {
        Button(action: calculatePositions) {
            Text("Calculate")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var resultsList: some View {
        List {
            Section("Planets") {
                ForEach(planetPositions) { position in
                    PlanetRow(position: position)
                }
            }
            
            Section("Angles") {
                AngleRow(title: "Ascendant", value: ascendant)
                AngleRow(title: "Medium Coeli (MC)", value: mc)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func calculatePositions() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            let ephemeris = SwissEphemerisService.shared
            
            var positions = ephemeris.calculateAllPlanetPositions(date: selectedDate)
            
            if let houseData = ephemeris.calculateAscendantMC(latitude: latitude, longitude: longitude, date: selectedDate) {
                let ascPosition = PlanetPosition(name: "Ascendant", longitude: houseData.ascendant, latitude: 0, speed: 0)
                let mcPosition = PlanetPosition(name: "Medium Coeli", longitude: houseData.mc, latitude: 0, speed: 0)
                
                positions.append(ascPosition)
                positions.append(mcPosition)
            }
            
            DispatchQueue.main.async {
                self.planetPositions = positions.filter { $0.name != "Ascendant" && $0.name != "Medium Coeli" }
                if let houseData = ephemeris.calculateAscendantMC(latitude: latitude, longitude: longitude, date: selectedDate) {
                    self.ascendant = houseData.ascendant
                    self.mc = houseData.mc
                }
                self.isLoading = false
            }
        }
    }
}

struct PlanetRow: View {
    let position: PlanetPosition
    
    var body: some View {
        HStack {
            Text(position.name)
                .font(.body)
            Spacer()
            Text(position.formattedLongitude)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct AngleRow: View {
    let title: String
    let value: Double
    
    var formattedValue: String {
        let sign = value < 0 ? "-" : ""
        let deg = Int(abs(value))
        let min = Int((abs(value) - Double(deg)) * 60)
        let sec = ((abs(value) - Double(deg)) * 60 - Double(min)) * 60
        return String(format: "%@%d° %d' %.2f\"", sign, deg, min, sec)
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(formattedValue)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}