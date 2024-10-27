import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// Custom header to adjust pull distance
class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClassicHeader(
      refreshingText: '',
      completeText: '',
      failedText: 'Refresh Failed',
      idleText: '',
      releaseText: '',
      height: 100.0, // Adjust height for pull distance
    );
  }
}

// Reusable Pull-to-Refresh Widget
class PullToRefresh extends StatefulWidget {
  final Widget child; // Any widget can be passed here

  const PullToRefresh({
    super.key,
    required this.child,
  });

  @override
  PullToRefreshState createState() => PullToRefreshState();
}

class PullToRefreshState extends State<PullToRefresh> {
  late RefreshController refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    refreshController.dispose(); // Dispose the controller when not in use
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      physics: const BouncingScrollPhysics(),
      controller: refreshController,
      header: const CustomHeader(), // Use the custom header here
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));

        // Notify the controller that the refresh is completed
        refreshController.refreshCompleted();
      },
      child: widget.child, // Display the passed child widget
    );
  }
}
