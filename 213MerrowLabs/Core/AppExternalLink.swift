import Foundation

enum AppExternalLink: String {
  case privacyPolicy = "https://merrow213labs.site/privacy/251"
  case termsOfUse = "https://merrow213labs.site/terms/251"

  var url: URL? {
    URL(string: rawValue)
  }
}
