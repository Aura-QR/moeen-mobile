import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_upload_models.dart';

void main() {
  group('PortfolioPickedFile.mimeFromName', () {
    test('maps the accepted types', () {
      expect(PortfolioPickedFile.mimeFromName('a.JPG'), 'image/jpeg');
      expect(PortfolioPickedFile.mimeFromName('a.jpeg'), 'image/jpeg');
      expect(PortfolioPickedFile.mimeFromName('a.png'), 'image/png');
      expect(PortfolioPickedFile.mimeFromName('a.webp'), 'image/webp');
      expect(PortfolioPickedFile.mimeFromName('خطة.pdf'), 'application/pdf');
    });

    test('rejects HEIC and names without an extension', () {
      expect(PortfolioPickedFile.mimeFromName('IMG_1.HEIC'), isNull);
      expect(PortfolioPickedFile.mimeFromName('file'), isNull);
    });
  });

  test('PortfolioModel sorts items and files by sort_order', () {
    final portfolio = PortfolioModel.fromJson({
      'id': 7,
      'title': 'ملف الإنجاز 1448',
      'role': 'teacher',
      'role_label': 'معلم',
      'is_public': false,
      'completion': {'included': 2, 'complete': 1, 'percent': 50, 'missing': ['ب']},
      'items': [
        {'id': 2, 'item_key': null, 'title': 'ب', 'included': true, 'sort_order': 2, 'files': []},
        {
          'id': 1,
          'item_key': 'duties',
          'title': 'أ',
          'included': true,
          'sort_order': 1,
          'files': [
            {'id': 91, 'kind': 'link', 'url': 'https://youtu.be/x', 'sort_order': 2},
            {'id': 90, 'kind': 'file', 'mime': 'image/png', 'url': 'https://r2/x.png', 'sort_order': 1},
          ],
        },
      ],
    });

    expect(portfolio.items.map((i) => i.id), [1, 2]);
    expect(portfolio.items.first.files.map((f) => f.id), [90, 91]);
    expect(portfolio.items.first.files.first.isImage, isTrue);
    expect(portfolio.items.first.files.last.isLink, isTrue);
    expect(portfolio.items.first.isCustom, isFalse);
    expect(portfolio.items.last.isCustom, isTrue);
    expect(portfolio.completion.percent, 50);
  });
}
