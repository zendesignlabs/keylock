import AppKit
import Combine

/// Blocks all keyboard input via a CGEventTap while locked.
/// Mouse events pass through so the unlock button stays clickable.
final class KeyboardLocker: ObservableObject {
    @Published private(set) var isLocked = false
    @Published private(set) var hasPermission = false
    @Published private(set) var remaining: TimeInterval = 0
    @Published var duration: TimeInterval = 0 // 0 = until tapped again

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var countdown: Timer?
    private var permissionPoll: Timer?

    init() {
        hasPermission = AXIsProcessTrusted()
        if !hasPermission {
            // Poll so the UI flips to ready as soon as the user grants access.
            permissionPoll = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                if AXIsProcessTrusted() {
                    self.hasPermission = true
                    self.permissionPoll?.invalidate()
                    self.permissionPoll = nil
                }
            }
        }
    }

    func requestPermission() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        hasPermission = AXIsProcessTrustedWithOptions(options)
    }

    func toggle() {
        isLocked ? unlock() : lock()
    }

    func lock() {
        guard !isLocked else { return }
        guard AXIsProcessTrusted() else {
            requestPermission()
            return
        }

        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << 14) // NSEvent systemDefined: media & brightness keys

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                let locker = Unmanaged<KeyboardLocker>.fromOpaque(refcon!).takeUnretainedValue()
                if let tap = locker.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
                return Unmanaged.passUnretained(event)
            }
            return nil // swallow the event
        }

        let refcon = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: refcon
        ) else {
            hasPermission = false
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isLocked = true

        if duration > 0 {
            remaining = duration
            countdown = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.remaining -= 0.05
                if self.remaining <= 0 { self.unlock() }
            }
        }
    }

    func unlock() {
        countdown?.invalidate()
        countdown = nil
        remaining = 0
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        isLocked = false
    }

    deinit {
        unlock()
        permissionPoll?.invalidate()
    }
}
