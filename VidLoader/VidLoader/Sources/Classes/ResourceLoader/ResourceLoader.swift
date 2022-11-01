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
    private let masterParser: MasterParser
    private let playlistParser: PlaylistParser
    private var streamResource: StreamResource
    private let headers: [String: String]?
    private let requestable: Requestable
    private let schemeHandler: SchemeHandleable
    
    init(observer: ResourceLoaderObserver,
         streamResource: StreamResource,
         headers: [String: String]? = nil,
         masterParser: MasterParser = M3U8Master(),
         playlistParser: PlaylistParser = M3U8Playlist(),
         requestable: Requestable = URLSession.shared,
         schemeHandler: SchemeHandleable = SchemeHandler.init()) {
        self.observer = observer
        self.streamResource = streamResource
        self.headers = headers
        self.masterParser = masterParser
        self.playlistParser = playlistParser
        self.requestable = requestable
        self.schemeHandler = schemeHandler
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        let scheme = schemeHandler.schemeType(from: url)
        switch scheme {
        case .key:
            guard let persistentKey = schemeHandler.persistentKey(from: url) else {
                return false
            }
            setup(persistentKey: persistentKey, url: url, loadingRequest: loadingRequest)
            return true
        case .master:
            adjustMasterFile(streamResource: streamResource, baseURL: url, loadingRequest: loadingRequest)
            return true
        case .variant:
            performPlaylistRequest(with: url, loadingRequest: loadingRequest)
            return true
        case .original, .none:
            return false
        }
    }

    
    // MARK: - Private
        
    private func request(with url: URL,
                         completion: @escaping Completion<Result<(HTTPURLResponse, Data), Error>>) {
        var request = URLRequest(url: url)
        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let task = requestable.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(.failure(error ?? DownloadError.unknown))
            }
            completion(.success((response, data)))
        }
        task.resume()
    }
    
    private func performPlaylistRequest(with url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        guard let adoptedURL = url.withScheme(scheme: .original) else {
            return observer.taskDidFail(.urlScheme)
        }
        request(with: adoptedURL, completion: { [weak self] result in
            self?.adjustPlaylistFile(result: result, baseURL: url, loadingRequest: loadingRequest)
        })
    }
    
    // MARK: Parse Files
    
    private func adjustMasterFile(streamResource: StreamResource,
                                  baseURL: URL,
                                  loadingRequest: AVAssetResourceLoadingRequest) {
        let result = masterParser.adjust(data: streamResource.data, baseURL: baseURL)
        switch result {
        case .success(let newData): loadingRequest.setup(response: streamResource.response, data: newData, isEntireLengthAvailableOnDemand: true)
        case .failure(let error): observer.taskDidFail(.m3u8(error))
        }
    }
    
    private func adjustPlaylistFile(result: Result<(HTTPURLResponse, Data), Error>,
                                    baseURL: URL,
                                    loadingRequest: AVAssetResourceLoadingRequest) {
        switch result {
        case .success(let response):
            playlistParser.adjust(data: response.1, with: baseURL, headers: headers, completion: { [weak self] result in
                switch result {
                case .success(let newData): loadingRequest.setup(response: response.0, data: newData, isEntireLengthAvailableOnDemand: false)
                case .failure(let error): self?.observer.taskDidFail(.m3u8(error))
                }
            })
        case .failure(let error):
            observer.taskDidFail(.custom(.init(error: error)))
        }
    }
    
    private func setup(persistentKey: Data, url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        let keyResponse = URLResponse(url: url,
                                      mimeType: AVStreamingKeyDeliveryContentKeyType,
                                      expectedContentLength: persistentKey.count,
                                      textEncodingName: nil)
        loadingRequest.setup(response: keyResponse, data: persistentKey, isEntireLengthAvailableOnDemand: true)
        observer.keyDidLoad()
    }
}
