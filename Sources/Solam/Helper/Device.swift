import Foundation
import ifaddrs

class Device {

	static var wifiAddress: String? {
	    var address : String?

	    var ifaddr: UnsafeMutablePointer<ifaddrs>?
	    guard getifaddrs(&ifaddr) == 0 else { return nil }
	    guard let firstAddr = ifaddr else { return nil }

	    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
	        let interface = ifptr.pointee

	        let addrFamily = interface.ifa_addr.pointee.sa_family

	        #if os(Linux)
	        let afInet = UInt16(AF_INET)
	        let afInet6 = UInt16(AF_INET6)
	        let expectedInterfaceName = "enp0s3"
	        #else
	        let afInet = UInt8(AF_INET)
	        let afInet6 = UInt8(AF_INET6)
	        let expectedInterfaceName = "en0"
	        #endif

	        if addrFamily == afInet || addrFamily == afInet6 {
	        
	            // Check interface name:
	            let name = String(cString: interface.ifa_name)
	            if  name == expectedInterfaceName {

	                // Convert interface address to a human readable string:
	                var addr = interface.ifa_addr.pointee
	                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

	                #if os(Linux)
					let addressLength = addrFamily == afInet ? INET_ADDRSTRLEN : INET6_ADDRSTRLEN
			        #else
			       	let addressLength = addr.sa_len
			        #endif

	                getnameinfo(&addr, socklen_t(addressLength),
	                            &hostname, socklen_t(hostname.count),
	                            nil, socklen_t(0), NI_NUMERICHOST)
	                address = String(cString: hostname)
	            }
	        }
	    }
	    freeifaddrs(ifaddr)

	    return address
	}
}
