//
//  Publisher+shareReplay.swift
//  Comet
//
//  Created by Tuan Tu Do on 12.06.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine

extension Publisher {
    func share(replay count: Int) -> Publishers.Autoconnect<Publishers.Multicast<Self, ReplaySubject<Output, Failure>>> {
        multicast { ReplaySubject(bufferSize: count) }
            .autoconnect()
    }
}
