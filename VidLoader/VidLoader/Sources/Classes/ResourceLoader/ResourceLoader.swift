import AVFoundation

struct ResourceLoaderObserver {
    let taskDidFail: Completion<ResourceLoadingError>
    let keyDidLoad: () -> Void
    
    init(taskDidFail: @escaping Completion<ResourceLoadingError>,
         keyDidLoad: @escaping () -> Void) {
        self.taskDidFail = taskDidFail
        self.keyDidLoad = keyDidLoad
    }
}

final class ResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    let queue = DispatchQueue(label: "com.vidloader.resource_loader_dispatch_url")
    private let observer: ResourceLoaderObserver
    private let parser: Parser
    private let streamResource: StreamResource
    private let requestable: Requestable
    private var didProvideFirstResponse = false
    private let schemeHandler: SchemeHandleable
    
    init(observer: ResourceLoaderObserver,
         streamResource: StreamResource,
         parser: Parser = M3U8Parser(),
         requestable: Requestable = URLSession.shared,
         schemeHandler: SchemeHandleable = SchemeHandler.init()) {
        self.observer = observer
        self.streamResource = streamResource
        self.parser = parser
        self.requestable = requestable
        self.schemeHandler = schemeHandler
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        if let persistentKey = schemeHandler.persistentKey(from: url) {
            let keyResponse = URLResponse(url: url,
                                          mimeType: AVStreamingKeyDeliveryPersistentContentKeyType,
                                          expectedContentLength: persistentKey.count,
                                          textEncodingName: nil)
            loadingRequest.setup(response: keyResponse, data: persistentKey)
            observer.keyDidLoad()
        } else {
            if !didProvideFirstResponse {
                prepareContent(streamResource, for: loadingRequest)
            } else {
                performPlaylistRequest(with: url, loadingRequest: loadingRequest)
            }
            didProvideFirstResponse = true
        }
        
        return true
    }
    
    // MARK: - Private
    
    private func request(with url: URL,
                         completion: @escaping Completion<Result<(HTTPURLResponse, Data), Error>>) {
        let request = URLRequest(url: url)
        let task = requestable.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(.failure(error ?? DownloadError.unknown))
            }
            completion(.success((response, data)))
        }
        task.resume()
    }
    
    private func prepareContent(_ streamResource: StreamResource,
                                for loadingRequest: AVAssetResourceLoadingRequest) {
        parseResponseData(streamResource.data, completion: { data in
            loadingRequest.setup(response: streamResource.response, data: data)
        })
    }
    
    private func performPlaylistRequest(with url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        guard let adoptedURL = url.withScheme(scheme: .original) else {
            return observer.taskDidFail(.urlScheme)
        }
        request(with: adoptedURL) { [weak self] result in
            switch result {
            case .success(let response):
                let streamResource = StreamResource(response: response.0, data: response.1)
                self?.prepareContent(streamResource, for: loadingRequest)
            case .failure(let error):
                self?.observer.taskDidFail(.custom(error))
            }
        }
    }
    
    private func parseResponseData(_ data: Data, completion: @escaping (Data) -> Void) {
        parser.adjust(data: data, completion: { [weak self] result in
            switch result {
            case .success(let data): completion(data)
            case .failure(let error): self?.observer.taskDidFail(.m3u8(error))
            }
        })
    }
}
