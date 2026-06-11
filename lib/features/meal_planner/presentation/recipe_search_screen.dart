import 'dart:async';

import 'package:aaharup_app/core/theme/app_colors.dart';
import 'package:aaharup_app/features/meal_planner/data/planner_providers.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/presentation/discovery_controller.dart';
import 'package:aaharup_app/features/meal_planner/data/dish_providers.dart';
import 'package:aaharup_app/features/meal_planner/presentation/dish_detail_sheet.dart';
import 'package:aaharup_app/features/meal_planner/presentation/planner_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecipeSearchListWidget extends ConsumerWidget {
  // 1. Declare a top-level or class-level nullable timer reference variable
  const RecipeSearchListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Looks at whether user clicked Breakfast, Lunch, or Dinner and pulls the valid rows
    final categories = ref.watch(targetCourseFiltersProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final searchController = TextEditingController(text: ref.read(dishSearchQueryProvider));
    Timer? _debounceTimer;

    return Scaffold(
      appBar: AppBar(
        leading: isSearchActive
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(isSearchActiveProvider.notifier).state = false;
              ref.read(dishSearchQueryProvider.notifier).state = '';
            },
          )
        : null,

        title: isSearchActive
            ? TextField(
                controller: searchController, //to show what is typed in this field
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search recipes...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Debounce or update state query to trigger API calls instantly
                  // ref.read(dishSearchQueryProvider.notifier).state = value;

                  // Cancel the previous timer if the user typed another letter before 350ms passed
                  if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

                  // Start a new countdown timer
                  _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                    // This code only runs after the user pauses typing for 350ms!
                    ref.read(dishSearchQueryProvider.notifier).state = value;
                  });
                }
            )
            : null,

        actions: [
        // DYNAMIC ICON BUTTON: Shows magnifying glass or clear button
        if (!isSearchActive)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => ref.read(isSearchActiveProvider.notifier).state = true,
          )
        else
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              ref.read(dishSearchQueryProvider.notifier).state = '';
            },
          ),
        ],
      ),
      body: SafeArea(

        child: Column(
          children: [
            // // 1. SEARCH BAR & TAB BAR WORKSPACE (If you have them at the top)
            // const Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: Text("Search and Segments go here"),
            // ),

            // 2. YOUR CAROUSEL FEED (Wrapped in Expanded so it occupies remaining space and scrolls independently)
            Expanded(
              child: isSearchActive
              ? const _SearchResultsGridWidget()
              : _buildCarouselListView(categories,ref),
            ),

            // // 3. THE FIXED BOTTOM SUBMIT AREA
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 16.0,
            //     vertical: 12.0,
            //   ),
            //   child: buildSubmitButton(context, ref), // Injected cleanly here!
            // ),
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
                ref.read(isSearchActiveProvider.notifier).state = false;
                ref.read(dishSearchQueryProvider.notifier).state = '';
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


  Widget _buildCarouselListView(List<String> categories, WidgetRef ref) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final courseCategoryName = categories[index];
        final asyncDishesRow = ref.watch(carouselDishesProvider(courseCategoryName),);

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
                  if (dishesList.isEmpty) {
                    return const Text('No recipes listed in this section');
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dishesList.length,
                    itemBuilder: (context, dIdx) {
                      final dish = dishesList[dIdx];
                      final selectedDishId = ref.watch(selectedDishIdProvider);
                      final isSelected = selectedDishId == dish.id;

                      return GestureDetector(
                        onTap: () {
                        // 1. Keep card selection highlighting working perfectly
                          ref.read(selectedDishIdProvider.notifier).state = dish.id;

                          // 2. Launch the Netflix modal detail layer above the view space smoothly
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Crucial parameter: Allows full height expanding behavior
                            backgroundColor: Colors.transparent, // Ensures our custom corner round borders show up beautifully
                            builder: (context) => FractionallySizedBox(
                                heightFactor: 0.88, // Opens up to occupy 88% of full device view screen height
                                child: DishDetailSheet(dish: dish),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.teal
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        // child: Icon(
                                        //   Icons.restaurant,
                                        //   color: Colors.teal,
                                        // ),
                                            child:  dishImage(context,dish),

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

                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

}

class _SearchResultsGridWidget extends ConsumerWidget {
  const _SearchResultsGridWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(globalSearchQueryResultProvider);
    final selectedDishId = ref.watch(selectedDishIdProvider);

    return searchResultsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.teal)),
      error: (err, stack) => Center(child: Text('Search Error: $err')),
      data: (dishesList) {
        if (dishesList.isEmpty) {
          return const Center(
            child: Text(
              'No dishes found matching your query.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          // Sets fixed 2-column cross-axis count constraint layout rules
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.78, // Adjust ratio slightly to make text cards fit beautifully
          ),
          itemCount: dishesList.length,
          itemBuilder: (context, index) {
            final dish = dishesList[index];
            final isSelected = selectedDishId == dish.id;

            return GestureDetector(
              onTap: () {
                ref.read(selectedDishIdProvider.notifier).state = dish.id;

                // 2. Launch the Netflix modal detail layer above the view space smoothly
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Crucial parameter: Allows full height expanding behavior
                  backgroundColor: Colors
                      .transparent, // Ensures our custom corner round borders show up beautifully
                  builder: (context) => FractionallySizedBox(
                    heightFactor:
                        0.88, // Opens up to occupy 88% of full device view screen height
                    child: DishDetailSheet(dish: dish),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.teal : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                                child: dishImage(context,dish),
                            //   child: Icon(
                            //     Icons.restaurant,
                            //     color: Colors.teal,
                            //     size: 28,
                            //   ),
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
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
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
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
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
              ),
            );
          },
        );
      },
    );
  }
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
