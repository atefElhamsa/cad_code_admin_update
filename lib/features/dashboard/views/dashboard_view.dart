import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/dashboard_cubit.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../users/views/users_view.dart';
import '../../courses/views/courses_view.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/placeholder_screen.dart';
import '../../updater/services/updater_service.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(),
      child: const DashboardContent(),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdaterService.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: const Center(child: Text('Mobile Layout Coming Soon')),
        tablet: const Center(child: Text('Tablet Layout Coming Soon')),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Row(
          children: [
            DashboardSidebar(selectedIndex: state.selectedIndex),
            Expanded(
              child: Column(
                children: [
                  const DashboardHeader(),
                  Expanded(child: _buildMainContent(state)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(DashboardState state) {
    switch (state.selectedIndex) {
      // case 0:
      // return DashboardOverview(state: state);
      case 0:
        return const UsersView();
      case 1:
        return const CoursesView();
      case 2:
        return const PlaceholderScreen(title: 'Settings');
      default:
        return const UsersView();
    }
  }
}
