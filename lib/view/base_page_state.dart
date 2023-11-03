import 'package:flutter/material.dart';
import 'package:flutter_arch/flutter_arch.dart';
import 'package:flutter_page_base/controller/base_controller.dart';
import 'package:flutter_page_base/page_state_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';



/// 可刷新的页面
abstract class BasePageState<T extends StatefulWidget, M extends BaseController> extends State<T>
    with BaseViewState<T, M>, AutomaticKeepAliveClientMixin, RouteAware, WidgetsBindingObserver {
  /// 页面状态
  PageState? pageState;

  /// 页面进入back stack中，仍然存活但不可见
  late bool isPagePause;

  /// 下拉刷新控制器
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  /// ListView 滚动控制器
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    pageState = model.pageState.getValue();
    model.pageState.listen((state) => setState(() => pageState = state), lifecycleOwner: this);
    WidgetsBinding.instance.addObserver(this);
    isPagePause = false;
  }

  @override
  @mustCallSuper
  void didPushNext() {
    isPagePause = true;
  }

  @override
  @mustCallSuper
  void didPopNext() {
    isPagePause = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageStateManager().routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  bool _keyboardShow = false;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPagePause) return;
      if (!mounted) return;
      var queryData = MediaQuery.maybeOf(context);
      if (queryData == null) return;
      if (queryData.viewInsets.bottom == 0 && _keyboardShow) {
        //关闭键盘
        _keyboardShow = false;
        onKeyboardHide();
      } else if (queryData.viewInsets.bottom > 0 && !_keyboardShow) {
        //显示键盘
        _keyboardShow = true;
        onKeyboardShow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: pageBgColor(),
      body: buildBody(context),
      extendBodyBehindAppBar: extendBodyBehindAppBar(),
    );
  }

  Widget buildBody(BuildContext context) {
    switch (pageState) {
      case PageState.loading:
        return buildLoadingView(context, model);
      case PageState.error:
        return buildErrorView(context, model);
      default:
        return buildSuccessView(context, model);
    }
  }

  Widget buildSuccessView(BuildContext context, M model) {
    var refreshBody = SmartRefresher(
      header: refreshHeader(context),
      controller: refreshController,
      enablePullDown: enableRefresh(),
      onRefresh: () => onRefresh(model),
      enablePullUp: false,
      scrollController: scrollController,
      child: pageState == PageState.empty ? buildEmptyView(context, model) : buildContentView(context, model),
    );
    var bottom = buildFixedBottom(context, model);
    if (bottom != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: refreshBody), bottom],
      );
    } else {
      return refreshBody;
    }
  }

  /// 固定底部的视图 不受刷新影响
  Widget? buildFixedBottom(BuildContext context, M model) => null;

  Widget refreshHeader(BuildContext context) {
    return PageStateManager().refreshHeader;
  }

  void onRefresh(M model) {
    model.initData().then((_) {
      refreshController.refreshCompleted();
    }).catchError((e) {
      refreshController.refreshFailed();
    });
  }

  /// 是否支持刷新
  bool enableRefresh() => false;

  /// 数据为空的界面，自定义请覆写
  Widget buildEmptyView(BuildContext context, M model) {
    return PageStateManager().emptyView;
  }

  /// 加载视图，自定义请覆写
  Widget buildLoadingView(BuildContext context, M model) {
    return PageStateManager().loadingView;
  }

  /// 请求数据错误，自定义请覆写
  Widget buildErrorView(BuildContext context, M model) {
    return PageStateManager().errorView.call(context, model.errorResponse!, () {
      model.initDataWithLoading();
    });
  }

  /// 页面的背景颜色
  Color pageBgColor() {
    return Colors.white;
  }

  /// AppBar
  PreferredSizeWidget buildAppBar();

  /// body 延伸到 AppBar下面
  bool extendBodyBehindAppBar() => false;

  /// 绘制页面内容
  Widget buildContentView(BuildContext context, M model);

  /// 切换到后台需要保持状态否？（page View 切换的时候是否会销毁重建）
  @override
  bool get wantKeepAlive => false;

  @override
  void dispose() {
    refreshController.dispose();
    PageStateManager().routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onKeyboardHide() {}

  void onKeyboardShow() {}
}
