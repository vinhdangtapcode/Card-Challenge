class HistoryItem {
  final String card;
  final String challenge;
  HistoryItem({required this.card, required this.challenge});
}

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<HistoryItem> _items = [];

  List<HistoryItem> get items => List.unmodifiable(_items);

  void add(String card, String challenge) {
    _items.insert(0, HistoryItem(card: card, challenge: challenge));
  }

  void clear() {
    _items.clear();
  }
}

