import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dynamic query input stream modifier parameter hooks
final selectedCuisineFilterProvider = StateProvider<String>((ref) => 'All');


class MealSchedulingNotifier extends StateNotifier<AsyncValue<void>> {
    final Ref _ref;
    MealSchedulingNotifier(this._ref) : super(const AsyncValue.data(null));

    Future<bool> confirmAndScheduleMeal({
    required DateTime targetDate,
    required String slotType,
    required int dishId,
    }) async {
    state = const AsyncValue.loading();
    try {
        final apiClient = _ref.read(apiClientProvider);
        // print(apiClient);

        // Hit your FastAPI POST /api/v1/planner/schedule route
        await apiClient.dio.post(
          '/planner/schedule',
          data: {
              'target_date': targetDate.toIso8601String().split(
              'T',
              )[0], // Formats exactly to YYYY-MM-DD
              'slot_type': slotType,
              'dish_id': dishId,
          },
        );

        state = const AsyncValue.data(null);
        // print(state);
        return true; // Success flag
    } catch (e, stack) {
        state = AsyncValue.error(e, stack);
        return false;
    }
    }
}
