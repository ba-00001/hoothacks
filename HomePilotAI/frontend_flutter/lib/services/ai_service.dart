import '../models/dashboard_model.dart';
import '../models/grant_match_model.dart';
import '../models/mortgage_estimate_model.dart';
import '../models/recommendation_model.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'demo_fallbacks.dart';

class ChatReply {
  const ChatReply({required this.message, this.suggestions = const []});

  final String message;
  final List<String> suggestions;
}

class AiService {
  AiService(this._apiClient);

  final ApiClient _apiClient;

  ChatReply buildWelcomeReply({UserProfile? user}) {
    final preference = switch (user?.rentOrBuy) {
      'BUY' => 'buying a home',
      'RENT' => 'renting smartly',
      _ => 'your housing plan',
    };
    final location = user?.preferredLocation;

    return ChatReply(
      message:
          'Hi! I am your HomePilot chatbot. I can help with $preference'
          '${location == null || location.isEmpty ? '' : ' around $location'}. '
          'Ask me about budget, listings, grants, or mortgage readiness.',
      suggestions: const [
        'Show my budget summary',
        'Find home recommendations',
        'What grants can I get?',
        'Estimate my mortgage with 15000 down',
      ],
    );
  }

  Future<ChatReply> getChatReply({
    required String prompt,
    UserProfile? user,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return buildWelcomeReply(user: user);
    }

    final normalized = trimmedPrompt.toLowerCase();

    if (_containsAny(normalized, ['hello', 'hi', 'hey', 'help', 'start'])) {
      return buildWelcomeReply(user: user);
    }

    if (_containsAny(normalized, ['grant', 'assistance', 'program'])) {
      return _buildGrantReply();
    }

    if (_containsAny(normalized, [
      'mortgage',
      'monthly payment',
      'down payment',
      'downpayment',
      'buy budget',
      'preapprove',
      'pre-approve',
      'readiness',
    ])) {
      return _buildMortgageReply(trimmedPrompt);
    }

    if (_containsAny(normalized, [
      'listing',
      'recommend',
      'property',
      'apartment',
      'house',
      'home',
    ])) {
      return _buildRecommendationReply();
    }

    if (_containsAny(normalized, [
      'budget',
      'afford',
      'dashboard',
      'summary',
      'rent range',
      'purchase range',
    ])) {
      return _buildBudgetReply();
    }

    final dashboard = await getDashboard();
    return ChatReply(
      message:
          'Here is a quick overall snapshot.\n'
          '- Best-fit rent range: ${_formatCurrency(dashboard.affordability.recommendedRentMin)} to ${_formatCurrency(dashboard.affordability.recommendedRentMax)} per month\n'
          '- Estimated purchase range: ${_formatCurrency(dashboard.affordability.recommendedPurchaseMin)} to ${_formatCurrency(dashboard.affordability.recommendedPurchaseMax)}\n'
          '- Mortgage readiness: ${dashboard.mortgageEstimate.readinessScore}/100\n'
          '- Guidance: ${dashboard.affordability.message}',
      suggestions: const [
        'Find home recommendations',
        'What grants can I get?',
        'Estimate my mortgage with 20000 down',
      ],
    );
  }

  Future<DashboardModel> getDashboard() async {
    try {
      final json = await _apiClient.getObject('/dashboard');
      return DashboardModel.fromJson(json);
    } on ApiConnectivityException {
      return DemoFallbacks.dashboard();
    }
  }

