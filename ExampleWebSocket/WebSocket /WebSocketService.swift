//
//  WebSocketService.swift
//  ExampleWebSocket
//
//  Created by Kane on 21/11/24.
//

import Foundation

class WebSocketService: NSObject {
    private var webSocket: URLSessionWebSocketTask?

    init(url: URL, queue: OperationQueue) {
        super.init()

        self.webSocket = URLSession(configuration: .default, delegate: self, delegateQueue: queue).webSocketTask(with: url)
    }

    public func connect() {
        webSocket?.resume()
        self.observe()
    }

    public func disconnect() {
        let disconnectReason = "User close screen".data(using: .utf8)
        webSocket?.cancel(with: .goingAway, reason: disconnectReason)
    }

    public func send(_ message: String) {
        let socketMsg = URLSessionWebSocketTask.Message.string(message)
        webSocket?.send(socketMsg) { error in
            if let error = error {
                print("Send message failed with error: \(error.localizedDescription)")
            }
        }
    }

    func observe() {
        webSocket?.receive(completionHandler: { result in
            switch result {
            case .success(let success):
                switch success {
                case .data(let data):
                    print("Did receive data: \(data)")
                case .string(let string):
                    print("Did receive string: \(string)")
                default:
                    print("Did receive other response")
                }
            case .failure(let failure):
                print("Failed to receive with error: \(failure.localizedDescription)")
            }
        })
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error = error {
            print("WebSocket task complete with error: \(error)")
        }
    }
}
