import UIKit
import UniformTypeIdentifiers

/// "Sousvite" in the share sheet. Takes the shared link, or text holding
/// one, and opens the app at `sousvite://open/import?shared=…`, which
/// starts importing the recipe. Android does the same in MainActivity.
final class ShareViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { await share() }
  }

  private func share() async {
    if let text = await sharedText(), let link = importLink(for: text) {
      open(link)
    }
    extensionContext?.completeRequest(returningItems: nil)
  }

  /// The shared web address, or else the shared text.
  private func sharedText() async -> String? {
    let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
    let providers = items.flatMap { $0.attachments ?? [] }
    for provider in providers
    where provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      let item = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier)
      if let url = item as? URL, url.scheme?.hasPrefix("http") == true {
        return url.absoluteString
      }
    }
    for provider in providers
    where provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      let item = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier)
      if let text = item as? String { return text }
    }
    return nil
  }

  private func importLink(for text: String) -> URL? {
    // Encode everything but unreserved characters: a "+" left as is would
    // read back as a space.
    let unreserved = CharacterSet(
      charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
    guard let value = text.addingPercentEncoding(withAllowedCharacters: unreserved) else {
      return nil
    }
    return URL(string: "sousvite://open/import?shared=\(value)")
  }

  /// Extensions can't reach `UIApplication.shared`, so this walks the
  /// responder chain to the app to open the link.
  private func open(_ url: URL) {
    var responder: UIResponder? = self
    while let current = responder {
      if let application = current as? UIApplication {
        application.open(url, options: [:], completionHandler: nil)
        return
      }
      responder = current.next
    }
  }
}
