import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';

class MockAiJobsRepository extends Mock implements AiJobsRepository {}

const _kind = AiJobKinds.remedialSuggestions;

const _pending = AiJobModel(id: 5, kind: _kind, status: AiJobStatus.pending);

const _done = AiJobModel(id: 5, kind: _kind, status: AiJobStatus.done, result: {
  'weaknesses': ['ضعف'],
});

void main() {
  late MockAiJobsRepository repo;

  AiSuggestionsCubit build({int maxPollAttempts = 30}) => AiSuggestionsCubit(
        kind: _kind,
        repository: repo,
        pollInterval: Duration.zero,
        maxPollAttempts: maxPollAttempts,
      );

  setUp(() => repo = MockAiJobsRepository());

  test('a cached answer (200) is used at once, without polling', () async {
    when(() => repo.start(_kind, [12])).thenAnswer((_) async => const Right(_done));
    final cubit = build();
    await cubit.suggest([12]);

    expect(cubit.state.status, AiSuggestionsStatus.done);
    expect(cubit.state.result, {
      'weaknesses': ['ضعف'],
    });
    verifyNever(() => repo.getJob(any()));
    await cubit.close();
  });

  test('a pending job (202) is polled until done', () async {
    var polls = 0;
    when(() => repo.start(_kind, [12, 13])).thenAnswer((_) async => const Right(_pending));
    when(() => repo.getJob(5)).thenAnswer((_) async => ++polls < 3 ? const Right(_pending) : const Right(_done));
    final cubit = build();
    await cubit.suggest([12, 13]);

    expect(polls, 3);
    expect(cubit.state.status, AiSuggestionsStatus.done);
    await cubit.close();
  });

  test('a failed job shows its error, and retrying asks again', () async {
    when(() => repo.start(_kind, [12])).thenAnswer((_) async => const Right(_pending));
    when(() => repo.getJob(5)).thenAnswer(
      (_) async => const Right(AiJobModel(id: 5, kind: _kind, status: AiJobStatus.failed, error: 'تعذر تجهيز الاقتراحات')),
    );
    final cubit = build();
    await cubit.suggest([12]);

    expect(cubit.state.status, AiSuggestionsStatus.failed);
    expect(cubit.state.errorMessage, 'تعذر تجهيز الاقتراحات');

    when(() => repo.start(_kind, [12])).thenAnswer((_) async => const Right(_done));
    await cubit.suggest([12]);
    expect(cubit.state.status, AiSuggestionsStatus.done);
    await cubit.close();
  });

  test('polling stops after the allowed attempts', () async {
    when(() => repo.start(_kind, [12])).thenAnswer((_) async => const Right(_pending));
    when(() => repo.getJob(5)).thenAnswer((_) async => const Right(_pending));
    final cubit = build(maxPollAttempts: 3);
    await cubit.suggest([12]);

    verify(() => repo.getJob(5)).called(3);
    expect(cubit.state.errorMessage, 'ai_suggestions_timeout');
    await cubit.close();
  });

  test('a usage limit (429) shows its message', () async {
    when(() => repo.start(_kind, [12])).thenAnswer(
      (_) async => const Left(ServerFailure('وصلت إلى الحد اليومي')),
    );
    final cubit = build();
    await cubit.suggest([12]);

    expect(cubit.state.status, AiSuggestionsStatus.failed);
    expect(cubit.state.errorMessage, 'وصلت إلى الحد اليومي');
    await cubit.close();
  });

  test('no subscription (402) asks for the upgrade sheet', () async {
    when(() => repo.start(_kind, [12])).thenAnswer(
      (_) async => const Left(PaymentRequiredFailure('ترقية الحساب', code: 'subscription_required')),
    );
    final cubit = build();
    await cubit.suggest([12]);

    expect(cubit.state.status, AiSuggestionsStatus.idle);
    expect(cubit.state.paymentRequired?.code, 'subscription_required');
    await cubit.close();
  });

  test('nothing is asked without lessons', () async {
    final cubit = build();
    await cubit.suggest(const []);

    verifyNever(() => repo.start(any(), any()));
    await cubit.close();
  });
}
