import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_base/model/response_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PageStateManager {
  /// 私有构造函数
  PageStateManager._internal();

  factory PageStateManager() => _instance;

  /// 单例
  static final PageStateManager _instance = PageStateManager._internal();

  /// 路由监视器
  RouteObserver routeObserver = RouteObserver();

  /// loading视图
  Widget loadingView = const Center(child: CupertinoActivityIndicator());

  /// 无数据空视图
  Widget emptyView = const Center(child: Text("暂无数据"));

  /// 刷新头
  Widget refreshHeader = const ClassicHeader();

  /// 加载更多视图
  Widget loadingMoreFooter = const ClassicFooter();

  /// 上拉加载更多 没有更多数据
  Widget noMoreView = Container(height: 60, alignment: Alignment.center, child: const Text("已全部加载"));

  /// 错误页面视图
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

  static void init({
    RouteObserver? routeObserver,
    Widget? refreshHeader,
    Widget? loadMoreFooter,
    Widget? noMoreView,
    Widget? loadingView,
    Widget? emptyView,
    ErrorWidgetBuilder? errorView,
  }) {
    if (routeObserver != null) {
      _instance.routeObserver = routeObserver;
    }
    if (refreshHeader != null) {
      _instance.refreshHeader = refreshHeader;
    }
    if (loadMoreFooter != null) {
      _instance.loadingMoreFooter = loadMoreFooter;
    }
    if (noMoreView != null) {
      _instance.noMoreView = noMoreView;
    }
    if (loadingView != null) {
      _instance.loadingView = loadingView;
    }
    if (emptyView != null) {
      _instance.emptyView = emptyView;
    }
    if (errorView != null) {
      _instance.errorView = errorView;
    }
  }
}

typedef ErrorWidgetBuilder = Widget Function(BuildContext context, ResponseData data, VoidCallback retry);
