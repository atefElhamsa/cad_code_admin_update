import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'access_codes_state.dart';

class AccessCodesCubit extends Cubit<AccessCodesState> {
  final int folderId;
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  AccessCodesCubit({required this.folderId}) : super(AccessCodesInitial()) {
    _fetchActiveCode();
  }

  Future<void> _fetchActiveCode() async {
    emit(AccessCodesLoading());
    try {
      final response = await _supabase
          .from('access_codes')
          .select()
          .eq('folder_id', folderId)
          .eq('is_used', false)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final activeCode = response['code'] as String;
        emit(
          AccessCodesLoaded(
            folders: const [], // Not needed here anymore
            selectedFolderId: folderId,
            activeCode: activeCode,
            isUsed: false,
          ),
        );
        _listenToCodeChanges(activeCode);
      } else {
        emit(
          AccessCodesLoaded(
            folders: const [],
            selectedFolderId: folderId,
            activeCode: null,
            isUsed: false,
          ),
        );
      }
    } catch (e) {
      emit(AccessCodesError(e.toString()));
    }
  }

  Future<void> generateCode() async {
    emit(AccessCodesLoading());
    try {
      final newCode = _generateRandomCode();

      // Delete any existing unused codes for this folder to prevent accumulating unused codes
      await _supabase
          .from('access_codes')
          .delete()
          .eq('folder_id', folderId)
          .eq('is_used', false);

      await _supabase.from('access_codes').insert({
        'code': newCode,
        'folder_id': folderId,
        'is_used': false,
      });

      emit(
        AccessCodesLoaded(
          folders: const [],
          selectedFolderId: folderId,
          activeCode: newCode,
          isUsed: false,
        ),
      );

      _listenToCodeChanges(newCode);
    } catch (e) {
      emit(AccessCodesError(e.toString()));
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String generateSegment(int length) {
      return String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
    }

    return 'CAD-${generateSegment(4)}-${generateSegment(4)}';
  }

  void _listenToCodeChanges(String code) {
    _subscription?.unsubscribe();

    _subscription = _supabase
        .channel('public:access_codes:$code')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'access_codes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'code',
            value: code,
          ),
          callback: (payload) {
            final updatedRow = payload.newRecord;
            if (updatedRow['is_used'] == true) {
              if (state is AccessCodesLoaded) {
                final currentState = state as AccessCodesLoaded;
                if (currentState.activeCode == code) {
                  // Emit used state
                  emit(currentState.copyWith(isUsed: true));

                  // Auto-generate a new one after 2 seconds
                  Future.delayed(const Duration(seconds: 2), () {
                    generateCode();
                  });
                }
              }
            }
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
