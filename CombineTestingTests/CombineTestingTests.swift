

import XCTest
import Combine
@testable import CombineTesting

class CombineTestingTests: XCTestCase {
    func mockDataTaskPublisher(publishing data: Data) -> ViewController.DTP {
        let fakeResult = (data, URLResponse())
        let j = Just<URLSession.DataTaskPublisher.Output>(fakeResult)
            .setFailureType(to: URLSession.DataTaskPublisher.Failure.self)
        return j.eraseToAnyPublisher()
    }
    
    let mockDataTaskPublisherSubject = PassthroughSubject<
        URLSession.DataTaskPublisher.Output,
        URLSession.DataTaskPublisher.Failure
    >()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImagePipeline() throws {
        let vc = ViewController()
        let mannyTesting = UIImage(named: "mannyTesting", in: Bundle(for: Self.self), compatibleWith: nil)!
        let data = mannyTesting.pngData()!
        let pub = mockDataTaskPublisher(publishing: data)
        vc.createPipelineFromPublisher(pub: pub)
        let pred = NSPredicate { vc, _ in (vc as? ViewController)?.image != nil }
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: vc)
        self.wait(for: [expectation], timeout: 2)
        let image = try XCTUnwrap(vc.image, "The image is nil")
        XCTAssertEqual(data, image.pngData()!, "The image is the wrong image")
    }
    
    func testImagePipeline2() throws {
        let vc = ViewController()
        let data = Data()
        let pub = mockDataTaskPublisher(publishing: data)
        vc.createPipelineFromPublisher(pub: pub)
        let pred = NSPredicate { vc, _ in (vc as? ViewController)?.image != nil }
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: vc)
        expectation.isInverted = true
        self.wait(for: [expectation], timeout: 2)
        XCTAssertNil(vc.image, "The image isn't nil")
    }

    func testImagePipeline3() throws {
        let vc = ViewController()
        let mannyTesting = UIImage(named: "mannyTesting", in: Bundle(for: Self.self), compatibleWith: nil)!
        let data = mannyTesting.pngData()!
        let pub = self.mockDataTaskPublisherSubject.eraseToAnyPublisher()
        vc.createPipelineFromPublisher(pub: pub)
        let tuple = (data, URLResponse())
        self.mockDataTaskPublisherSubject.send(tuple) // same reference as pub
        let pred = NSPredicate { vc, _ in (vc as? ViewController)?.image != nil }
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: vc)
        self.wait(for: [expectation], timeout: 2)
        let image = try XCTUnwrap(vc.image, "The image is nil")
        XCTAssertEqual(data, image.pngData()!, "The image is the wrong image")
    }
    
    func testImagePipeline4() throws {
        let vc = ViewController()
        let pub = self.mockDataTaskPublisherSubject.eraseToAnyPublisher()
        vc.createPipelineFromPublisher(pub: pub)
        self.mockDataTaskPublisherSubject.send(completion: .failure(URLError(.badURL)))
        let pred = NSPredicate { vc, _ in (vc as? ViewController)?.image != nil }
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: vc)
        expectation.isInverted = true
        self.wait(for: [expectation], timeout: 2)
        XCTAssertNil(vc.image, "The image isn't nil")
    }


}