  Future<List<GrantMatchModel>> getGrants() async {
    try {
      final json = await _apiClient.postObject('/ai/grants');
      final matches = json['matches'] as List<dynamic>;
      return matches
          .map((item) => GrantMatchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiConnectivityException {
      return DemoFallbacks.grants();
    }
  }

  Future<List<RecommendationModel>> getRecommendations() async {
    try {
      final json = await _apiClient.postObject('/ai/recommendations');
      final recommendations = json['recommendations'] as List<dynamic>;
      return recommendations
          .map(
            (item) =>
                RecommendationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on ApiConnectivityException {
      return DemoFallbacks.recommendations();
    }
  }

  Future<MortgageEstimateModel> getMortgageEstimate({
    double? downPayment,
  }) async {
    try {
      final json = await _apiClient.postObject(
        '/ai/mortgage-estimate',
        body: downPayment == null ? null : {'downPayment': downPayment},
      );
      return MortgageEstimateModel.fromJson(json);
    } on ApiConnectivityException {
      return DemoFallbacks.mortgageEstimate(downPayment: downPayment);
    }
  }

  Future<ChatReply> _buildBudgetReply() async {
    final dashboard = await getDashboard();

    return ChatReply(
      message:
          'Here is your affordability summary.\n'
          '- Rent target: ${_formatCurrency(dashboard.affordability.recommendedRentMin)} to ${_formatCurrency(dashboard.affordability.recommendedRentMax)} per month\n'
          '- Purchase range: ${_formatCurrency(dashboard.affordability.recommendedPurchaseMin)} to ${_formatCurrency(dashboard.affordability.recommendedPurchaseMax)}\n'
          '- Mortgage readiness: ${dashboard.mortgageEstimate.readinessScore}/100\n'
          '- AI note: ${dashboard.affordability.message}',
      suggestions: const [
        'Find home recommendations',
        'Estimate my mortgage with 15000 down',
      ],
    );
  }

  Future<ChatReply> _buildGrantReply() async {
    final grants = await getGrants();
    if (grants.isEmpty) {
      return const ChatReply(
        message:
            'I could not find any grant matches yet. Completing more of your housing profile will improve the search.',
        suggestions: ['Show my budget summary', 'Find home recommendations'],
      );
    }

    final buffer = StringBuffer(
      'These are the strongest grant matches I found for you.\n',
    );
    for (final grant in grants.take(3)) {
      buffer.writeln(
        '- ${grant.programName}: ${_formatCurrency(grant.coverageAmount)} coverage, ${grant.eligibilityScore.toStringAsFixed(0)} match. ${grant.rationale}',
      );
    }

    return ChatReply(
      message: buffer.toString().trim(),
      suggestions: const [
        'Show my budget summary',
        'Estimate my mortgage with 10000 down',
      ],
    );
  }

  Future<ChatReply> _buildRecommendationReply() async {
    final recommendations = await getRecommendations();
    if (recommendations.isEmpty) {
      return const ChatReply(
        message:
            'I do not have listing recommendations yet. Try updating your profile preferences and ask again.',
        suggestions: ['Show my budget summary', 'What grants can I get?'],
      );
    }

    final buffer = StringBuffer(
      'Here are the top homes and rentals I would start with.\n',
    );
    for (final item in recommendations.take(3)) {
      final priceLabel = item.rentOrBuy == 'RENT'
          ? '${_formatCurrency(item.price)} per month'
          : _formatCurrency(item.price);
      buffer.writeln(
        '- ${item.title} in ${item.location}: $priceLabel, ${item.score.toStringAsFixed(0)} match. ${item.fitSummary}',
      );
    }

    return ChatReply(
      message: buffer.toString().trim(),
      suggestions: const [
        'What grants can I get?',
        'Estimate my mortgage with 20000 down',
      ],
    );
  }

  Future<ChatReply> _buildMortgageReply(String prompt) async {
    final downPayment = _extractAmount(prompt);
    final estimate = await getMortgageEstimate(downPayment: downPayment);

    return ChatReply(
      message:
          'Here is your mortgage snapshot'
          '${downPayment == null ? '' : ' using a ${_formatCurrency(downPayment)} down payment'}.\n'
          '- Estimated budget: ${_formatCurrency(estimate.estimatedBudget)}\n'
          '- Monthly payment target: ${_formatCurrency(estimate.monthlyPayment)}\n'
          '- Readiness score: ${estimate.readinessScore}/100\n'
          '- Suggested purchase range: ${_formatCurrency(estimate.recommendedPurchaseMin)} to ${_formatCurrency(estimate.recommendedPurchaseMax)}\n'
          '- Summary: ${estimate.summary}',
      suggestions: const [
        'Show my budget summary',
        'Find home recommendations',
      ],
    );
  }

  bool _containsAny(String source, List<String> candidates) {
    return candidates.any(source.contains);
  }

  double? _extractAmount(String prompt) {
    final match = RegExp(r'(\d[\d,]*(?:\.\d+)?)').firstMatch(prompt);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  String _formatCurrency(num value) {
    final rounded = value.round();
    final digits = rounded.abs().toString();
    final groups = <String>[];

    for (var index = digits.length; index > 0; index -= 3) {
      final start = (index - 3).clamp(0, digits.length);
      groups.insert(0, digits.substring(start, index));
    }

    final formatted = groups.join(',');
    return rounded < 0 ? '-\$$formatted' : '\$$formatted';
  }
}
