/// Web implementation — opens a URL in a new browser tab.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void openUrlInNewTab(String url) {
  html.window.open(url, '_blank');
}
