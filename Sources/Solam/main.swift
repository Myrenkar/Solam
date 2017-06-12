import Foundation

#if os(Linux)
import Dispatch
#endif

print("Do you want to tell me what's your IP? Press enter if not.")
let providedIP = readLine()

if providedIP == Device.wifiAddress {
    print("Correct this is your internal IP but I wont use it.")
} else {
    print("No it isn't. Your IP is \(Device.wifiAddress ?? "Not founded" )")
}

let queue = DispatchQueue(label: "location", attributes: .concurrent)
let group = DispatchGroup()

func show(error: Error) {
	print(error)
	group.leave()
}

func show(info message: String) {
	print(message)
	group.leave()
}

/// Request weather from openweatherapi.org based on a city name and a country code
let weatherRequest: (String, String) -> Void = { city, countryCode in
	
	let weatherProvider = WeatherProvider(city: city, countryCode: countryCode)
	weatherProvider.request(successHandler: { response in
		let weatherDescription = response.description
		do {
			try OutputWriter.write(weatherDescription)
			print("Weather saved in \(OutputWriter.savePath)")
		} catch let e {
			print(e)
		}
		show(info: weatherDescription)
	}, errorHandler: {error in
		show(error: error)
	})
}

/// Request location from ip-api.com based on your external IP
let locationRequest: (String) -> Void = { ip in
	let locationProvider = LocationProvider(ip: ip)
	locationProvider.request(successHandler: { response in

		let city =  response.city ?? ""
		let countryCode =  response.countryCode ?? ""

		print("Getting weather for \(city) in \(countryCode)...\r")
		weatherRequest(city, countryCode)
		

	}, errorHandler: { error in
		show(error: error)
	})
}

/// Request IP from icanhazip.com
let ipRequest: () -> Void = {
	let ipProvider = IPProvider()
	ipProvider.request(successHandler: { response in
		print("Getting your location for \(response)... \r")
		locationRequest(response)
	}, errorHandler: { error in 
		show(error: error)
	})
}

group.enter()
queue.async(group: group) {

	let timeout = DispatchTime.now() + .seconds(1)
	let _ = group.wait(timeout: timeout)

	ipRequest()

}

group.notify(queue: queue) {
	exit(0)
}

dispatchMain()
