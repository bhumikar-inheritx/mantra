import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../providers/mini_player_provider.dart';
import 'mini_player_widget.dart';

import '../../../main.dart';

/// A scaffold wrapper that automatically includes the global mini player.
/// Use this on every screen that is pushed via Navigator to ensure
/// the mini player remains visible, matching the Shanti app's CalmScaffold pattern.
class DeepMantraScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showMiniPlayer;
  final Color? backgroundColor;

  const DeepMantraScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showMiniPlayer = true,
    this.backgroundColor,
  });

  @override
  State<DeepMantraScaffold> createState() => _DeepMantraScaffoldState();
}

class _DeepMantraScaffoldState extends State<DeepMantraScaffold> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is ModalRoute<void>) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _updateOffset();
  }

  @override
  void didPopNext() {
    _updateOffset();
  }

  void _updateOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final offset = widget.bottomNavigationBar != null 
            ? AppSizes.bottomNavBarHeight 
            : 0.0;
        context.read<MiniPlayerProvider>().setBottomOffset(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: widget.backgroundColor,
      appBar: widget.appBar,
      body: Consumer4<
        AudioPlayerProvider,
        AudioChantProvider,
        PracticeSessionProvider,
        MiniPlayerProvider
      >(
        builder: (context, audio, chant, practice, miniPlayer, child) {
          final bool isPlayerVisible = widget.showMiniPlayer && 
              miniPlayer.showMiniPlayer(audio, chant, practice);

          // Calculate padding ONLY for the mini player.
          // The Scaffold already handles the BottomNavigationBar layout since extendBody is false.
          final double bottomPadding = isPlayerVisible 
              ? AppSizes.miniPlayerHeight + 4.h 
              : 0;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: widget.body,
          );
        },
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar != null
          ? SafeArea(
              top: false,
              bottom: false, // Scaffold handles bottom safety with BottomNavigationBar
              child: widget.bottomNavigationBar!,
            )
          : null,
    );
  }
}
