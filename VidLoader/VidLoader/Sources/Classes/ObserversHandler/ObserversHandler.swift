//
//  ObserversHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

protocol ObserversHandleable {
    func add(_ observer: VidObserver?)
    func remove(_ observer: VidObserver?)
    func fire(for type: ObserverType, with item: ItemInformation)
}

class ObserversHandler: ObserversHandleable {
    private var observers: [ObserverType: [WeakObserver<VidObserver>]]

    init(observers: [ObserverType: [WeakObserver<VidObserver>]] = [:]) {
        self.observers = observers
    }

    // MARK: - ObserverHandleable

    func add(_ observer: VidObserver?) {
        guard let observer = observer else { return }
        append(observer: observer)
    }

    func remove(_ observer: VidObserver?) {
        guard let type = observer?.type,
            let weakObserver = observers[type]?.first(where: { $0.reference == observer }) else { return }
        remove(observer: weakObserver, with: type)
    }

    func fire(for type: ObserverType, with item: ItemInformation) {
        observers[type]?.forEach { weakObserver in
            guard let observer = weakObserver.reference else {
                return remove(observer: weakObserver, with: type)
            }
            observer.stateChanged(item)
        }
    }

    // MARK: - Private functions

    private func append(observer: VidObserver) {
        let type = observer.type
        let array = observers[type] ?? []
        observers[type] = array + [WeakObserver(reference: observer)]
    }

    private func remove(observer: WeakObserver<VidObserver>, with type: ObserverType) {
        guard let newObservers = observers[type]?.filter({ $0 != observer && $0.reference != nil }),
            !newObservers.isEmpty else {
            observers[type] = nil
            return
        }
        observers[type] = Array(newObservers)
    }
}
