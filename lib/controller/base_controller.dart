import 'package:flutter/widgets.dart';
import 'package:flutter_arch/flutter_arch.dart';
import 'package:flutter_mvp/model/response_data.dart';

/// 页面数据状态
enum PageState {
  /// 初始状态
  created,

  /// 数据加载中
  loading,

  /// 加载成功
  success,

  /// 获取数据出错
  error,

  /// 没有数据
  empty
}

abstract class BaseController extends ViewModel {
  LiveData<PageState> pageState = LiveData(PageState.loading);

  BaseController(BuildContext context) : super(context);

  /// 数初始化数据 以及刷新页面调用
  @override
  Future initData();

  /// 请求数据成功 更新UI
  void onSuccess() {
    pageState.setValue(PageState.success);
  }

  void initDataWithLoading() {
    loading();
    initData();
  }

  /// 网络请求错误响应
  ResponseData? errorResponse;

  /// 没有数据 更新UI
  void onEmpty() {
    pageState.setValue(PageState.empty);
  }

  /// 显示loading
  void loading() {
    pageState.setValue(PageState.loading);
  }

  /// 出错 更新UI
  void onError() {
    pageState.setValue(PageState.error);
  }

  /// 不改变状态 更新UI
  void setState() {
    PageState state = pageState.getValue();
    pageState.setValue(state);
  }

  @override
  void dispose() {}
}

/// 页面无需数据处理的逻辑时 使用[SimplePageModel] 即可
class SimplePageModel extends BaseController {
  SimplePageModel(BuildContext context) : super(context);

  @override
  Future initData() async {
    onSuccess();
  }
}
