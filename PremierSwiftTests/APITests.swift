import XCTest
@testable import PremierSwift

final class APITests: XCTestCase {
    func test_url_queryParams() {
        let queryItem = URLQueryItem(name: "testName", value: "testValue")
        let url = URL(string: "https://deliveroo.co.uk")!.url(with: [queryItem])
        XCTAssertEqual(url.absoluteString, "https://deliveroo.co.uk?testName=testValue")
    }
    
    func test_full_url_builder() {
        let request: Request<Movie> = Request(method: .get, path: "/testing", pars: [:])
        let url = URL("https://deliveroo.co.uk", "testKey", request)
        XCTAssertEqual(url.absoluteString, "https://deliveroo.co.uk/testing?api_key=testKey")
    }
    
    func test_search_request() {
        let movie_request = Request<[Movie]>(method: Method.get, path: "/search/movie", pars: ["query": "test"])
        let request_url = URL(APIManager.shared.host, APIManager.shared.apiKey, movie_request)
        XCTAssertEqual(request_url.absoluteString, "https://api.themoviedb.org/3/search/movie?api_key=e4f9e61f6ffd66639d33d3dde7e3159b&query=test")
        
        APIManager.shared.execute(movie_request, completion: { result in
            if case .success(let movies) = result {
                XCTAssertTrue(movies.count > 0)
            }
        })
    }
}
