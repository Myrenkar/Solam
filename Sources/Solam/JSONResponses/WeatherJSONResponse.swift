import Foundation

#if os(Linux)
    enum WeatherJSONResponseError: Error {
        case wrongStruct
    }
#else
    import Decodable
#endif

struct WeatherJSONResponse {
	let sky: String
	let temperature: Double
	let presure: Double
	let humidity: Double
}

extension WeatherJSONResponse: CustomStringConvertible {
	var description: String {
		return "\(sky) with \(temperature) ℃ | \(presure) hPa | humidity: \(humidity)"
	}	
}

#if os(Linux)
	extension WeatherJSONResponse {
        static func decode(_ json: Any) throws -> WeatherJSONResponse {

            guard
                  let json = json as? [String: Any?],
                  let weather = json["weather"] as? [[String: Any?]],
           		  let sky = weather[0]["description"] as? String ,
                  let main = json["main"] as? [String: Any?],
                  let temperature = main["temp"] as? Int,
                  let pressure = main["pressure"] as? Int,
                  let humidity = main["humidity"] as? Int
            else {
                throw WeatherJSONResponseError.wrongStruct
    		}

            return WeatherJSONResponse(
                sky: sky,
                temperature: Double(temperature),
				presure: Double(pressure),
				humidity: Double(humidity)
            )
        }
    }
#else
extension WeatherJSONResponse: Decodable {
	static func decode(_ json: Any) throws -> WeatherJSONResponse {
		return try WeatherJSONResponse(
				sky: (json => "weather" as! Array<AnyObject>)[0] => "description",
				temperature: json => "main" => "temp",
				presure: json => "main" => "pressure",
				humidity: json => "main" => "humidity"
			)
	}
}
#endif
