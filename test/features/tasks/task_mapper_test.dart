import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/src/features/tasks/data/task_mapper.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

void main() {
  group('TaskMapper', () {
    test('maps remote rows into domain models and back', () {
      final createdAt = DateTime.utc(2024, 1, 1, 10, 0, 0);
      final updatedAt = DateTime.utc(2024, 1, 2, 10, 0, 0);
      final deletedAt = DateTime.utc(2024, 1, 3, 10, 0, 0);

      final remoteRow = {
        'id': 'remote-1',
        'title': 'Write report',
        'description': 'Quarterly summary',
        'due_date': '2024-01-04T10:00:00.000Z',
        'is_completed': true,
        'priority': 2,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt.toIso8601String(),
      };

      final model = TaskMapper.fromRemoteRow(remoteRow);

      expect(model.remoteId, 'remote-1');
      expect(model.title, 'Write report');
      expect(model.description, 'Quarterly summary');
      expect(model.priority, TaskPriority.medium);
      expect(model.isCompleted, true);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
      expect(model.deletedAt, deletedAt);

      final payload = TaskMapper.toRemoteRow(model, userId: 'user-123');
      expect(payload['id'], 'remote-1');
      expect(payload['user_id'], 'user-123');
      expect(payload['title'], 'Write report');
      expect(payload['is_completed'], true);
      expect(payload['priority'], 2);
      expect(payload['updated_at'], updatedAt.toIso8601String());
    });
  });
}
