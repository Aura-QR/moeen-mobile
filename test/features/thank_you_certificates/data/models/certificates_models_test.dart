import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_catalogue_model.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_input.dart';

void main() {
  test('the catalogue reads reasons with a text per audience, designs and limits', () {
    final catalogue = CertificatesCatalogueModel.fromJson({
      'audiences': [
        {'key': 'male', 'label': 'طلاب'},
      ],
      'reasons': [
        {
          'key': 'excellence',
          'label': 'التفوق الدراسي',
          'title': 'شهادة تفوق',
          'text': {'male': 'للطالب {name}', 'female': 'للطالبة {name}'},
        },
      ],
      'designs': [
        {'key': 'classic_green', 'label': 'كلاسيكي أخضر', 'image_url': 'https://x/classic_green.png'},
      ],
      'limits': {'names': 80, 'text_chars': 300, 'title_chars': 60},
    });

    expect(catalogue.reasonOf('excellence')?.textFor('female'), 'للطالبة {name}');
    expect(catalogue.reasonOf('other'), isNull);
    expect(catalogue.designs.single.imageUrl, 'https://x/classic_green.png');
    expect(catalogue.limits.textChars, 300);
  });

  group('CertificatesInput', () {
    test('toJson leaves out empty fields so the backend uses its defaults', () {
      final json = CertificatesInput(
        names: const ['ريم'],
        reason: 'excellence',
        design: 'classic_green',
        date: DateTime(2026, 10, 22),
        extra: const {'date_hijri': '١٤٤٨/٠٤/٣٠'},
      ).toJson();

      expect(json, {
        'date_hijri': '١٤٤٨/٠٤/٣٠',
        'names': ['ريم'],
        'reason': 'excellence',
        'design': 'classic_green',
        'date': '2026-10-22',
      });
    });

    test('fromJson round-trips, dropping empty names', () {
      final input = CertificatesInput.fromJson({
        'names': ['ريم', ' ', 'سارة'],
        'class_id': 3,
        'reason': 'behavior',
        'design': 'classic_green',
        'audience': 'female',
        'text': 'نص {name}',
      });

      expect(input.names, ['ريم', 'سارة']);
      expect(input.classId, 3);
      expect(input.withNames(['ريم']).toJson()['text'], 'نص {name}');
    });
  });
}
