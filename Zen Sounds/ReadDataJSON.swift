//
//  ReadDataJSON.swift
//  Zen Sounds
//
//  Created by Arunya Goojar on 15/05/24.
//

import Foundation

struct Sound: Identifiable, Codable {
    enum CodingKeys : CodingKey{
        case title
        case location
        case imageName
        case audioURL
    }
    var id = UUID()
    var title: String
    var location: String
    var imageName: String
    var audioURL: String
}

class ReadDataJSON: ObservableObject {
    @Published var sounds = [Sound]()
    
    init() {
        loadData()
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json")
        else {
            print("Data Fetch Error")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let sounds = try JSONDecoder().decode([Sound].self, from: data)
            self.sounds = sounds
        } catch {
            print("Error decoding JSON: \(error)") 
        }
    }
}
