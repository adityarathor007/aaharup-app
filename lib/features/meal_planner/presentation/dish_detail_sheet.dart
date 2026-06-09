import 'package:aaharup_app/features/meal_planner/data/dish_providers.dart';
import 'package:aaharup_app/features/meal_planner/data/planner_providers.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/presentation/planner_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DishDetailSheet extends ConsumerWidget {
  final Dish dish;
  final bool isReadOnly;

  const DishDetailSheet({
    super.key,
    required this.dish,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Parse the comma-separated ingredients text cleanly into a list
    final List<String> ingredientsList = dish.ingredientsRaw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              // Grab handle indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  // padding: const EdgeInsets.fromLTRB(20,16,20,100),
                  padding: EdgeInsets.fromLTRB(20, 16, 20, isReadOnly ? 24 : 100),
                  children: [
                    // Hero Image bounding box
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        // child: Icon(Icons.restaurant, size: 48, color: Colors.teal),
                        child: dishImage(context,dish)
                      )
                    ),

                    const SizedBox(height: 20),

                    //Dish Name
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      )
                    ),

                    const SizedBox(height: 12),

                    // Metadata Pill Wrap Grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (dish.cuisineType.isNotEmpty) _buildChip(dish.cuisineType),
                        if (dish.courseType.isNotEmpty) _buildChip(dish.courseType),
                        if (dish.dietType.isNotEmpty) _buildChip(dish.dietType),
                        _buildChip('${dish.cookTimeMins} mins',icon: Icons.access_time),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Ingredients List Block
                    const Text(
                      'Ingredients Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...ingredientsList.map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0, right: 10.0),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.teal,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Preparation Steps Text
                    const Text(
                      'Preparation Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      dish.recipeInstructions,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.6, // Generous line height for cooking legibility
                      ),
                    ),
                  ],
                )
                ),
            ],
          ),


          // B. Fixed Transparent Floating Close Circle Button
          Positioned(
            top: 24,
            right: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          if (!isReadOnly)
            // C. Fixed Sticky Bottom Action Button Area
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                color: Colors.white.withValues(alpha: 0.95),
                child: _buildScheduleButton(context, ref),
              ),
            ),

        ],
      )
    );
  }

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.teal.shade700),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton(BuildContext context, WidgetRef ref) {
    final activeSlot = ref.watch(activeSlotContextRecipientProvider);
    final targetCalendarDate = ref.watch(selectedDateProvider);
    final schedulingState = ref.watch(mealSchedulingProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488), // Fresh Teal primary
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      onPressed: schedulingState.isLoading
          ? null
          : () async {
              final success = await ref
                  .read(mealSchedulingProvider.notifier)
                  .confirmAndScheduleMeal(
                    targetDate: targetCalendarDate,
                    slotType: activeSlot,
                    dishId: dish.id,
                  );

              if (success && context.mounted) {
                // Clear active search state tracking variables completely
                ref.read(isSearchActiveProvider.notifier).state = false;
                ref.read(dishSearchQueryProvider.notifier).state = '';

                // Reload calendar strips maps data
                ref.invalidate(dailyMealPlanProvider);

                // Close the detailed pop-up layer
                context.pop();
                // Close the discovery screen workspace to drop back onto main dashboard
                context.pop();
              }
            },
      child: schedulingState.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.edit_calendar_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule This Meal for $activeSlot',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }

  Widget dishImage(BuildContext context, Dish dish) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: dish.imageUrl!,
              fit: BoxFit.cover,

              placeholder: (context, url) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D9488),
                    strokeWidth: 2.5,
                  ),
                ),
              ),

              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFFEF2F2),
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              ),
            )
          : const Center(child: Icon(Icons.restaurant, size: 48)),
    );
  }

}
