import '../models/coding_log.dart';
import '../models/portfolio_project.dart';

class PortfolioRepository {
  // TODO: 프로젝트 진행률을 백엔드 API로 저장하고 불러오는 기능 구현 필요
  // - POST /api/projects/{projectId}/progress
  // - GET /api/projects/{projectId}/progress
  
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