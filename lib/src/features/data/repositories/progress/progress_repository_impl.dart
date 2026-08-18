import 'package:unstable_flying_object/src/features/data/repositories/progress/iprogress_repository.dart';
import 'package:unstable_flying_object/src/features/data/repositories/shared_preferences/ishared_preferences_repository.dart';

class ProgressRepositoryImpl implements IProgressRepository {
  static const String _progressKey = 'progress';

  final ISharedPreferencesRepository _spRepository;

  int? _bestScore;

  ProgressRepositoryImpl({required this._spRepository});

  @override
  int get bestScore => _bestScore ?? 0;

  @override
  Future<void> load() async {
    _bestScore = await _spRepository.getInt(_progressKey);
  }

  @override
  Future<void> save(int score) async {
    _bestScore = score;
    _spRepository.setInt(_progressKey, score);
  }
}
