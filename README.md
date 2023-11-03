## Features

This package provides a set base component to build flutter app page.

## API

[PageStateManager](./lib/page_state_manager.dart) 页面状态管理工具类

```dart
PageStateManager.init
({
// 路由监视器
RouteObserver? routeObserver,
// 下拉刷新头
Widget? refreshHeader,
// 上拉加载底部
Widget? loadMoreFooter,
// 分页加载没有更多数据
Widget? noMoreView,
// 初始化加载视图
Widget? loadingView,
// 无数据视图
Widget? emptyView,
// 错误视图
ErrorWidgetBuilder? errorView,
});
```
[BaseController](./lib/controller/base_controller.dart) 控制BasePageState状态变更刷新视图
[BasePageState](./lib/view/base_page_state.dart) 页面基类 包含页面基本的状态 刷新
[BaseListController](./lib/controller/base_list_controller.dart)控制BaseListState状态变更刷新视图
[BaseListState](./lib/view/base_page_state.dart) 分页加载列表页面基类 支持分页加载 滚动协调
