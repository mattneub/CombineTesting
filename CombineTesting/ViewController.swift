
import UIKit
import Combine


class ViewController: UIViewController {
    // Output is (data: Data, response: URLResponse)
    // Failure is URLError
    typealias DTP = AnyPublisher <
        URLSession.DataTaskPublisher.Output,
        URLSession.DataTaskPublisher.Failure
    >

    var image : UIImage?
    var storage = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey:"TESTING") {
            return
        }
        let url = URL(string:"https://www.apeth.com/pep/manny.jpg")!
        // self.getImageNaive(url:url)
        self.getImage(url:url)
    }
    // this is not testable
    func getImageNaive(url:URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { UIImage(data:$0.data) }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] image in
                print(image)
                self?.image = image
            }
            .store(in: &self.storage)
    }
    // but this is, because we can "inject" a test publisher
    func getImage(url:URL) {
        let pub = URLSession.shared.dataTaskPublisher(for: url).eraseToAnyPublisher()
        self.createPipelineFromPublisher(pub: pub)
    }
    func createPipelineFromPublisher(pub: DTP) {
        pub
            .compactMap { UIImage(data:$0.data) }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] image in
                print(image)
                self?.image = image
            }
            .store(in: &self.storage)
    }
}

