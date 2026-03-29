import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../application/providers.dart';
import '../../core/constants.dart';

class DatasetScreen extends ConsumerWidget {
  const DatasetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(datasetControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Collection')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recording State:'),
                Switch(
                  value: state.isRecording,
                  onChanged: (val) {
                    ref.read(datasetControllerProvider.notifier).toggleRecording();
                  },
                ),
              ],
            ),
          ),
          
          if (state.lastSavedFile.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Saved: ${state.lastSavedFile}',
                style: const TextStyle(color: Colors.green),
              ),
            ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRealTimeGraph(state.graphData),
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: AppConstants.availableLabels.length,
                itemBuilder: (context, index) {
                  final label = AppConstants.availableLabels[index];
                  return FilledButton(
                    onPressed: state.isRecording
                        ? () {
                            ref
                                .read(datasetControllerProvider.notifier)
                                .saveLabelAndExport(label);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Saved label: $label')),
                            );
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _getColorForLabel(label),
                    ),
                    child: Text(label),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLabel(String label) {
    switch (label) {
      case 'Slap':
        return Colors.red;
      case 'Drop':
        return Colors.orange;
      case 'Shake':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Idle':
        return Colors.grey;
      default:
        return Colors.deepPurple;
    }
  }

  Widget _buildRealTimeGraph(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text('Start recording to see live data'));
    }

    List<FlSpot> axSpots = [];
    List<FlSpot> aySpots = [];
    List<FlSpot> azSpots = [];

    // only show the last 50 points so it doesn't get too cramped
    final renderData = data.length > 50 ? data.sublist(data.length - 50) : data;

    for (int i = 0; i < renderData.length; i++) {
      axSpots.add(FlSpot(i.toDouble(), renderData[i].ax));
      aySpots.add(FlSpot(i.toDouble(), renderData[i].ay));
      azSpots.add(FlSpot(i.toDouble(), renderData[i].az));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: axSpots,
            isCurved: true,
            color: Colors.redAccent,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: aySpots,
            isCurved: true,
            color: Colors.greenAccent,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: azSpots,
            isCurved: true,
            color: Colors.blueAccent,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
