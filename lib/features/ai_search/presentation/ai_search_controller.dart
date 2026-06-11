import 'dart:async';
import 'package:aaharup_app/features/meal_planner/domain/dish_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/data/auth_providers.dart'; // Adjust imports path to your setup
import '../data/ai_search_repository.dart';
import '../domain/ai_suggestion_model.dart';

final aiSearchRepositoryProvider = Provider(
  (ref) => AiSearchRepository(ref.read(apiClientProvider)),
);


class AiSearchState {
  final bool isLoading;
  final List<AiSuggestion> suggestions;
  final String? aiMessage;
  final String? errorMessage;
  final String sessionId;
  final List<ChatTurn> chatHistory; // ← add this

  const AiSearchState({
    this.isLoading = false,
    this.suggestions = const [],
    this.aiMessage,
    this.errorMessage,
    required this.sessionId,
    this.chatHistory = const [], // ← add this
  });

  AiSearchState copyWith({
    bool? isLoading,
    List<AiSuggestion>? suggestions,
    String? aiMessage,
    String? errorMessage,
    String? sessionId,
    List<ChatTurn>? chatHistory, // ← add this
  }) {
    return AiSearchState(
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
      aiMessage: aiMessage ?? this.aiMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      sessionId: sessionId ?? this.sessionId,
      chatHistory: chatHistory ?? this.chatHistory, // ← add this
    );
  }
}

// ChatTurn model
class ChatTurn {
  final String userMessage;
  final String aiReply;
  final List<AiSuggestion> suggestions;

  const ChatTurn({
    required this.userMessage,
    required this.aiReply,
    required this.suggestions,
  });
}




// 1. Add Uuid instance at top of file
final _uuid = Uuid();

// 2. Fix the controller — pure Notifier pattern, no StateNotifier
class AiSearchController extends AutoDisposeNotifier<AiSearchState> {
  late final AiSearchRepository _repo;

  @override
  AiSearchState build() {
    _repo = ref.read(aiSearchRepositoryProvider);

    // Clear backend session when user leaves screen
    ref.onDispose(() {
      _repo.clearAiSession(state.sessionId);
    });

    // Session ID created once here, lives for screen lifetime
    return AiSearchState(sessionId: _uuid.v4());
  }

  Future<void> sendAiQuery(String message) async {
    if (message.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _repo.queryAiSuggestions(
        message.trim(),
        state.sessionId,
      );

      // print(response);

      // Append new turn to history instead of replacing
      final newTurn = ChatTurn(
        userMessage: message.trim(),
        aiReply: response.message,
        suggestions: List.from(response.suggestions),
      );


      state = state.copyWith(
        isLoading: false,
        // sessionId: response.sessionId,
        aiMessage: response.message,
        suggestions: List.from(response.suggestions),
        chatHistory: [...?state.chatHistory, newTurn], // ← grow history
      );
      debugPrint(
        "State updated. Total dishes loaded: ${state.suggestions.length}",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetSearchSession() {
    _repo.clearAiSession(state.sessionId);
    state = AiSearchState(sessionId: _uuid.v4());   // fresh session ID on reset
  }
}

final aiSearchControllerProvider =
    NotifierProvider.autoDispose<AiSearchController, AiSearchState>(() {
      return AiSearchController();
    });
