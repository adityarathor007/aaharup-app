import 'package:aaharup_app/core/theme/app_colors.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:aaharup_app/features/meal_planner/presentation/meal_planner_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoveryFeedWidget extends ConsumerWidget {
  const DiscoveryFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Looks at whether user clicked Breakfast, Lunch, or Dinner and pulls the valid rows
    final categories = ref.watch(targetCourseFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Dish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(

        child: Column(
          children: [
            // 1. SEARCH BAR & TAB BAR WORKSPACE (If you have them at the top)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Search and Segments go here"),
            ),

            // 2. YOUR CAROUSEL FEED (Wrapped in Expanded so it occupies remaining space and scrolls independently)
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final courseCategoryName = categories[index];
                  final asyncDishesRow = ref.watch(
                    carouselDishesProvider(courseCategoryName),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row Title Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          courseCategoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Horizontal Netflix-style Card Scroller container
                      SizedBox(
                        height: 220,
                        child: asyncDishesRow.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error loading elements: $err'),
                          data: (dishesList) {
                            if (dishesList.isEmpty)
                              return const Text('No recipes listed in this section');

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dishesList.length,
                              itemBuilder: (context, dIdx) {
                                final dish = dishesList[dIdx];
                                final selectedDishId = ref.watch(selectedDishIdProvider);
                                final isSelected = selectedDishId == dish.id;

                                return GestureDetector(
                                  onTap: (){
                                    ref.read(selectedDishIdProvider.notifier).state=dish.id;
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? Colors.teal: Colors.transparent,
                                        width: 2,
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children:[
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.teal.shade50,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.restaurant,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.teal,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                )
                                            ]
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            dish.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            '${dish.cookTimeMins} mins',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    )
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3. THE FIXED BOTTOM SUBMIT AREA
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: buildSubmitButton(context, ref), // Injected cleanly here!
            ),
          ],
        ),
      ),
    );
  }

  // 2. Inside your Sticky Bottom "Add to Schedule" Action Area:
  Widget buildSubmitButton(BuildContext context, WidgetRef ref) {
    final selectedDishId = ref.watch(selectedDishIdProvider);
    final activeSlot = ref.watch(activeSlotContextRecipientProvider);
    final targetCalendarDate = ref.watch(selectedDateProvider,); // Reads active day from main screen state
    final schedulingState = ref.watch(mealSchedulingProvider);

    // Keep button disabled/grayed-out until a user taps an active dish card
    final isButtonEnabled =
        selectedDishId != null && !schedulingState.isLoading;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonEnabled
            ? AppColors.tealPrimary
            : Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: !isButtonEnabled
          ? null
          : () async {
              // print(selectedDishId);
              final success = await ref
                  .read(mealSchedulingProvider.notifier)
                  .confirmAndScheduleMeal(
                    targetDate: targetCalendarDate,
                    slotType: activeSlot,
                    dishId: selectedDishId,
                  );

              if (success && context.mounted) {
                // 1. Invalidate your calendar data provider to force an automatic layout reload
                ref.invalidate(dailyMealPlanProvider);

                // 2. Pop the discovery screen and slide back to the main calendar smoothly
                context.pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully planned $activeSlot!')),
                );
              }
            },
      child: schedulingState.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Add to Schedule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
