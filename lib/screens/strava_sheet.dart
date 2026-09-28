import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/workout.dart';
import '../services/fit_export.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/ui_kit.dart';

void showStravaSheet(BuildContext context) => showAppSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _StravaSheet(),
    );

const _brand = 'Strava';

class _StravaSheet extends StatelessWidget {
  const _StravaSheet();

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final list = [...fit.sessions]..sort((a, b) => b.date.compareTo(a.date));
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.82),
      padding: sheetPad(context),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Row(children: [
            Text(_brand, style: AppTheme.f(21, weight: FontWeight.w700, color: gc.text)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: gc.accentSoft, borderRadius: BorderRadius.circular(100)),
              child: Text(t.stravaBeta,
                  style: AppTheme.f(10.5, weight: FontWeight.w800, color: gc.accent, letterSpacing: 1.2)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(t.stravaIntro,
              style: AppTheme.f(13, weight: FontWeight.w500, color: gc.textSecondary, height: 1.45)),
          const SizedBox(height: 16),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(t.stravaEmpty,
                  textAlign: TextAlign.center,
                  style: AppTheme.f(13.5, weight: FontWeight.w600, color: gc.textTertiary)),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _row(context, gc, list[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, GymColors gc, LoggedSession s) {
    final minutes = s.durationSec ~/ 60;
    return Pressable(
      onTap: () => shareWorkoutFit(s),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.longDate(s.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.f(14.5, weight: FontWeight.w700, color: gc.text)),
              const SizedBox(height: 3),
              Text('${t.setCount(s.setCount)}${minutes > 0 ? ' · $minutes min' : ''}',
                  style: AppTheme.f(12, weight: FontWeight.w500, color: gc.textSecondary)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: gc.accentSoft, shape: BoxShape.circle),
            child: Icon(PhosphorIconsRegular.export, size: 17, color: gc.accent),
          ),
        ]),
      ),
    );
  }
}

Future<void> shareWorkoutFit(LoggedSession s) async {
  try {
    final dir = await getTemporaryDirectory();
    final d = s.date;
    final stamp = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/GymMane $stamp.fit');
    await file.writeAsBytes(workoutFit(s, pounds: fit.isLb));
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: t.exportForStravaHint));
  } catch (_) {}
}
