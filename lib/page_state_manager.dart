import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvp/response_data.dart';

class PageStateManager {
  /// 私有构造函数
  PageStateManager._internal();

  factory PageStateManager() => _instance;

  /// 单例
  static final PageStateManager _instance = PageStateManager._internal();

  static setLoadingView(WidgetBuilder loadingView) => _instance.loadingView = loadingView;

  static setEmptyView(WidgetBuilder emptyView) => _instance.emptyView = emptyView;

  static setErrorView(ErrorWidgetBuilder errorView) => _instance.errorView = errorView;

  WidgetBuilder loadingView = (context) => const Center(child: CupertinoActivityIndicator());

  WidgetBuilder emptyView = (context) => const Center(child: Text("暂无数据"));

  WidgetBuilder refreshHeader = (context) => const Center(child: Text("暂无数据"));

  /// 上拉加载更多 没有更多数据
  WidgetBuilder noMoreView = (context) => Container(height: 60, alignment: Alignment.center, child: const Text("暂无数据"));

  RouteObserver routeObserver = RouteObserver();

  ErrorWidgetBuilder errorView = (context, data, retry) {
    double contentHeight = 150;
    return LayoutBuilder(builder: (context, constraint) {
      var biggest = constraint.biggest.height;
      double paddingTop = 0;
      if (biggest > contentHeight) {
        // 内容中心 处在屏幕中心的黄金分割点上
        paddingTop = 0.382 * (biggest - contentHeight);
      }
      return Container(
        height: biggest > contentHeight ? biggest : contentHeight,
        padding: EdgeInsets.only(top: paddingTop),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: retry,
              child: const Icon(
                Icons.running_with_errors_sharp,
                size: 120,
              ),
            ),
            const Text('出错了', style: TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      );
    });
  };
}

typedef ErrorWidgetBuilder = Widget Function(BuildContext context, ResponseData data, VoidCallback retry);
