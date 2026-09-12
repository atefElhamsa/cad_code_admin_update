part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final int counter;
  final int selectedIndex;
  final int totalUsers;
  final int totalCourses;
  final double completionRate;
  final List<UserProfile> recentUsers;
  final Map<int, int> userGrowthData; // Day of month -> count
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.counter = 0,
    this.selectedIndex = 0,
    this.totalUsers = 0,
    this.totalCourses = 0,
    this.completionRate = 0.0,
    this.recentUsers = const [],
    this.userGrowthData = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    int? counter,
    int? selectedIndex,
    int? totalUsers,
    int? totalCourses,
    double? completionRate,
    List<UserProfile>? recentUsers,
    Map<int, int>? userGrowthData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      counter: counter ?? this.counter,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      totalUsers: totalUsers ?? this.totalUsers,
      totalCourses: totalCourses ?? this.totalCourses,
      completionRate: completionRate ?? this.completionRate,
      recentUsers: recentUsers ?? this.recentUsers,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    counter,
    selectedIndex,
    totalUsers,
    totalCourses,
    completionRate,
    recentUsers,
    userGrowthData,
    isLoading,
    errorMessage,
  ];
}
