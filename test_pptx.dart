import 'dart:io';
import 'package:open_xml/open_xml.dart';

void main() async {
  try {
    final ppt = Presentation();
    final slide = ppt.addSlide();
    
    // Testing the open_xml API since it can be tricky.
    // The previous API I wrote `slide.addTitle(text: ...)` might be invalid. Let's see.
  } catch (e) {
    print(e);
  }
}
