import 'package:aaharup_app/features/meal_planner/data/planner_providers.dart';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:aaharup_app/features/meal_planner/presentation/dish_detail_sheet.dart';
import 'package:aaharup_app/features/meal_planner/presentation/recipe_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../presentation/ai_search_controller.dart';

class DiscoveryFeedWidget extends ConsumerStatefulWidget {
  const DiscoveryFeedWidget({super.key});

  @override
  ConsumerState<DiscoveryFeedWidget> createState() =>
      _DiscoveryFeedWidgetState();
}

class _DiscoveryFeedWidgetState extends ConsumerState<DiscoveryFeedWidget> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  // Add this method
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiSearchControllerProvider);

    ref.listen(aiSearchControllerProvider, (previous, next) {
      if (!next.isLoading &&
          next.chatHistory.length != previous?.chatHistory.length) {
        _scrollToBottom();
      }
    });


    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: aiState.isLoading && aiState.chatHistory.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.tealPrimary,
                    ),
                  )
                : aiState.chatHistory.isEmpty
                ? _buildEmptyStatePlaceholder()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        aiState.chatHistory.length +
                        (aiState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at the bottom while fetching
                      if (aiState.isLoading &&
                          index == aiState.chatHistory.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.tealPrimary,
                            ),
                          ),
                        );
                      }

                      final turn = aiState.chatHistory[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── User message bubble ──────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: 8,
                                left: 48,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tealPrimary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                turn.userMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          // ── AI reply bubble ──────────────────────────
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              right: 48,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.tealLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              turn.aiReply,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ),

                          // ── Dish grid for this turn ──────────────────
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: turn.suggestions.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.68,
                                ),
                            itemBuilder: (context, i) {
                              final suggestion = turn.suggestions[i];
                              final selectedDishId = ref.watch(
                                selectedDishIdProvider,
                              );
                              final isSelected =
                                  selectedDishId == suggestion.dish.id;
                              return _buildHighFidelityDishCard(
                                context,
                                ref,
                                suggestion.dish,
                                suggestion.reason,
                                isSelected,
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
          ),

          // -------------------------------------------------------------------
          // LAYER 2: CHAT INPUT COMPONENT FLOATING FIXED AT THE BOTTOM
          // -------------------------------------------------------------------
          SafeArea(
            top: false, // Ensures accurate edge margins on button row blocks
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(28), // Rounded pill style
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (val) { ref
                            .read(aiSearchControllerProvider.notifier)
                            .sendAiQuery(val);
                            _queryController.clear();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type: "Low-calorie dinner ideass"...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            // color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.tealPrimary,
                      ),
                      onPressed: () {
                        ref
                            .read(aiSearchControllerProvider.notifier)
                            .sendAiQuery(_queryController.text);
                        _queryController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REUSABLE DISH CARD PATTERN
  // ---------------------------------------------------------------------------
  Widget _buildHighFidelityDishCard(
  BuildContext context,
  WidgetRef ref,
  Dish dish,
  String reason,
  bool isSelected,
) {
  return GestureDetector(
    onTap: () {
      ref.read(selectedDishIdProvider.notifier).state = dish.id;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.88,
          child: DishDetailSheet(dish: dish), // Works natively with zero type clashes!
        ),
      );
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Core Asset Visual Component Block
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
                    child: dishImage(context, dish),
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
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. Dish Name Details Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              dish.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Text(
              '${dish.cookTimeMins} mins',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),

          // // 3. 🌟 THE REASON FOOTER TEXT ACCENT CONTAINER
          // Container(
          //   margin: const EdgeInsets.all(6),
          //   padding: const EdgeInsets.all(8),
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: Color(0xFFF8FAFC),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Text(
          //     reason,
          //     maxLines: 3, // Safely caps the rationale lines within card boundaries
          //     overflow: TextOverflow.ellipsis,
          //     style: TextStyle(
          //       fontSize: 11,
          //       color: Color(0xFF334155),
          //       height: 1.3,
          //       fontStyle: FontStyle.italic,
          //     ),
          //   ),
          // ),

          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 10,
                      color: AppColors.tealPrimary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reason,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildEmptyStatePlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'AI Recipe Smart Scout',
              style: AppTextStyles.h1.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'What do you feel like eating? Tell the bot your mood or specific diet limits, and see perfect recipe cards dynamically populate right here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
