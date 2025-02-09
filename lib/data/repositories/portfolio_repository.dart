import '../models/coding_log.dart';
import '../models/portfolio_project.dart';

class PortfolioRepository {
  Future<List<PortfolioProject>> getProjects() async {
    // TODO: 프로젝트 데이터 저장소 구현
    return [];
  }

  Future<List<CodingLog>> getCodingLogs() async {
    // TODO: 코딩 로그 데이터 저장소 구현
    return [];
  }

  Future<void> updateCodingLog({
    required DateTime date,
    required double additionalMinutes,
  }) async {
    // TODO: 코딩 로그 업데이트 구현
  }
} 