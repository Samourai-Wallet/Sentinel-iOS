//
//  PromiseKit_Moya_Decode.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation
import Moya
import PromiseKit

extension MoyaProvider {
    public typealias PendingRequestPromise = (promise: Promise<Moya.Response>, cancellable: Cancellable)
    
    public func request(target: Target,
                        queue: DispatchQueue? = nil,
                        progress: Moya.ProgressBlock? = nil) -> Promise<Moya.Response> {
        return requestCancellable(target: target,
                                  queue: queue,
                                  progress: progress).promise
    }
    
    public func requestDecoded<T>(target: Target, type: T.Type) -> Promise<T> where T: Decodable {
        return Promise<T> { seal in
            request(target: target).done({ (response) in
                do {
                    let decoded = try JSONDecoder().decode(type, from: response.data)
                    NSLog(target.baseURL.absoluteString + " -> " + response.debugDescription) // TODO remove debug output
                    seal.fulfill(decoded)
                } catch let err {
                    seal.reject(err)
                }
            }).catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    func requestCancellable(target: Target,
                            queue: DispatchQueue?,
                            progress: Moya.ProgressBlock? = nil) -> PendingRequestPromise {
        let pending = Promise<Moya.Response>.pending()
        let completion = promiseCompletion(fulfill: pending.resolver.fulfill, reject: pending.resolver.reject)
        let cancellable = request(target, callbackQueue: queue, progress: progress, completion: completion)
        
        return (pending.promise, cancellable)
    }
    
    private func promiseCompletion(fulfill: @escaping (Moya.Response) -> Void,
                                   reject: @escaping (Swift.Error) -> Void) -> Moya.Completion {
        return { result in
            switch result {
            case let .success(response):
                fulfill(response)
            case let .failure(error):
                reject(error)
            }
        }
    }
}
