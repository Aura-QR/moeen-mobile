/// `GET /portfolios/{id}/performance` as the server sends it.
Map<String, dynamic> performanceJson({int? selfRating = 4, double? average = 4.33}) => {
      'portfolio_id': 7,
      'title': 'ملف الإنجاز 1448',
      'role_label': 'معلم',
      'cv': {'name': 'سارة', 'qualification': 'بكالوريوس', 'rank': null, 'subjects': ''},
      'evidence_target': 3,
      'rating_scale': {'min': 1, 'max': 5},
      'rating': {
        'elements': 11,
        'rated': average == null ? 0 : 2,
        'points': 13,
        'out_of': 15,
        'percent': average == null ? null : 86.7,
        'average': average,
      },
      'document_id': 55,
      'items': [
        {
          'id': 31,
          'item_key': 'teaching_strategies',
          'number': 4,
          'weight': 10,
          'title': 'التنويع في استراتيجيات التدريس',
          'description': null,
          'included': true,
          'self_rating': selfRating,
          'evidence_count': 3,
          'state': 'complete',
          'files': [
            {'id': 90, 'kind': 'link', 'url': 'https://youtu.be/x'},
          ],
          'documents': [
            {'id': 12, 'type': 'strategy_documentation', 'title': 'توثيق جيكسو', 'created_at': '2026-10-01T10:00:00+00:00'},
          ],
        },
        {
          'id': 32,
          'item_key': 'activity_plan',
          'number': null,
          'weight': null,
          'title': 'خطة النشاط',
          'included': false,
          'self_rating': null,
          'evidence_count': 0,
          'state': 'something_new',
        },
      ],
    };
