import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/property_journey_model.dart';
import '../services/journey_service.dart';
import '../theme/app_colors.dart';
import 'property_journey_screen.dart';

class MyJourneysScreen extends StatefulWidget {
  final int userId;

  const MyJourneysScreen({super.key, required this.userId});

  @override
  State<MyJourneysScreen> createState() => _MyJourneysScreenState();
}

class _MyJourneysScreenState extends State<MyJourneysScreen> {
  static final _priceFmt = NumberFormat('#,##,###');

  List<PropertyJourneyModel> _journeys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await JourneyService.loadAll(widget.userId);
    if (!mounted) return;
    setState(() {
      _journeys = list;
      _loading = false;
    });
  }

  Future<void> _delete(PropertyJourneyModel j) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journey?'),
        content: Text(
            'Remove the purchase journey for "${j.propertyTitle}"? '
            'This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await JourneyService.delete(j.id);
      _load();
    }
  }

  Future<void> _openJourney(PropertyJourneyModel j) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PropertyJourneyScreen(journey: j, userId: widget.userId),
      ),
    );
    _load(); // refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(title: const Text('My Journeys')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _journeys.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: _journeys.length,
                    itemBuilder: (_, i) =>
                        _JourneyCard(_journeys[i], _openJourney, _delete),
                  ),
                ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _EmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.route,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('No Journeys Yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Open a property listing and tap\n"Start Purchase Journey" to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Journey card ──────────────────────────────────────────────────────────────

class _JourneyCard extends StatelessWidget {
  static final _priceFmt = NumberFormat('#,##,###');
  static final _dateFmt = DateFormat('d MMM yyyy');

  final PropertyJourneyModel journey;
  final Future<void> Function(PropertyJourneyModel) onOpen;
  final Future<void> Function(PropertyJourneyModel) onDelete;

  const _JourneyCard(this.journey, this.onOpen, this.onDelete);

  @override
  Widget build(BuildContext context) {
    final count = journey.completedCount;
    final progress = count / 6.0;
    final isDone = journey.isComplete;

    return Dismissible(
      key: Key(journey.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        await onDelete(journey);
        return false; // Let _delete handle the state update
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          onTap: () => onOpen(journey),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + status badge ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_work_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journey.propertyTitle,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (journey.propertyCity != null ||
                              journey.propertyPrice != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              [
                                if (journey.propertyCity != null)
                                  journey.propertyCity!,
                                if (journey.propertyPrice != null)
                                  '₹ ${_priceFmt.format(journey.propertyPrice)}',
                              ].join(' • '),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Complete',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Progress bar ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                              isDone
                                  ? AppColors.success
                                  : AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('$count / 6',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppColors.success
                                : AppColors.textSecondary)),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Footer: date + button ───────────────────────────────
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Updated ${_dateFmt.format(journey.updatedAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    Text(
                      isDone ? 'View Journey →' : 'Continue →',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
