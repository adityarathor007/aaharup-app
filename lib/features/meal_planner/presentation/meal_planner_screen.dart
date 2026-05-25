import 'package:aaharup_app/core/theme/app_colors.dart';
import 'package:aaharup_app/core/theme/app_spacing.dart';
import 'package:aaharup_app/core/theme/app_text_styles.dart';
import 'package:aaharup_app/features/meal_planner/domain/meal_plan_models.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:aaharup_app/features/meal_planner/presentation/meal_planner_controller.dart';
import 'package:aaharup_app/shared/providers/theme_provider.dart';
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
    final dailyPlan = ref.watch(dailyMealPlanProvider(selectedDate));
    // final themeMode = ref.watch(themeProvider);

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
                child: ListView(
                  children:[
                    _buildMealSlot(context,ref,'BREAKFAST', dailyPlan.breakfast),
                    const SizedBox(height: AppSpacing.md),
                    _buildMealSlot(context,ref, 'LUNCH', dailyPlan.lunch),
                    const SizedBox(height: AppSpacing.md),
                    _buildMealSlot(context,ref, 'DINNER', dailyPlan.dinner),
                    const SizedBox(height: AppSpacing.md),

                    // 5. NUTRITION TRACKING GOAL WIDGET
                    // _buildNutritionCard(dailyPlan.totalCalories),
                  ]
                )
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
        if (meal != null)
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: AppSpacing.paddingAllMd,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: AppColors.tealPrimary,
                    ), // Swapped with network images later
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
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {},
                  ),
                ],
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
