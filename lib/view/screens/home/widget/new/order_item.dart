import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happy_belly_kitchen/controller/demo_data_controller.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/data/model/response/order_details_model.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';
import 'package:happy_belly_kitchen/view/screens/home/widget/new/order_list.dart';
import 'package:happy_belly_kitchen/view/screens/home/widget/new/order_summary_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({
    super.key,
    required this.item,
    required this.carouselController,
    required this.itemIndex,
  });

  final Orders item;
  final CarouselController carouselController;
  final int itemIndex;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  Future<OrderDetailsModel>? orderDetails;
  var demoOrderDetails = DemoDataController().demoOrderDetails;

  @override
  void initState() {
    super.initState();
    if (Get.find<OrderController>().isLoading) {
      orderDetails = Future.value(DemoDataController().demoOrderDetails);
    } else {
      var cachedDetails = Get.find<OrderController>()
          .cachedOrderDetails
          .where((e) => e.id == widget.item.id);
      if (cachedDetails.isNotEmpty) {
        print("Fetching order details from cached");
        orderDetails = Future.value(cachedDetails.toList().first.details);
      } else {
        print("Fetching order details from network");
        orderDetails =
            Get.find<OrderController>().getOrderDetails(widget.item.id!);
      }
    }
  }

  String formatTimeAgo(String inputDate) {
    // Parse the input date string into a DateTime object
    DateTime dateTime = DateTime.parse(inputDate);

    // Get the current date and time
    DateTime now = DateTime.now();

    // Calculate the time difference between the input date and now
    Duration difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderDetailsModel>(
        future: orderDetails,
        builder: (context, asyncSnapshot) {
          return Card(
            elevation: 10,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.grey.withOpacity(0.2),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Skeleton.leaf(
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID: ${widget.item.id}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFBFBFB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                widget.item.orderStatus ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF4F4F4F),
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              widget.item.deliveryAddress?.contactPersonName ??
                                  '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            widget.item.isFirstOrder == '1'
                                ? Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.red),
                                    child: const Text('New User',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  )
                                : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.item.kitchenNote != "")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CUSTOMER NOTE',
                                      style: TextStyle(
                                        color: Color(0xFF868686),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      height: 3,
                                    ),
                                    const SizedBox(height: 10),
                                    // Container(
                                    //   width: double.infinity,
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 15, vertical: 10),
                                    //   decoration: BoxDecoration(
                                    //       color: const Color(0xFCECECEB),
                                    //       borderRadius:
                                    //           BorderRadius.circular(15)),
                                    //   child: Text(widget.item.orderNote ?? ''),
                                    // ),
                                    Container(
                                      width: double.infinity,
                                      height:
                                          90, // Set a fixed height for the container
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFCECECEB),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(widget.item.kitchenNote),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              const Text(
                                'ORDER SUMMARY',
                                style: TextStyle(
                                  color: Color(0xFF868686),
                                  fontSize: 12,
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                                height: 3,
                              ),
                            ],
                          ),
                        ),
                        if (asyncSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            Get.find<OrderController>().isLoading) ...[
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child:
                                  Center(child: CupertinoActivityIndicator()),
                            ),
                          )
                        ] else
                          Expanded(
                              child: Scrollbar(
                            trackVisibility: true,
                            // thumbVisibility: true,
                            child: ListView.builder(
                              itemCount:
                                  asyncSnapshot.data?.details.length ?? 0,
                              primary: false,
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (_, index) {
                                var order = asyncSnapshot.data?.details[index];
                                List<AddOns> addOns = [];

                                List<AddOns> addonsData =
                                    order?.productDetails?.addOns ?? [];

                                for (int i = 0;
                                    i < order!.addOnIds!.length;
                                    i++) {
                                  var matchingAddons = addonsData
                                      .where((e) => e.id == order.addOnIds![i]);

                                  if (matchingAddons.isNotEmpty) {
                                    var thisAddOn = matchingAddons.first;
                                    addOns.add(thisAddOn);
                                    debugPrint(
                                      'Name: ${thisAddOn.name}, ID: ${order.addOnIds![i]}, QTY: ${order.addOnQtys![i]}',
                                    );
                                  } else {
                                    debugPrint(
                                        'No addon found for ID: ${order.addOnIds![i]}');
                                  }
                                }

                                return OrderList(
                                  order: order,
                                  addOns: addOns,
                                );
                              },
                            ),
                          )),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              OrderSummaryItem(
                                title: 'Delivery Status',
                                subtitle:
                                    widget.item.orderType.toString().capitalize,
                              ),
                              OrderSummaryItem(
                                title: 'Add Cutlery',
                                subtitle: widget.item.addCutlery != null &&
                                        widget.item.addCutlery == true
                                    ? "Yes"
                                    : "No",
                              ),
                              // OrderSummaryItem(
                              //   title: 'Order receieved by kitchen',
                              //   subtitle:  widget.item.,
                              // ),
                              OrderSummaryItem(
                                title: 'Time since ordered',
                                subtitle: formatTimeAgo(widget.item.createdAt!),
                              ),
                            ],
                          ),
                        ),
                        if (widget.item.orderStatus != "ready_for_delivering")
                          const Divider(
                            color: Colors.grey,
                            height: 3,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              if (widget.item.orderStatus !=
                                      "ready_for_delivering" &&
                                  widget.item.orderStatus != "pending")
                                Expanded(
                                  child: FilledButton(
                                      onPressed: Get.find<OrderController>()
                                              .isLoading
                                          ? null
                                          : () {
                                              int orderId = widget.item.id ?? 0;

                                              if (widget.item.orderStatus ==
                                                  "cooking") {
                                                Get.find<OrderController>()
                                                    .orderStatusUpdate(orderId,
                                                        'ready_for_delivering');
                                              } else {
                                                Get.find<OrderController>()
                                                    .orderStatusUpdate(
                                                        orderId, 'cooking');
                                              }

                                              // widget.carouselController.animateToPage(
                                              //   widget.itemIndex - 1,
                                              //   duration: Duration(milliseconds: 500),
                                              //   curve: Curves.easeInOut,
                                              // );
                                            },
                                      style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 13)),
                                      child: Get.find<OrderController>()
                                              .isLoading
                                          ? const CupertinoActivityIndicator()
                                          : Text(
                                              () {
                                                switch (
                                                    widget.item.orderStatus) {
                                                  case "cooking":
                                                    return "Finish";
                                                  default:
                                                    return "Start";
                                                }
                                              }(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                ),
                            ],
                          ),
                        )
                      ]),
                )
              ],
            ),
          );
        });
  }
}
