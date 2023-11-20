import 'package:flutter/material.dart';
import 'package:flutter_arch/flutter_arch.dart';

/// 刷新页面通知
class Event<T> {
  /// 事件类型
  final String key;

  /// 数据
  final T? data;

  const Event({required this.key, this.data});

  /// 事件由来决定 可以相同则代表同一类事件
  @override
  bool operator ==(Object other) {
    if (other is Event) {
      return key == other.key;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return "Event(key:$key,data:$data)";
  }

  const Event.empty({required this.key}) : data = null;

  Event<T> clone(T data) {
    return Event(key: key, data: data);
  }
}

/// 事件总线
class EventBus {
  /// 可观测数据
  static final Map<String, LiveData<Event>> _eventBus = {};

  /// 监听事件
  /// [baseView] 生命周期组件
  /// [events] 要监听的事件
  /// [listener] 回调函数
  static void listen<T>({required List<Event<T>> events, required BaseViewState baseView, ValueChanged<T>? listener}) {
    for (var event in events) {
      if (!_eventBus.containsKey(event.key)) {
        _eventBus.putIfAbsent(event.key, () => LiveData<Event<T>>(Event.empty(key: event.key)));
      }
      _eventBus[event.key]!.listen((t) {
        if (events.contains(t)) {
          listener?.call(t.data);
        }
      }, lifecycleOwner: baseView);
    }
  }

  static T? getLatestData<T>(Event<T> event) {
    return _eventBus[event.key]?.getValue().data;
  }

  /// 发送事件
  /// [event]事件
  static void sendEvent<T>(Event<T> event) {
    if (!_eventBus.containsKey(event.key)) {
      _eventBus.putIfAbsent(event.key, () => LiveData<Event<T>>(Event.empty(key: event.key)));
    }
    _eventBus[event.key]!.setValue(event);
  }
}

/// ViewModel 的默认实现
class SimpleViewModel extends ViewModel {
  const SimpleViewModel(BuildContext context) : super(context);

  @override
  void initData() {}

  @override
  void dispose() {}
}
