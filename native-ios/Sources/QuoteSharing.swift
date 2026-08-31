import SwiftUI
import UIKit

enum ShareCardLayout {
  static let width: CGFloat = 1080
  static let height: CGFloat = 1350
}

@MainActor
enum QuoteShareRenderer {
  static func activityItems(
    quote: Quote,
    categoryName: String,
    language: AppLanguage
  ) -> [Any]? {
    let card = ShareQuoteCard(
      quoteText: quote.text,
      categoryName: categoryName,
      language: language
    )
    .frame(width: ShareCardLayout.width, height: ShareCardLayout.height)
    .environment(\.locale, Locale(identifier: language.localeIdentifier))
    .environment(\.colorScheme, .light)

    let renderer = ImageRenderer(content: card)
    renderer.scale = 1
    guard let image = renderer.uiImage else { return nil }
    var items: [Any] = [image]
    let payload = quote.id.hasPrefix("custom-")
      ? SharedQuotePayload.personal(text: quote.text, language: language)
      : SharedQuotePayload.builtIn(id: quote.id, language: language)
    if ShareLinkRoute.isPublicLinkEnabled,
       let shareURL = ShareLinkRoute.shareURL(for: payload) {
      items.append(shareURL)
    }
    return items
  }
}

struct QuoteShareButton<Label: View>: View {
  @EnvironmentObject private var store: AppStore
  @State private var activityItems: [Any] = []
  @State private var showingShareSheet = false

  let quote: Quote
  let label: Label

  init(quote: Quote, @ViewBuilder label: () -> Label) {
    self.quote = quote
    self.label = label()
  }

  var body: some View {
    Button {
      guard let items = QuoteShareRenderer.activityItems(
        quote: quote,
        categoryName: store.localizedCategoryName(store.category(for: quote.category)),
        language: store.language
      ) else {
        return
      }
      activityItems = items
      showingShareSheet = true
    } label: {
      label
    }
    .sheet(isPresented: $showingShareSheet) {
      ActivityView(activityItems: activityItems)
    }
  }
}

private struct ShareQuoteCard: View {
  let quoteText: String
  let categoryName: String
  let language: AppLanguage

  private var localizedCategoryName: String {
    categoryName.uppercased(with: Locale(identifier: language.localeIdentifier))
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color(hex: "#F7F1E8"), Color(hex: "#FBF8F1"), Color(hex: "#EFE7DA")],
        startPoint: .top,
        endPoint: .bottom
      )

      VStack(spacing: 30) {
        ZStack {
          BundledImage(name: "premium-mountains", fallback: PremiumBackground())
            .frame(width: 944, height: 1120)
            .clipped()
            .overlay(
              LinearGradient(
                colors: [.white.opacity(0.97), .white.opacity(0.72), .white.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
              )
            )

          VStack(spacing: 34) {
            Text("\"")
              .font(.system(size: 104, weight: .semibold, design: .serif))
              .foregroundStyle(Premium.gold)
              .frame(height: 100)

            Text(quoteText)
              .font(.system(size: 72, weight: .regular, design: .serif))
              .multilineTextAlignment(.center)
              .lineSpacing(10)
              .foregroundStyle(Premium.ink)
              .lineLimit(7)
              .minimumScaleFactor(0.48)
              .frame(maxWidth: 770, minHeight: 350, maxHeight: 500)

            Rectangle()
              .fill(Premium.gold)
              .frame(width: 150, height: 3)

            Text(localizedCategoryName)
              .font(.system(size: 28, weight: .medium))
              .tracking(3)
              .padding(.horizontal, 34)
              .padding(.vertical, 16)
              .foregroundStyle(Premium.gold)
              .overlay(Capsule().stroke(Premium.gold, lineWidth: 2))
          }
          .padding(.horizontal, 70)
          .offset(y: -150)
        }
        .frame(width: 944, height: 1120)
        .clipShape(RoundedRectangle(cornerRadius: 52))
        .overlay(RoundedRectangle(cornerRadius: 52).stroke(Premium.gold.opacity(0.42), lineWidth: 2))
        .shadow(color: .black.opacity(0.14), radius: 28, x: 0, y: 18)

        Text(AppBrand.name)
          .font(.system(size: 46, weight: .regular, design: .serif))
          .foregroundStyle(Premium.gold)
      }
      .padding(.vertical, 52)
    }
    .frame(width: ShareCardLayout.width, height: ShareCardLayout.height)
  }
}

private struct ActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
