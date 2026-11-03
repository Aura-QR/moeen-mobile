/// Builds the JavaScript snippet injected into the lab WebView to synchronize
/// dark/light mode with the host website's Tailwind theme.
String buildLabThemeScript(bool isDark) {
  final theme = isDark ? 'dark' : 'light';
  return '''
(function() {
  try {
    var t = '$theme';
    localStorage.setItem('hadr-theme', t);
    localStorage.setItem('moeen_theme', t);
    localStorage.setItem('moeen-theme', t);
    if (t === 'dark') {
      document.documentElement.classList.add('dark');
      if (document.body) document.body.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
      if (document.body) document.body.classList.remove('dark');
    }
    document.documentElement.setAttribute('data-theme', t);
  } catch (e) {}
})();
''';
}
