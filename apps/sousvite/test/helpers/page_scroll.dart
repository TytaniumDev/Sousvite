import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// What to drag to scroll a page built with `PageScaffold`: its
/// `NestedScrollView`, which passes the drag to the content under it and
/// slides the app bar. Pass it as `scrollable:` to `scrollUntilVisible`.
Finder get pageScrollable => find.byType(Scrollable).first;
