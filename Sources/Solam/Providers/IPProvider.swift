import Foundation

enum IPProviderError: Error {
	case missingIP(String)
}

final class IPProvider: Requestable {
	
	typealias Response = String

	var path: String {
		return "https://icanhazip.com/"
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

			guard let ip = String(data: data, encoding: .utf8) else {
				errorHandler(IPProviderError.missingIP("External service could not establish your IP."))
				return
			}
			successHandler(ip.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
		}
		.resume()
	}
}
