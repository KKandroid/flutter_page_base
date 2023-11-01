import 'package:flutter/material.dart';
import 'package:flutter_mvp/paging_data.dart';

import 'base_page_model.dart';
import 'response_data.dart';

/// 长列表 model
abstract class BaseListModel<D> extends BasePageModel {
  bool hasMore = true;

  /// 每页数据条数
  int pageSize = 20;

  /// 当前类维护，子类只能通过get读取
  int _pageNo = 1;

  int get pageNo => _pageNo;

  /// 列表数据
  List<D> data = [];

  BaseListModel(BuildContext context) : super(context);

  @override
  Future initData() async {
    _pageNo = 1;
    hasMore = true;
    await loadData();
  }

  D getItem(int index) {
    if (index >= dataListSize) {
      throw Exception("index:$index out of bound");
    }
    return data[index];
  }

  int get dataListSize => data.length;

  /// 加载数据成功 后调用更新状态与数据
  @Deprecated("存在并发安全的问题,快速滑动，会出现数据重复。使用[onLoadCompleted]代替 ")
  void onLoadSuccess(List<D> data) {
    if (_pageNo == 1) {
      // 加载的数据是第一页时 直接赋值
      this.data = data;
    } else {
      this.data.addAll(data);
    }
    onSuccess();
    _pageNo++;
  }

  /// 加载数据成功 后调用更新状态与数据
  /// [data]
  /// [resultPageNo] data 对应的 pageNo 不要使用成员 [_pageNo]
  @Deprecated("分页数据 结构处理 使用[onLoadDataCompleted]代替，使用时确保 数据结果必须 继承 MaPageData")
  void onLoadCompleted(List<D> data, int resultPageNo) {
    if (resultPageNo == 1) {
      // 加载的数据是第一页时 直接赋值
      this.data = data;
    } else {
      this.data.addAll(data);
    }
    _pageNo = resultPageNo + 1;
    onSuccess();
  }

  /// 加载数据 bool 为是否还有更多数据
  Future<bool> loadData();

  /// 分页 数据夹在完成时调用,数据结果必须 继承 MaPageData
  bool onLoadDataCompleted(ResponseData<PagingData<D>> response) {
    var result = response.result;
    if (response.success && result != null) {
      onLoadDataSuccess(result);
    } else {
      onLoadDataError(response);
    }
    return hasMore;
  }

  /// 加载数据成功
  void onLoadDataSuccess(PagingData<D> result) {
    var dataList = result.data;
    var dataPageNo = result.page!;
    if (dataList?.isNotEmpty ?? false) {
      if (dataPageNo == 1) {
        // 加载的数据是第一页时 直接赋值
        data = dataList!;
      } else {
        data.addAll(dataList!);
      }
      _pageNo = dataPageNo + 1;
      onSuccess();
    } else {
      if (pageNo == 1) {
        data = [];
        onEmpty();
      }
    }
    if ((dataList?.length ?? 0) < pageSize || dataListSize == result.total!) {
      hasMore = false;
    }
  }

  /// 加载数据出错
  void onLoadDataError(ResponseData response) {
    if (pageNo == 1) {
      onError();
    }
  }
}
