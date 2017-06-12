import Foundation

enum LocationProviderError: Error {
	case wrongSerialization(String)
	case privateRangeIP(String)
}

final class LocationProvider: Requestable {
	
	typealias Response = LocationJSONResponse

	private let ip: String
	var path: String {
		return "http://ip-api.com/json/\(ip)"
	}

	init(ip: String) {
		self.ip = ip
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
 
			guard let data = data, 
				 error == nil else {
				errorHandler(error!)
				return
			}
			guard let json = try? JSONSerialization.jsonObject(with: data),
				  let response = try? LocationJSONResponse.decode(json) else {
				  	errorHandler(LocationProviderError.wrongSerialization("Parsing gone wrong"))
				  	return
				  }

			guard response.success else {
				errorHandler(LocationProviderError.privateRangeIP("Provided IP is from private range"))
				return
			}
			successHandler(response)
		}
		.resume()
	}
}
