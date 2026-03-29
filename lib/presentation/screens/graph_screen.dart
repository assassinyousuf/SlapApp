import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../application/providers.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can reuse the dataset controller state since it already buffers graph data
    // Or we can just watch the slap controller's buffer. We'll use slapController since it's always listening.
    // We want to rebuild whenever slapController state changes
    ref.watch(slapControllerProvider);
    final buffer = ref.read(slapControllerProvider.notifier).sensorBuffer.toList;

    return Scaffold(
      appBar: AppBar(title: const Text('Oscilloscope')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Real-Time Sensor Waves',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRealTimeGraph(buffer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.redAccent, 'Accel X'),
                _buildLegendItem(Colors.greenAccent, 'Accel Y'),
                _buildLegendItem(Colors.blueAccent, 'Accel Z'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildRealTimeGraph(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text('Start detection to see live data'));
    }

    List<FlSpot> axSpots = [];
    List<FlSpot> aySpots = [];
    List<FlSpot> azSpots = [];

    // Keep it oscilloscope style (last 100 points)
    final renderData = data.length > 100 ? data.sublist(data.length - 100) : data;

    for (int i = 0; i < renderData.length; i++) {
      axSpots.add(FlSpot(i.toDouble(), renderData[i].ax));
      aySpots.add(FlSpot(i.toDouble(), renderData[i].ay));
      azSpots.add(FlSpot(i.toDouble(), renderData[i].az));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        lineBarsData: [
          LineChartBarData(
            spots: axSpots,
            isCurved: true,
            color: Colors.redAccent,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
          LineChartBarData(
            spots: aySpots,
            isCurved: true,
            color: Colors.greenAccent,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
          LineChartBarData(
            spots: azSpots,
            isCurved: true,
            color: Colors.blueAccent,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
        ],
        minY: -40,
        maxY: 40,
      ),
      // To animate nicely without flickering:
      duration: const Duration(milliseconds: 0),
    );
  }
}
