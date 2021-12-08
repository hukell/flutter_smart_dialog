import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';

import 'base_dialog.dart';

class CustomToast extends BaseDialog {
  CustomToast({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  List<Future<void> Function()> _toastList = [];

  DateTime? _lastTime;

  Future<void> showToast({
    required Duration time,
    required bool antiShake,
    required SmartToastStatus status,
    required Widget widget,
  }) async {
    // anti-shake
    if (antiShake) {
      var now = DateTime.now();
      var isShake = _lastTime != null &&
          now.difference(_lastTime!) < SmartDialog.config.antiShakeTime;
      _lastTime = now;
      if (isShake) return;
    }
    config.isExistToast = true;

    // provider some toast display effect
    if (status == SmartToastStatus.normal) {
      _normalToast(time: time, widget: widget);
    } else if (status == SmartToastStatus.last) {
      _lastToast(time: time, widget: widget);
    } else if (status == SmartToastStatus.firstAndLast) {
      _firstAndLastToast(time: time, widget: widget);
    }
  }

  Future<void> _normalToast({
    required Duration time,
    required Widget widget,
  }) async {
    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.length == 0) return;

      mainDialog.show(
        alignment: Alignment.center,
        maskColor: Colors.transparent,
        maskWidget: null,
        animationDuration: Duration(milliseconds: 200),
        isLoading: true,
        isUseAnimation: true,
        isPenetrate: true,
        clickBgDismiss: false,
        widget: widget,
        onDismiss: null,
        onBgTap: () => dismiss(),
      );
      await Future.delayed(time);
      //invoke next toast
      _toastList.removeAt(0);
      await dismiss();

      if (_toastList.length != 0) await _toastList[0]();
    });

    if (_toastList.length == 1) await _toastList[0]();
  }

  Future<void> _lastToast({
    required Duration time,
    required Widget widget,
  }) async {
    mainDialog.show(
      alignment: Alignment.center,
      maskColor: Colors.transparent,
      maskWidget: null,
      animationDuration: Duration(milliseconds: 200),
      isLoading: true,
      isUseAnimation: true,
      isPenetrate: true,
      clickBgDismiss: false,
      widget: widget,
      onDismiss: null,
      onBgTap: () => dismiss(),
    );
    _toastList.add(() async {});
    await Future.delayed(time);
    if (_toastList.length == 1) {
      await dismiss();
    }
    _toastList.removeLast();
  }

  Future<void> _firstAndLastToast({
    required Duration time,
    required Widget widget,
  }) async {
    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.length == 0) return;

      mainDialog.show(
        alignment: Alignment.center,
        maskColor: Colors.transparent,
        maskWidget: null,
        animationDuration: Duration(milliseconds: 200),
        isLoading: true,
        isUseAnimation: true,
        isPenetrate: true,
        clickBgDismiss: false,
        widget: widget,
        onDismiss: null,
        onBgTap: () => dismiss(),
      );
      await Future.delayed(time);
      //invoke next toast
      _toastList.removeAt(0);
      await dismiss();

      if (_toastList.length != 0) await _toastList[0]();
    });

    if (_toastList.length == 1) await _toastList[0]();

    if (_toastList.length > 2) {
      _toastList.removeAt(1);
    }
  }

  Future<void> dismiss() async {
    await mainDialog.dismiss();
    if (_toastList.length != 0) return;

    config.isExistToast = false;
  }
}
