// portfolio_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acto/data/models/portfolio_project.dart';
import 'package:acto/presentation/views/focus/focus_view.dart';
import 'package:acto/presentation/views/portfolio/project_detail_view.dart';
import '../../viewmodels/portfolio_state.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../../data/models/github_models.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../data/services/github_service.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  _PortfolioViewState createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showEditPomodoroDialog(BuildContext context) {
    final vm = context.read<PortfolioViewModel>();
    final current = vm.state;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int hours = current.pomodoroMinutes ~/ 60;
          int minutes = current.pomodoroMinutes % 60;

          return AlertDialog(
            title: const Text('집중 시간 수정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimeAdjustSection(
                  label: '시간',
                  value: hours,
                  onDecrement: () => setState(() => hours = (hours - 1).clamp(0, 23)),
                  onIncrement: () => setState(() => hours = (hours + 1).clamp(0, 23)),
                ),
                const SizedBox(height: 16),
                _TimeAdjustSection(
                  label: '분',
                  value: minutes,
                  onDecrement: () => setState(() => minutes = (minutes - 5).clamp(0, 55)),
                  onIncrement: () => setState(() => minutes = (minutes + 5).clamp(0, 55)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  vm.setPomodoroTime(hours * 60 + minutes);
                  Navigator.pop(context);
                },
                child: const Text('적용'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PortfolioViewModel(
            portfolioRepository: PortfolioRepository(),
            gitHubService: GitHubService(),
          )..loadGitHubData('StyxWORKSPACE'),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개발 현황'),
          backgroundColor: const Color(0xFF4F5D75),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildPortfolioContent(),
            const FocusView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: '포트폴리오',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_rounded),
              label: '포모도로',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF4F5D75),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildPortfolioContent() {
    return BlocBuilder<PortfolioViewModel, PortfolioState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTodayStatus(context, state),
                const SizedBox(height: 20),
                _buildProjectList(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayStatus(BuildContext context, PortfolioState state) {
    return Container(
      decoration: _gradientBoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.code_rounded, '오늘의 개발 활동'),
            const SizedBox(height: 24),
            Text(
              '오늘 ${state.todayCommitCount}개의 커밋',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildTimeInfo(state),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditPomodoroDialog(context),
              child: const Text('집중 시간 수정'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(PortfolioState state) {
    final hours = state.pomodoroMinutes ~/ 3600;
    final minutes = (state.pomodoroMinutes % 3600) ~/ 60;

    return Text(
      '총 집중 시간: ${hours}시간 ${minutes}분',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildProjectList(PortfolioState state) {
    return Container(
      decoration: _gradientBoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.folder_rounded, '프로젝트'),
            const SizedBox(height: 24),
            if (state.repositories.isEmpty)
              _buildEmptyProject()
            else
              ...state.repositories.map((repo) => _buildProjectItem(repo, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyProject() {
    return const Center(
      child: Text(
        'GitHub 프로젝트가 없습니다',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildProjectItem(Repository repo, PortfolioState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToProjectDetail(context, repo, state),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(repo.name, style: _whiteTextStyle(16, true))),
                  Text('70%', style: _whiteTextStyle(14, false)),
                ],
              ),
              if (repo.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  repo.description!,
                  style: _whiteTextStyle(14, false).copyWith(color: Colors.white.withOpacity(0.7)),
                ),
              ],
              const SizedBox(height: 16),
              _buildProgressBar(),
              const SizedBox(height: 12),
              _buildLanguageTag(repo.language),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProjectDetail(BuildContext context, Repository repo, PortfolioState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailView(
          project: PortfolioProject(
            title: repo.name,
            description: repo.description ?? '',
            startDate: DateTime.now(),
            status: ProjectStatus.inProgress,
            completionPercentage: 70,
          ),
          repository: repo,
          commits: state.projectCommits[repo.name] ?? [],
        ),
      ),
    );
  }

  TextStyle _whiteTextStyle(double fontSize, bool isBold) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const FractionallySizedBox(
          widthFactor: 0.7,
          child: SizedBox(
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF4F5D75), Colors.white]),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTag(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(language, style: _whiteTextStyle(12, false)),
    );
  }

  BoxDecoration _gradientBoxDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4F5D75), Color(0xFF2D3142)],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }
}

class _TimeAdjustSection extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _TimeAdjustSection({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onDecrement,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$value $label',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onIncrement,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}