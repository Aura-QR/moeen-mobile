import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';

void main() {
  test('NewLearningStyleSurvey.toJson drops empty names and keeps class ids', () {
    const survey = NewLearningStyleSurvey(
      title: '  أنماط التعلم  ',
      version: LearningStyleVersions.simple,
      groups: [
        (name: 'خامس ١', classId: 12),
        (name: '', classId: null),
      ],
    );

    final json = survey.toJson();

    expect(json['title'], 'أنماط التعلم');
    expect(json['version'], LearningStyleVersions.simple);
    final groups = json['groups'] as List;
    expect(groups.first, {'name': 'خامس ١', 'class_id': 12});
    expect((groups.last as Map).containsKey('name'), isFalse);
    expect((groups.last as Map).containsKey('class_id'), isFalse);
  });

  test('LearningStylesResults.fromJson parses the mix, students and strategies', () {
    final results = LearningStylesResults.fromJson({
      'survey': {'id': 1, 'title': 'أنماط', 'is_open': true, 'responses': 2},
      'styles': [
        {'key': 'visual', 'label': 'بصري', 'description': 'الصور'},
      ],
      'overall': {
        'count': 2,
        'percents': {'visual': 25, 'auditory': 50, 'read_write': 0, 'kinesthetic': 25},
        'top_styles': ['auditory', 'visual'],
        'strategies': [
          {'key': 'discussion', 'style': 'auditory', 'name': 'المناقشة', 'steps': ['اسأل', 'ناقش']},
        ],
      },
      'groups': [
        {
          'id': 3,
          'name': 'خامس ١',
          'summary': {'count': 2},
          'responses': [
            {'id': 7, 'student_name': 'خالد', 'main_styles': ['visual', 'kinesthetic'], 'leaning': 'البصري والحركي'},
          ],
        },
      ],
    });

    expect(results.survey.id, 1);
    expect(results.styles.single.label, 'بصري');
    expect(results.overall.percents['auditory'], 50);
    expect(results.overall.topStyles, ['auditory', 'visual']);
    expect(results.overall.strategies.single.steps.length, 2);
    expect(results.groups.single.responses.single.studentName, 'خالد');
    expect(results.groups.single.responses.single.leaning, 'البصري والحركي');
  });

  test('qrBytesFromDataUri decodes a data URI and rejects junk', () {
    expect(qrBytesFromDataUri(null), isNull);
    expect(qrBytesFromDataUri('not-a-uri'), isNull);
    final bytes = qrBytesFromDataUri('data:image/png;base64,aGVsbG8=');
    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!), 'hello');
  });
}
