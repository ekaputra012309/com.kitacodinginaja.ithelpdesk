import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../../constans.dart';
import '../request_model.dart';
import 'item_card.dart';

class TimelineWidget extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final VoidCallback onRefresh;

  const TimelineWidget({
    super.key, 
    required this.items, 
    required this.scaffoldMessengerKey , 
    required this.onRefresh
  });

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FixedTimeline.tileBuilder(
          builder: TimelineTileBuilder.connected(
            contentsAlign: ContentsAlign.basic,
            nodePositionBuilder: (context, index) => 0.0,
            connectorBuilder: (context, index, type) {
              return const SolidLineConnector(
                color: CustomColors.first,
              );
            },
            indicatorBuilder: (context, index) {
              return const DotIndicator(
                color: CustomColors.second,
              );
            },
            itemCount: items.length,
            contentsBuilder: (context, index) {
              final item = items[index];
              if (item is String) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              } else if (item is DataItem) {
                return ItemCard(item: item, scaffoldMessengerKey: scaffoldMessengerKey, onDelete: onRefresh);
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
