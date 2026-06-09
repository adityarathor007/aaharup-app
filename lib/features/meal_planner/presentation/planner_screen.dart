import 'package:aaharup_app/core/theme/app_colors.dart';
import 'package:aaharup_app/core/theme/app_spacing.dart';
import 'package:aaharup_app/core/theme/app_text_styles.dart';
import 'package:aaharup_app/features/auth/data/auth_providers.dart';
import 'package:aaharup_app/features/meal_planner/data/dish_providers.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/domain/meal_plan_models.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:aaharup_app/features/meal_planner/presentation/dish_detail_sheet.dart';
import 'package:aaharup_app/features/meal_planner/presentation/planner_controller.dart';
import 'package:aaharup_app/shared/providers/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final selectedDate = ref.watch(selectedDateProvider);
    final weekDays = ref.watch(currentWeekDaysProvider);
    // final dailyPlan = ref.watch(dailyMealPlanProvider);
    // final themeMode = ref.watch(themeProvider);
    // Watch the asynchronous meal plan state
    final dailyPlanAsync = ref.watch(dailyMealPlanProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(padding: AppSpacing.paddingAllMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //1. Header Section (Month Name & Mode Icons)
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.tealPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('MMMM yyyy').format(selectedDate),
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.tealPrimary,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      ref.watch(themeProvider) == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: AppColors.textMutedLight,
                    ),
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing. md),

              // 2. WEEK CONTROLLER BAR (Nav Arrows & Week count)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        ref.read(selectedDateProvider.notifier).state =
                            selectedDate.subtract(const Duration(days: 7)),
                  ),
                  Column(
                    children: [
                      Text(
                        'Week ${((selectedDate.day / 7).ceil())}',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 16,
                          color: AppColors.tealPrimary,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM d').format(weekDays.first)} – ${DateFormat('d').format(weekDays.last)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMutedLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        ref.read(selectedDateProvider.notifier).state =
                            selectedDate.add(const Duration(days: 7)),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. HORIZONTAL CALENDAR STRIP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((day) {
                  final isSelected =
                      day.year == selectedDate.year &&
                      day.month == selectedDate.month &&
                      day.day == selectedDate.day;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(selectedDateProvider.notifier).state = day,
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day)[0],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.tealPrimary
                                : AppColors.textMutedLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.tealPrimary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface ,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 4. DAILY MEAL SLOTS SECTION
              Expanded(
                child: dailyPlanAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  error: (err, stack) =>
                      Center(child: Text('Sync Error: $err')),
                  data: (dailyPlan) {
                    return ListView(
                      padding: AppSpacing.paddingHorizontalMd,
                      children: [
                        _buildMealSlot(
                          context,
                          ref,
                          'Breakfast',
                          dailyPlan.breakfast,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildMealSlot(context,ref, 'Lunch', dailyPlan.lunch),
                        const SizedBox(height: AppSpacing.md),
                        _buildMealSlot(context,ref, 'Dinner', dailyPlan.dinner),
                        // const SizedBox(height: AppSpacing.lg),
                        // _buildNutritionCard(dailyPlan.totalCalories),
                      ],
                    );
                  },
                ),
              )

            ],
          ),
          )
      )
    );
  }


  Widget _buildMealSlot(
    BuildContext context,
    WidgetRef ref,
    String title,
    ScheduledMeal? meal,
  ) {

    // if(meal!=null) print(meal.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textMutedLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // If meal already assigned for the slot
        if (meal != null)
          GestureDetector(
            onTap: () async {
              try{
                //1. showing a loading indicator dialog since we need to fetch full dish metric from db
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
                );

                //2.Fetch full dish entity details using the repository layer
                // final fullRepository = ref.read(dishRepositoryProvider);

                // Look up your global database by ID (ensure your API has a GET /dishes/{id} route)
                final response = await ref.read(apiClientProvider).dio.get('/dishes/${meal.id}');
                final fullDishEntity = Dish.fromJson(response.data);

                if (context.mounted) {
                  context.pop(); // Dismiss loading spinner indicator dialog safely

                  // 3. Open the custom detailed popup sheet overlay layer
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.88,
                      // Pass isReadOnly: true to dynamically hide the bottom schedule button element canvas
                      child: DishDetailSheet(dish: fullDishEntity, isReadOnly: true),
                    ),
                  );
                }
              } catch (e) {
                  if (context.mounted) {
                    context.pop(); // Dismiss loading spinner
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to load dish profile details.')),
                    );
                  }
                }
            },
            child: Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: dishImage(context, meal)
                      // child: const Icon(
                      //   Icons.fastfood,
                      //   color: AppColors.tealPrimary,
                      // ), // Swapped with network images later
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${meal.calories.toInt()} kcal',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.tealPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meal.prepTimeMinutes}m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // THE DELETE CROSS ICON ACTION BUTTON
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () async {
                        final targetDate = ref.read(selectedDateProvider);
                        final dateStr = targetDate.toIso8601String().split(
                          'T',
                        )[0];

                        // Optimistically hit your backend DELETE endpoint configuration path
                        try {
                          await ref
                              .read(apiClientProvider)
                              .dio
                              .delete(
                                '/planner/remove',
                                queryParameters: {
                                  'target_date': dateStr,
                                  'slot_type':
                                      title, // title represents 'Breakfast', 'Lunch', or 'Dinner'
                                },
                              );

                          // Force layout streams network refetch synchronization loops
                          ref.invalidate(dailyMealPlanProvider);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed $title selection mapping.',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to clear slot reservation.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          // Add Meal Button State
          DottedBorder(
            color: Colors.grey.shade300,
            strokeWidth: 1,
            dashPattern: const [6, 3], // 6px line, 3px gap
            borderType: BorderType.RRect,
            radius: const Radius.circular(12), // Matches button shape
            padding: EdgeInsets.zero, // Prevents layout shifting
            child: OutlinedButton(
              onPressed: () {
                // 1. Set the active slot context (e.g., 'Breakfast', 'Lunch', 'Dinner')
                // This instantly switches your backend carousel queries dynamically!
                ref.read(activeSlotContextRecipientProvider.notifier).state =
                    title;

                // 2. Reset any previous temporary selection states
                // ref.read(selectedDishIdProvider.notifier).state = null;

                // 3. Navigate to your Netflix-style discovery screen
                // Assuming your GoRouter path is configured as '/discovery'
                context.push('/discovery');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                // Remove 'side' parameter entirely
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '+ Add dish',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            ),
          )
      ],
    );
  }

}

Widget dishImage(BuildContext context, ScheduledMeal meal) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: meal.imageUrl!,
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
