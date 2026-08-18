abstract interface class IProgressRepository {
  int get bestScore;

  Future<void> load();

  Future<void> save(int score);
}
