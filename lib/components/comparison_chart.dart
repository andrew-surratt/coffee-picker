import 'package:coffee_picker/components/rating_input.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coffees.dart';
import '../services/coffee.dart';

class ComparisonChart extends ConsumerWidget {
  final List<ChartComponent> chartComponents;

  const ComparisonChart({super.key, required this.chartComponents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    Future<List<Coffee>> coffees = getCoffees([
      'Maxwell Medium',
      'Starbucks (In Store)',
      'Counter Culture Hologram',
    ]);

    return FutureBuilder(
        future: coffees,
        builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
          return ScaffoldBuilder(
              body: buildChartBody(
                  flBorderData: buildFlBorderData(themeData),
                  themeData: themeData,
                  context: context,
                  chartComponent: chartComponents,
                  coffeeData: snapshot.data ?? []),
              floatingActionButton: buildFloatingActionButton(context)
          );
        });
  }

  Padding buildChartBody({
    required FlBorderData flBorderData,
    required ThemeData themeData,
    required BuildContext context,
    required List<ChartComponent> chartComponent,
    required List<Coffee> coffeeData}
      ) {
    LineTouchData lineTouchData = buildLineTouchData(themeData, coffeeData);
    LineChart lineChart = buildLineChart(
        lineTouchData: lineTouchData,
        flBorderData: buildFlBorderData(themeData),
        themeData: themeData,
        context: context,
        chartComponent: chartComponents,
        coffeeData: coffeeData);
    return Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 40, 20),
          child: lineChart);
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.small(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RatingInput(),
              )),
          child: const Icon(Icons.navigate_next));
  }
}

class ChartComponent {
  ComponentName componentName;

  ChartComponent(this.componentName);
}

enum ComponentName {
  price,
  rating,
}

LineChart buildLineChart(
    {required LineTouchData lineTouchData,
    required FlBorderData flBorderData,
    required ThemeData themeData,
    required BuildContext context,
    required List<ChartComponent> chartComponent,
    required List<Coffee> coffeeData}) {
  List<LineChartBarData> data = coffeeData.map((e) {
    var data = createLineData(e.costPerOz, Colors.green);
    var rating = 5; //e.rating;
    const maxAlpha = 255;
    const minAlpha = 100;
    const maxRating = 10;
    return data.copyWith(
      color:
          chartComponent.any((c) => c.componentName == ComponentName.rating) &&
                  rating != null
              ? data.color?.withAlpha(
                  (rating * (maxAlpha - minAlpha) / maxRating + minAlpha)
                      .truncate())
              : data.color,
    );
  }).toList();

  return LineChart(LineChartData(
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 20000,
      lineTouchData: lineTouchData,
      titlesData: buildFlTitlesData(themeData, context),
      borderData: flBorderData,
      gridData: const FlGridData(show: false),
      lineBarsData: data));
}

FlBorderData buildFlBorderData(ThemeData themeData) {
  return FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: themeData.primaryColorDark),
      left: BorderSide(color: themeData.primaryColorDark),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );
}

FlTitlesData buildFlTitlesData(ThemeData themeData, BuildContext context) {
  return FlTitlesData(
    bottomTitles: AxisTitles(
      axisNameWidget: Text(
        'Time (years)',
        style: themeData.textTheme.labelMedium,
      ),
      sideTitles: getXTitles(context),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
      axisNameSize: 30,
      axisNameWidget: Text(
        'Opportunity Cost Compared to Investing',
        style: themeData.textTheme.titleMedium,
      ),
    ),
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        'Ending Balance (\$k)',
        style: themeData.textTheme.labelMedium,
      ),
      sideTitles: getYTitles(context),
    ),
  );
}

LineTouchData buildLineTouchData(ThemeData themeData, List<Coffee> coffeeData) {
  return LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 300,
        tooltipBgColor: themeData.scaffoldBackgroundColor.withOpacity(0.2),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            var coffeeDataSelected = coffeeData[touchedSpot.barIndex % 4];
            return LineTooltipItem(
                "${coffeeDataSelected.name} \$${touchedSpot.y.toString()} (\$${coffeeDataSelected.costPerOz}/oz)",
                TextStyle(
                  color: touchedSpot.bar.gradient?.colors.first ??
                      touchedSpot.bar.color ??
                      themeData.colorScheme.primary,
                ));
          }).toList();
        }),
  );
}

SideTitles getYTitles(BuildContext context) {
  const double interval = 1000;
  return getSideTitles(
      interval: interval,
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          (value ~/ interval).toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getXTitles(BuildContext context) {
  return getSideTitles(
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          value.toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getSideTitles({
  required BuildContext context,
  required Text Function(double, BuildContext) getTitleText,
  double interval = 1,
  double reservedSize = 50,
}) {
  return SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (double value, TitleMeta meta) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: getTitleText(value, context),
        );
      });
}
