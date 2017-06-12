import Foundation

protocol Requestable {

	associatedtype Response

	var path: String { get }
	func request(successHandler: @escaping (Response) -> Void, errorHandler: @escaping (Error) -> Void)
}
