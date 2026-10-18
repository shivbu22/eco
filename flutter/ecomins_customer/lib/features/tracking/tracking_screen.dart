import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tracking_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    super.key,
    required this.jobId,
    required this.token,
  });

  final String jobId;
  final String token;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Start tracking after the first frame so the provider tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TrackingProvider>().startTracking(
              widget.jobId,
              widget.token,
            );
      }
    });
  }

  @override
  void dispose() {
    context.read<TrackingProvider>().stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final isCompleted = tracking.jobStatus == JobStatus.completed;
    final showReconnecting =
        !tracking.isConnected && tracking.jobStatus != JobStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Job'),
      ),
      body: Column(
        children: [
          // ── Reconnecting banner ──────────────────────────────────────────
          if (showReconnecting)
            MaterialBanner(
              backgroundColor: Colors.amber.shade100,
              content: const Text('Reconnecting…'),
              leading: const Icon(Icons.wifi_off, color: Colors.amber),
              actions: const [SizedBox.shrink()],
            ),

          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: isCompleted
                ? _CompletionCard(onBackToHome: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  })
                : _StatusTimeline(tracking: tracking),
          ),
        ],
      ),
    );
  }
}

// ── Completion card ──────────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.onBackToHome});

  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                'Service Completed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onBackToHome,
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status timeline ──────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.tracking});

  final TrackingProvider tracking;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status history items
        ...tracking.statusHistory.map(
          (event) => _TimelineItem(event: event),
        ),

        // Worker location
        if (tracking.workerLat != null && tracking.workerLng != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Worker Location'),
              subtitle: Text(
                'Lat: ${tracking.workerLat!.toStringAsFixed(5)}, '
                'Lng: ${tracking.workerLng!.toStringAsFixed(5)}',
              ),
            ),
          ),
        ],

        // Empty state
        if (tracking.statusHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Waiting for updates…',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Single timeline item ─────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event});

  final StatusEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.green),
              Container(
                width: 2,
                height: 32,
                color: Colors.green.shade200,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatTime(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
