import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arch/flutter_arch.dart';
import 'package:flutter_page_base/event_bus/event_bus.dart';
import 'package:flutter_page_base/page_state_manager.dart';

class GlobalLoading extends StatefulWidget {
  static bool init = false;

  static void _init() {
    BuildContext? context = PageStateManager().navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    Overlay.of(context).insert(OverlayEntry(
      builder: (context) => const GlobalLoading(),
      maintainState: true,
      opaque: true,
    ));
    init = true;
  }

  static const eventKey = "GlobalLoading";

  static void show([String? message]) {
    if (!init) {
      _init();
    }
    EventBus.sendEvent(Event(key: eventKey, data: LoadingMsg.show(message)));
  }

  static void dismiss() {
    EventBus.sendEvent(const Event(key: eventKey, data: LoadingMsg.dismiss()));
  }

  const GlobalLoading({Key? key}) : super(key: key);

  @override
  GlobalLoadingState createState() => GlobalLoadingState();
}

class LoadingMsg {
  static const typeShow = 1;
  static const typeDismiss = 0;
  final String? message;
  final int type;

  const LoadingMsg(this.type, {this.message});

  const LoadingMsg.show(this.message) : type = typeShow;

  const LoadingMsg.dismiss()
      : type = typeDismiss,
        message = null;
}

class GlobalLoadingState extends State<GlobalLoading> with BaseViewState<GlobalLoading, SimpleViewModel> {
  bool _isShow = false;

  String get defaultMsg => '加载中';

  Timer? _dismissTimer;

  String message = '';

  void dismiss() {
    _dismissTimer = Timer(const Duration(milliseconds: 50), () {
      setState(() => _isShow = false);
    });
  }

  void show(String? message) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    setState(() {
      this.message = message ?? defaultMsg;
      _isShow = true;
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    message = defaultMsg;
    EventBus.listen<LoadingMsg>(
      events: [const Event.empty(key: GlobalLoading.eventKey)],
      baseView: this,
      listener: onEvent,
    );
  }

  void onEvent(LoadingMsg event) {
    if (event.type == LoadingMsg.typeShow) {
      show(event.message);
    } else {
      dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isShow,
      child: Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.2),
          child: PageStateManager().loadingBuilder.call(context, message)),
    );
  }

  @override
  SimpleViewModel createModel() => SimpleViewModel(context);
}
