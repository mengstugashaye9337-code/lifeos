import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/src/features/habits/data/habit_mapper.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

void main() {
  group('HabitMapper', () {
    test('maps remote rows into domain models and back', () {
      final createdAt = DateTime.utc(2024, 1, 1, 10, 0, 0);
      final updatedAt = DateTime.utc(2024, 1, 2, 10, 0, 0);
      final deletedAt = DateTime.utc(2024, 1, 3, 10, 0, 0);

      final remoteRow = {
        'id': 'remote-1',
        'title': 'Read 20 pages',
        'frequency': 'weekly',
        'streak': 3,
        'last_completed_date': '2024-01-02T10:00:00.000Z',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt.toIso8601String(),
      };

      final model = HabitMapper.fromRemoteRow(remoteRow);

      expect(model.remoteId, 'remote-1');
      expect(model.title, 'Read 20 pages');
      expect(model.frequency, HabitFrequency.weekly);
      expect(model.streak, 3);
      expect(model.lastCompletedDate, DateTime.utc(2024, 1, 2, 10, 0, 0));
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
      expect(model.deletedAt, deletedAt);

      final payload = HabitMapper.toRemoteRow(model, userId: 'user-123');

      expect(payload['id'], 'remote-1');
      expect(payload['user_id'], 'user-123');
      expect(payload['title'], 'Read 20 pages');
      expect(payload['frequency'], 'weekly');
      expect(payload['streak'], 3);
      expect(payload['last_completed_date'], '2024-01-02T10:00:00.000Z');
      expect(payload['updated_at'], updatedAt.toIso8601String());
    });
  });
}
