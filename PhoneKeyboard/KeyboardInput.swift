import SwiftUI
import UIKit

struct KeyboardInput: UIViewRepresentable {
    let onText: (String) -> Void
    let onDelete: () -> Void

    func makeUIView(context: Context) -> InputView {
        let view = InputView()
        view.onText = onText
        view.onDelete = onDelete
        DispatchQueue.main.async { view.becomeFirstResponder() }
        return view
    }

    func updateUIView(_ view: InputView, context: Context) {
        view.onText = onText
        view.onDelete = onDelete
    }
}

final class InputView: UIView, UIKeyInput {
    var onText: (String) -> Void = { _ in }
    var onDelete: () -> Void = {}
    override var canBecomeFirstResponder: Bool { true }
    var hasText: Bool { true }

    func insertText(_ text: String) { onText(text) }
    func deleteBackward() { onDelete() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        becomeFirstResponder()
        super.touchesBegan(touches, with: event)
    }
}
