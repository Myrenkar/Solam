import Foundation

enum WeatherProviderError: Error {
	case wrongSerialization(String)
}

final class WeatherProvider: Requestable {
	
	typealias Response = WeatherJSONResponse

	private let city: String
	private let countryCode: String
	private let key = "1202c8b8a1099bacc23dedc2f4cb301d"
	var path: String {
		return "http://api.openweathermap.org/data/2.5/weather?q=\(city),\(countryCode)&appid=\(key)&units=metric"
	}

	init(city: String, countryCode: String) {
		self.city = city
		self.countryCode = countryCode
	}

	func request(successHandler: @escaping (Response) -> Void, errorHandler: @escaping (Error) -> Void) {
		let url = URL(string: path)!
		let request = URLRequest(url: url)
        
        #if os(Linux)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        #else
        let session = URLSession.shared
        #endif
        
        session.dataTask(with: request) { data, httpResponse, error in
 
			guard (httpResponse as! HTTPURLResponse).statusCode == 200, 
				  let data = data, 
				  error == nil else {
				errorHandler(error!)
				return
			}
			guard let json = try? JSONSerialization.jsonObject(with: data),
				  let response = try? WeatherJSONResponse.decode(json) else {
				  	errorHandler(WeatherProviderError.wrongSerialization("Parsing gone wrong"))
				  	return
				  }
			successHandler(response)
		}
		.resume()
	}
}
