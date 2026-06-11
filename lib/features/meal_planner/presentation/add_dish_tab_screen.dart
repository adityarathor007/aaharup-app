import 'package:aaharup_app/features/ai_search/presentation/discover_screen.dart';
import 'package:aaharup_app/features/meal_planner/presentation/recipe_search_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AddDishTabsScreen extends StatelessWidget {
  const AddDishTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 distinct strategy pathways
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Dish to Plan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // -------------------------------------------------------------------
          // THE TAB BAR SELECTION HUB
          // -------------------------------------------------------------------
          bottom: const TabBar(
            labelColor: AppColors.tealPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.tealPrimary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Explore Meals'),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('AaharUp Suggests'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ---------------------------------------------------------------------
        // TAB VIEWS: Renders layout columns matching index alignment
        // ---------------------------------------------------------------------
        body: const TabBarView(
          physics:
              BouncingScrollPhysics(), // Silky smooth switching transitions
          children: [
            // Tab 1: Direct Catalog Search (Your old default listing view)
            RecipeSearchListWidget(),

            // Tab 2: The conversational RAG system we just built
            DiscoveryFeedWidget(),
          ],
        ),
      ),
    );
  }
}
