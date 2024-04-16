// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:happy_belly_kitchen/controller/demo_data_controller.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';
import 'package:happy_belly_kitchen/util/images.dart';
import 'package:happy_belly_kitchen/view/screens/home/home_screen_new.dart';
import 'package:happy_belly_kitchen/view/screens/home/widget/new/order_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderListView extends StatefulWidget {
  const OrderListView({
    super.key,
    required this.activeTab,
    required this.activeScreen,
  });

  final int activeTab;
  final int activeScreen;

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  var demoOrder = DemoDataController().demoOrderList;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GetBuilder<OrderController>(builder: (orderController) {
      List<Orders>? orderList = [];
      if (orderController.isLoading) {
        orderList = DemoDataController().demoOrderList;
      } else {
        if (widget.activeScreen == 0) {
          orderList = orderController.orderList;
        } else {
          orderList = orderController.orderList
              ?.where((e) => e.screenId == widget.activeScreen)
              .toList();
        }
      }

      return orderList!.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Image.asset(
                    Images.emptyBox,
                    width: 50,
                  ),
                  SizedBox(height: 10),
                  Text("Oops! nothing is here",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                ])
          : Skeletonizer(
              enabled: orderController.isLoading,
              ignoreContainers: false,
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                options: CarouselOptions(
                  pageSnapping: screenWidth > 600 ? false : true,
                  scrollDirection: Axis.horizontal,
                  aspectRatio: 3 / 5,
                  enlargeFactor: 0.1,
                  enlargeCenterPage: screenWidth > 600 ? false : true,
                  viewportFraction: (() {
                    if (screenWidth > 1700) {
                      // For desktop
                      return 0.22;
                    }
                    if (screenWidth > 1000) {
                      // For desktop
                      return 0.3;
                    } else if (screenWidth > 600) {
                      // For tablet
                      return 0.5;
                    } else if (screenWidth > 500) {
                      // For tablet
                      return 0.8;
                    } else {
                      // For mobile
                      return 0.9;
                    }
                  })(),
                  enableInfiniteScroll: false,
                ),
                itemCount: orderList?.length ?? 0,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  var item = orderList![itemIndex];
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, -1.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: OrderItem(
                      key:
                          ValueKey(itemIndex), // Use a unique key for each item
                      item: item,
                      itemIndex: itemIndex,
                      carouselController: _carouselController,
                    ),
                  );
                },
              ),
            );
    });
  }
}
