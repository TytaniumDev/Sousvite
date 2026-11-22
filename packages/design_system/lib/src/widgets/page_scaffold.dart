import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// A page with an app bar that gets out of the way (DESIGN_SYSTEM.md §10.12).
///
/// The app bar slides away as the page's scroll view scrolls down and snaps
/// back the moment it scrolls up, so its actions are never more than a
/// small scroll away. Its actions end with the [PageActions] the app puts
/// on every page, such as Send feedback.
///
/// The body's vertical scroll views follow the app bar when they use the
/// default controller, as they do unless given one. A body that doesn't
/// scroll keeps the app bar in place, as does a page that turns off
/// [hideOnScroll].
class const PageScaffold({
  /// The page's content.
  required final Widget body,

  /// The app bar's title, or null for none.
  final Widget? title,

  /// Replaces the back button, or null for the default.
  final Widget? leading,

  /// The page's own actions. The [PageActions] follow them.
  final List<Widget> actions = const [],

  /// Whether to show the [PageActions]. False only on pages where they make
  /// no sense, such as the feedback form itself.
  final bool showPageActions = true,

  /// The page's floating action button, or null for none.
  final Widget? floatingActionButton,

  /// Whether the app bar slides away on scroll down. False only where the
  /// app bar shows something the page needs in view, such as cooking
  /// mode's step count.
  final bool hideOnScroll = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pageActions = showPageActions
        ? PageActions.of(context)
        : const <Widget>[];
    final allActions = [...actions, ...pageActions];
    if (!hideOnScroll) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        // A pinned app bar for pages that turn off hiding.
        // ignore: sousvite_lints/page_scaffolds
        appBar: AppBar(title: title, leading: leading, actions: allActions),
        body: body,
      );
    }
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, scrolled) => [
          // Every page's app bar comes from here; the lint sends them.
          // ignore: sousvite_lints/page_scaffolds
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: scrolled,
            title: title,
            leading: leading,
            actions: allActions,
          ),
        ],
        // The app bar already keeps clear of the status bar.
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: body,
        ),
      ),
    );
  }
}

/// The actions the app shows at the end of every [PageScaffold]'s app bar.
///
/// The app puts one of these above every page, so features don't each
/// have to remember its actions.
class const PageActions({
  /// The actions, in order.
  required final List<Widget> actions,
  required super.child,
  super.key,
}) extends InheritedWidget {
  /// The actions above [context], or none.
  static List<Widget> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageActions>()?.actions ??
      const [];

  @override
  bool updateShouldNotify(PageActions oldWidget) =>
      !listEquals(actions, oldWidget.actions);
}
