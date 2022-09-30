import Foundation
import Combine
import SwiftUI

class WeatherViewModel: ObservableObject {
    
    @Published var weatherData: ResponseBody?
    @Published private(set) var isSearching = false
    
    private var weatherFetcher: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol) {
        weatherFetcher = service
    }
    
    init() {
        weatherFetcher = WeatherService(service: NetworkService())
    }
    
    private var searchTask: Task<Void, Never>?

   // @MainActor
    func load(for cityElement: CityElement) async {
        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            weatherData = await searchWeather(at: cityElement)
            isSearching = Task.isCancelled
        }
    }

    private func searchWeather(at city: CityElement) async -> ResponseBody? {
        do {
            let weatherResponse: ResponseBody = try await weatherFetcher.fetchWeatherData(by: city)
            print("Fetched response - ", weatherResponse.lat)
            return weatherResponse
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
