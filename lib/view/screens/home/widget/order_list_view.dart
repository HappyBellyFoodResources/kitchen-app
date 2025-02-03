import 'package:flutter/cupertino.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';
import 'package:happy_belly_kitchen/helper/responsive_helper.dart';
import 'package:happy_belly_kitchen/util/dimensions.dart';
import 'package:happy_belly_kitchen/view/base/no_data_screen.dart';
import 'package:happy_belly_kitchen/view/screens/home/widget/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_plus/pull_to_refresh_plus.dart';

class OrderListView extends StatefulWidget {
  final TabController tabController;

  const OrderListView({Key? key, required this.tabController})
      : super(key: key);

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  var refreshController = RefreshController();
  var refreshController2 = RefreshController();

  @override
  void dispose() {
    refreshController.dispose();
    refreshController2.dispose();
    super.dispose();
  }

  refresh() async {
    switch (widget.tabController.index) {
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
    refreshController.refreshCompleted();
    refreshController2.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        (Get.height / Get.width) > 1 && (Get.height / Get.width) < 1.7;
    return SmartRefresher(
      controller: refreshController2,
      onRefresh: () async {
        refresh();
      },
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          List<Orders>? orderList = orderController.orderList;
          return Padding(
            padding: const EdgeInsets.only(
              right: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
            ),
            child: Column(children: [
              Get.find<OrderController>().isLoading == false &&
                      orderList != null
                  ? orderList.isNotEmpty
                      ? Expanded(
                          child: SmartRefresher(
                            controller: refreshController,
                            onRefresh: () async {
                              refresh();
                            },
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: orderController.scrollController,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    ResponsiveHelper.isSmallTab() || isMobile
                                        ? 3
                                        : !ResponsiveHelper.isTab(context)
                                            ? 2
                                            : 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: ResponsiveHelper.isSmallTab()
                                    ? 0.75
                                    : ResponsiveHelper.isTab(context)
                                        ? 0.85
                                        : 1 / 1.2,
                              ),
                              padding: const EdgeInsets.all(0),
                              itemCount: orderList.length,
                              itemBuilder: (context, index) {
                                return OrderCardWidget(order: orderList[index]);
                              },
                            ),
                          ),
                        )
                      : const NoDataScreen()
                  : const Expanded(
                      child: Center(child: CupertinoActivityIndicator())),
              orderController.isLoading && orderController.orderList != null
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(Dimensions.iconSize),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                    ))
                  : const SizedBox.shrink(),
            ]),
          );
        },
      ),
    );
  }
}
//order: orderList[index]