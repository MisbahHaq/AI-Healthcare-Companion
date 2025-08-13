import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mintocoin/widgets/mining_button.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, int> balances;
  final VoidCallback onMine;

  const HomeScreen({super.key, required this.balances, required this.onMine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MintoCoin Mining")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MiningButton(onPressed: onMine, isMining: false),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children:
                    balances.entries
                        .map(
                          (e) => ListTile(
                            title: Text(e.key),
                            trailing: Text("${e.value}"),
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 200, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots:
                balances.values
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                    .toList(),
            isCurved: true,
            color: Colors.indigo,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
