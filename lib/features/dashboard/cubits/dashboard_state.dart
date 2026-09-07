part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final int counter;
  final int selectedIndex;
  final int totalUsers;
  final List<UserProfile> recentUsers;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.counter = 0,
    this.selectedIndex = 0,
    this.totalUsers = 0,
    this.recentUsers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    int? counter,
    int? selectedIndex,
    int? totalUsers,
    List<UserProfile>? recentUsers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      counter: counter ?? this.counter,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      totalUsers: totalUsers ?? this.totalUsers,
      recentUsers: recentUsers ?? this.recentUsers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    counter,
    selectedIndex,
    totalUsers,
    recentUsers,
    isLoading,
    errorMessage,
  ];
}
