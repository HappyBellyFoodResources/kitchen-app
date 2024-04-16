// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_plus/pull_to_refresh_plus.dart';

import 'package:happy_belly_kitchen/data/api/api_checker.dart';
import 'package:happy_belly_kitchen/data/model/response/order_details_model.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';
import 'package:happy_belly_kitchen/data/repository/order_repo.dart';
import 'package:happy_belly_kitchen/view/base/custom_snackbar.dart';
import 'package:happy_belly_kitchen/view/screens/home/home_screen.dart';

enum OrderStatusTabs { all, confirmed, cooking, done }

class CachedOrderDetailsModel {
  final int id;
  final OrderDetailsModel details;

  CachedOrderDetailsModel({required this.id, required this.details});
}

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});
  TabController? tabController;

  List<Orders>? _orderList = [];
  List<Orders>? get orderList => _orderList;
  set orderList(List<Orders>? value) {
    _orderList = value;
    update();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
  }

  final int _orderListLength = 0;
  int get orderListLength => _orderListLength;
  bool _isFirst = true;
  bool get isFirst => _isFirst;
  final double _discountOnProduct = 0;
  double get discountOnProduct => _discountOnProduct;
  final double _totalTaxAmount = 0;
  double get totalTaxAmount => _totalTaxAmount;
  OrderStatusTabs _selectedBookingStatus = OrderStatusTabs.all;
  OrderStatusTabs get selectedBookingStatus => _selectedBookingStatus;
  int _orderId = 0;
  int get orderId => _orderId;
  String _orderStatus = '';
  String get orderStatus => _orderStatus;
  String _orderNote = '';
  String get orderNote => _orderNote;
  List<CachedOrderDetailsModel> cachedOrderDetails = [];

  OrderDetailsModel _orderDetails = OrderDetailsModel(
      details: [],
      order: Order(
          id: 0,
          tableId: 0,
          numberOfPeople: 0,
          tableOrderId: 0,
          orderNote: '',
          orderStatus: ''));
  OrderDetailsModel get orderDetails => _orderDetails;

  int _offset = 1;
  int get offset => _offset;
  int _pageSize = 1;
  int get pageSize => _pageSize;
  int _orderLength = 1;
  int get orderLength => _orderLength;
  bool _isShadow = true;
  bool get isShadow => _isShadow;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  bool _isDetails = true;
  bool get isDetails => _isDetails;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (_offset < _pageSize) {
          _offset++;
          if (_currentIndex == 0) {
            getOrderList(_offset, reload: false);
          } else if (_currentIndex == 1) {
            filterOrder("confirmed", offset, reload: false);
          } else if (_currentIndex == 2) {
            filterOrder("cooking", offset, reload: false);
          } else if (_currentIndex == 3) {
            filterOrder("ready_for_delivering", offset, reload: false);
          }
        } else {
          _isShadow = false;
          update();
        }
      }
    });
  }

  Future<void> fetchOrders(index) async {
    switch (index) {
      case 0:
        await Get.find<OrderController>().getOrderList(1);
        break;
      case 1:
        await Get.find<OrderController>().filterOrder('confirmed', 1);
        break;
      case 2:
        await Get.find<OrderController>().filterOrder('cooking', 1);
        break;
      case 3:
        await Get.find<OrderController>()
            .filterOrder('ready_for_delivering', 1);
        break;
    }
  }

  final List<Tab> orderTypeList = <Tab>[
    Tab(text: 'all'.tr),
    Tab(text: 'confirmed'.tr),
    Tab(text: 'cooking'.tr),
    Tab(text: 'done'.tr),
  ];

  Future<void> getOrderList(int offset,
      {bool reload = true, bool refetch = false}) async {
    _offset = offset;

    if (refetch == false) {
      _isLoading = true;
      update();
    }

    Response response = await orderRepo.getOrderList(offset);
    if (response.statusCode == 200) {
      OrderModel orderModel = OrderModel.fromJson(response.body);
      if (refetch == false) {
        if (reload) {
          _orderList = [];
        }

        for (var order in orderModel.data!) {
          _orderList!.add(order);
        }
        _pageSize = orderModel.lastPage!;
      } else {
        List<Orders> tempList = [];
        for (var order in orderModel.data!) {
          tempList.add(order);
        }
        _orderList = tempList;
      }

      _orderLength = orderModel.total!;
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> searchOrder(String orderId) async {
    _isFirst = true;
    _orderList = null;
    setIndex(0);
    updateOrderStatusTabs(OrderStatusTabs.all);
    Response response = await orderRepo.searchOrder(orderId);
    if (response.statusCode == 200) {
      _orderList = [];
      OrderModel orderModel = OrderModel.fromJson(response.body);
      for (var order in orderModel.data!) {
        _orderList!.add(order);
      }

      _isLoading = false;
      _isFirst = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> filterOrder(String orderType, int offset,
      {bool reload = true, bool refetch = false}) async {
    _offset = offset;

    if (refetch == false) {
      _isLoading = true;

      if (reload || (offset == 1)) {
        _orderList = null;
        _isFirst = true;
      }
    }

    setIndex(orderType == 'confirmed'
        ? 1
        : orderType == 'cooking'
            ? 2
            : 3);
    Response response = await orderRepo.filterOrder(orderType, offset);
    if (response.statusCode == 200) {
      OrderModel orderModel = OrderModel.fromJson(response.body);

      if (refetch == false) {
        if (reload || (offset == 1)) {
          _orderList = [];
        }

        for (var order in orderModel.data!) {
          _orderList!.add(order);
        }
      } else {
        List<Orders> tempList = [];
        for (var order in orderModel.data!) {
          tempList.add(order);
        }
        _orderList = tempList;
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isFirst = false;
    _isLoading = false;
    update();
  }

  Future<OrderDetailsModel> getOrderDetails(int orderID) async {
    _isDetails = true;
    Response apiResponse = await orderRepo.getOrderDetails(orderID);
    if (apiResponse.statusCode == 200) {
      if (apiResponse.body['order']['order_status'] != 'delivered' &&
          apiResponse.body['order']['order_status'] != 'out_for_delivery') {
        _orderDetails = OrderDetailsModel.fromJson(apiResponse.body);
        cachedOrderDetails
            .add(CachedOrderDetailsModel(id: orderID, details: _orderDetails));
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isDetails = false;
    update();
    return _orderDetails;
  }

  Future<void> orderStatusUpdate(int orderId, String orderStatus) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.updateOrderStatus(orderId, orderStatus);
    if (response.statusCode == 200) {
      if (orderStatus == "cooking") {
        setIndex(2);
      } else {
        setIndex(3);
      }

      fetchOrders(tabController?.index);
      showCustomSnackBar("order_status_updated_successfully".tr,
          isError: false);
      // if (Get.width < 640) {
      //   Get.to(const HomeScreen(fromFilter: true));
      // }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateOrderStatusTabs(OrderStatusTabs bookingStatusTabs) {
    // _isFirst = true;
    _selectedBookingStatus = bookingStatusTabs;
    // _orderList = [];
    // _isFirst = true;
  }

  void setOrderIdForOrderDetails(
      int orderId, String orderStatus, String orderNote) {
    _orderId = orderId;
    _orderStatus = orderStatus;
    _orderNote = orderNote;
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void removeFirstLoading() {
    _isFirst = true;
    update();
  }

  void setIndex(int index) {
    _currentIndex = index;
    update();
  }
}
