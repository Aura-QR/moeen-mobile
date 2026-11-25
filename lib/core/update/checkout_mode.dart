/// How the app may let a teacher pay, decided per platform on the server
/// (`checkout` in `GET /api/app/version`), so it can change with no release.
enum CheckoutMode {
  /// Subscribe buttons open the website's checkout in the phone's browser.
  web,

  /// No paying in the app at all: no buttons and no link to the site.
  off;

  /// Anything other than `"web"`, a missing field from an older server
  /// included, is [off]: when the server says nothing, show no way to pay.
  static CheckoutMode fromServer(Object? value) =>
      value == 'web' ? CheckoutMode.web : CheckoutMode.off;
}
