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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: widget.backgroundColor,
      appBar: widget.appBar,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: Consumer4<
        AudioPlayerProvider,
        AudioChantProvider,
        PracticeSessionProvider,
        MiniPlayerProvider
      >(
        builder: (context, audio, chant, practice, miniPlayer, child) {
          final bool isPlayerVisible = widget.showMiniPlayer && 
              miniPlayer.showMiniPlayer(audio, chant, practice);

          if (!isPlayerVisible && widget.bottomNavigationBar == null) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPlayerVisible)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: const DeepMantraMiniPlayer(),
                ),
              if (widget.bottomNavigationBar != null)
                widget.bottomNavigationBar!,
            ],
          );
        },
      ),
    );
  }
}
