import '../entities/run_session_snapshot.dart';

abstract interface class RunSessionRepository {
  RunSessionSnapshot? readActiveSession();
  Future<void> saveActiveSession(RunSessionSnapshot snapshot);
  Future<void> clearActiveSession();
}
