import Foundation

#if os(Linux)
    enum LocationJSONResponseError: Error {
        case wrongStruct
    }
#else
    import Decodable
#endif

struct LocationJSONResponse {
	let countryCode: String?
	let city: String?
	let success: Bool
}

#if os(Linux)
    extension LocationJSONResponse {
        static func decode(_ json: Any) throws -> LocationJSONResponse {
            guard let json = json as? [String: Any?],
                  let success = json["status"] as? String,
                  let countryCode = json["countryCode"] as? String,
                  let city = json["city"] as? String
            else {
                throw LocationJSONResponseError.wrongStruct
            }
            
            return LocationJSONResponse(
                countryCode: countryCode,
                city: city,
                success: success == "success"
            )
        }
    }
#else
    extension LocationJSONResponse: Decodable {
        static func decode(_ json: Any) throws -> LocationJSONResponse {
            var success = false
            if let jsonSuccess = (try json => "status") as? String {
                success = jsonSuccess == "success"
            }
            return try LocationJSONResponse(
                countryCode: json =>? "countryCode" ,
                city: json =>? "city",
                success: success
            )
        }
    }
#endif
