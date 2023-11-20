import 'dart:async';

import 'global_loading.dart';

/// Future 拓展
/// 执行异步任务 伴随loading
/// [message] loading的提示文案。 默认为 ['加载中'.intl()]
extension FutureExt<T> on Future<T> {
  Future<T> withLoading([String? message, Duration timeout = const Duration(seconds: 20)]) async {
    GlobalLoading.show(message);
    try {
      T result = await this.timeout(timeout);
      GlobalLoading.dismiss();
      return result;
    } catch (e) {
      GlobalLoading.dismiss();
      rethrow;
    }
  }

  Future<T> delay(Duration duration) {
    return Future.delayed(duration, () => this);
  }
}
