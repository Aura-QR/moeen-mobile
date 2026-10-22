import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';

void main() {
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

  test('a document file is neither an image nor a link', () {
    final file = PortfolioFileModel.fromJson({
      'id': 5,
      'kind': 'document',
      'title': 'توثيق جيكسو',
      'mime': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'url': null,
    });

    expect(file.isDocument, isTrue);
    expect(file.isImage, isFalse);
    expect(file.isLink, isFalse);
    expect(file.url, isEmpty);
  });
}
