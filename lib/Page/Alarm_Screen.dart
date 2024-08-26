import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Config/Setting_Provider.dart';
import '../Config/color.dart';
import '../main.dart';
import 'MainPage.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _timeString = _formatTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  // SharedPreferences에서 저장된 값을 불러오는 함수
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      settingsProvider.vibrationIntensity =
          prefs.getDouble('vibrationIntensity') ?? 1.0;
      settingsProvider.brightness = prefs.getDouble('brightness') ?? 1.0;
      settingsProvider.textSize = prefs.getDouble('textSize') ?? 40.0;
      settingsProvider.transitionTime = prefs.getInt('transitionTime') ?? 1;
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatTime(now);
    if (mounted)
    setState(() {
      _timeString = formattedTime;
    });
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    return PageView(
      children: [
        Scaffold(
          backgroundColor: DelightColors.background,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 현재 시간
              Column(
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(
                        fontSize: ratio.height * 120,
                        color: DelightColors.grey1,
                        fontWeight: FontWeight.w900),
                  ),
                  Divider(
                    color: Colors.black,
                    indent: 65,
                    endIndent: 65,
                  ),
                ],
              ),
              // 사운드 판별 결과
              Text(
                "Knock",
                style: TextStyle(
                    fontSize: settingsProvider.textSize,
                    color: DelightColors.grey1,
                    fontWeight: FontWeight.w900),
              ),
              // 음성 진폭도 판별
              Container(
                height: ratio.height * 100,
                  child: SoundWaveformWidget())
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          },
          child: Scaffold(
            backgroundColor: DelightColors.background,
            body: Container(
              child: Center(
                  child: Icon(
                Icons.arrow_back,
                size: ratio.width * 200,
                color: DelightColors.grey1,
              )),
            ),
          ),
        ),
      ],
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  const SoundWaveformWidget({
    Key? key,
    this.count = 6,
    this.minHeight = 10,
    this.maxHeight = 30,
    this.durationInMilliseconds = 500,
  }) : super(key: key);
  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.durationInMilliseconds,
        ))
      ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final minHeight = widget.minHeight;
    final maxHeight = widget.maxHeight;
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        double t = controller.value;
        int current = (count * t).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
                (i) => AnimatedContainer(
              duration: Duration(
                  milliseconds: widget.durationInMilliseconds ~/ count),
              margin: i == (count - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5),
              height: i == current ? maxHeight : minHeight,
              width: 5,
              decoration: BoxDecoration(
                color: DelightColors.grey1,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}