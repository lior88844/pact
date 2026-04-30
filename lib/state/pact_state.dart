import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/daily_entry_service.dart';
import '../services/pair_service.dart';
import '../services/user_service.dart';

class PactState extends ChangeNotifier {
  final DailyEntryService _entryService;
  final PairService _pairService;
  final UserService _userService;

  PactState({
    DailyEntryService? entryService,
    PairService? pairService,
    UserService? userService,
  })  : _entryService = entryService ?? DailyEntryService(),
        _pairService = pairService ?? PairService(),
        _userService = userService ?? UserService();

  UserProfile? me;
  UserProfile? partner;
  String? partnerUid;
  bool isLoading = true;
  String? errorMessage;

  // Navigation
  int tab = 0; // 0=today, 1=history, 2=settings

  // Today view
  bool isYouView = true;
  int dayOffset = 0; // 0=today, -n=n days ago

  List<Task> youTasks = makeFreshDay();
  List<Task> palTasks = makeFreshDay();

  // Mood strings are stored in Firestore. UI uses enum.
  MoodState? youMood;
  MoodState? palMood;

  final Map<int, DaySnapshot> _loadedSnapshots = {};
  List<DailyEntry> historyEntries = [];
  String? _activeYouEntryId;

  // ── Computed ──
  bool get isToday => dayOffset == 0;
  bool get isPast => dayOffset < 0;

  DaySnapshot? get pastSnapshot => isPast ? _loadedSnapshots[dayOffset] : null;

  List<Task> get activeTasks {
    if (isPast) {
      final snap = pastSnapshot;
      if (snap == null) return [];
      return isYouView ? snap.youTasks : snap.palTasks;
    }
    return isYouView ? youTasks : palTasks;
  }

  MoodState? get activeMood {
    if (isPast) {
      final snap = pastSnapshot;
      return snap == null ? null : (isYouView ? snap.youMood : snap.palMood);
    }
    return isYouView ? youMood : palMood;
  }

  int get youDone {
    if (isPast) return pastSnapshot?.youTasks.where((t) => t.done).length ?? 0;
    return youTasks.where((t) => t.done).length;
  }

  int get palDone {
    if (isPast) return pastSnapshot?.palTasks.where((t) => t.done).length ?? 0;
    return palTasks.where((t) => t.done).length;
  }

  int get activeDone => isYouView ? youDone : palDone;

  bool get canEdit => isToday && isYouView;

  String get currentUserName => me?.displayName.isNotEmpty == true ? me!.displayName : 'You';
  String get partnerName =>
      partner?.displayName.isNotEmpty == true ? partner!.displayName : 'Partner';
  String get partnerInviteCode => partner?.inviteCode ?? '';

  Future<void> initialize(UserProfile profile) async {
    me = profile;
    await refreshSession();
  }

  Future<void> refreshSession() async {
    final profile = me;
    if (profile == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      me = await _userService.getByUid(profile.uid) ?? profile;
      final pairId = me?.pairId;
      if (pairId == null) {
        throw StateError('Missing pair for current user.');
      }

      partnerUid = await _pairService.getPartnerUid(
        pairId: pairId,
        myUid: me!.uid,
      );
      if (partnerUid != null) {
        partner = await _userService.getByUid(partnerUid!);
      }

      await _loadSelectedDay();
      await loadHistory();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    if (me == null) return;
    historyEntries = await _entryService.getRecentEntries(userId: me!.uid, limit: 14);
  }

  Future<void> _loadSelectedDay() async {
    if (me == null || me!.pairId == null) return;
    final date = _entryService.dateToLocalYmd(DateTime.now().add(Duration(days: dayOffset)));
    final myEntry = await _entryService.getOrCreateEntry(
      userId: me!.uid,
      pairId: me!.pairId!,
      date: date,
    );
    final partnerEntry = partnerUid == null
        ? null
        : await _entryService.getEntryByUserAndDate(
            userId: partnerUid!,
            date: date,
          );

    final youList = _toUiTasks(myEntry.tasks);
    final palList = partnerEntry == null ? makeFreshDay() : _toUiTasks(partnerEntry.tasks);
    final youMoodValue = _moodFromString(myEntry.state);
    final palMoodValue = _moodFromString(partnerEntry?.state);

    if (dayOffset == 0) {
      _activeYouEntryId = myEntry.id;
      youTasks = youList;
      palTasks = palList;
      youMood = youMoodValue;
      palMood = palMoodValue;
    } else {
      _loadedSnapshots[dayOffset] = DaySnapshot(
        youTasks: youList,
        palTasks: palList,
        youMood: youMoodValue,
        palMood: palMoodValue,
      );
    }
  }

  List<Task> _toUiTasks(List<TaskItem> items) {
    return items
        .map(
          (t) => Task(
            id: t.id,
            label: t.label,
            text: t.title,
            done: t.done,
          ),
        )
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  MoodState? _moodFromString(String? value) {
    if (value == null) return null;
    return MoodState.values.where((m) => _moodToString(m) == value).firstOrNull;
  }

  String _moodToString(MoodState mood) {
    return switch (mood) {
      MoodState.focused => 'focused',
      MoodState.driven => 'driven',
      MoodState.calm => 'calm',
      MoodState.lowEnergy => 'low_energy',
      MoodState.strategic => 'strategic',
      MoodState.struggling => 'struggling',
    };
  }

  // ── Mutations ──
  void setTab(int t) {
    tab = t;
    notifyListeners();
  }

  void setView(bool youView) {
    isYouView = youView;
    notifyListeners();
  }

  void setDayOffset(int offset) {
    dayOffset = offset.clamp(-7, 0);
    _loadSelectedDay().then((_) => notifyListeners());
    notifyListeners();
  }

  void setYouMood(MoodState? mood) {
    youMood = mood;
    final id = _activeYouEntryId;
    if (id != null) {
      _entryService.updateEntryState(
        entryId: id,
        state: mood == null ? null : _moodToString(mood),
      );
    }
    notifyListeners();
  }

  void updateTaskText(String id, String text) {
    youTasks = youTasks.map((t) => t.id == id ? t.copyWith(text: text) : t).toList();
    final entryId = _activeYouEntryId;
    if (entryId != null) {
      _entryService.updateTask(
        entryId: entryId,
        taskId: id,
        title: text,
      );
    }
    notifyListeners();
  }

  void updateTaskLabel(String id, String label) {
    youTasks = youTasks.map((t) => t.id == id ? t.copyWith(label: label) : t).toList();
    final entryId = _activeYouEntryId;
    if (entryId != null) {
      _entryService.updateTask(
        entryId: entryId,
        taskId: id,
        label: label,
      );
    }
    notifyListeners();
  }

  void toggleTask(String id) {
    bool? doneValue;
    youTasks = youTasks.map((t) {
      if (t.id != id) return t;
      doneValue = !t.done;
      return t.copyWith(done: doneValue);
    }).toList();
    final entryId = _activeYouEntryId;
    if (entryId != null && doneValue != null) {
      _entryService.updateTask(
        entryId: entryId,
        taskId: id,
        done: doneValue,
      );
    }
    notifyListeners();
  }
}
