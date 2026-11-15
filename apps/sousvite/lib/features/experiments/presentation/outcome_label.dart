import 'package:domain/domain.dart';
import 'package:sousvite/l10n/l10n.dart';

/// How an experiment turned out, in words.
String outcomeLabel(AppLocalizations l10n, ExperimentOutcome outcome) =>
    switch (outcome) {
      .open => l10n.experiments_outcomeOpen,
      .adopted => l10n.experiments_outcomeAdopted,
      .kept => l10n.experiments_outcomeKept,
    };
