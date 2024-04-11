// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/data/model/response/order_details_model.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';
import 'package:pull_to_refresh_plus/pull_to_refresh_plus.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew>
    with TickerProviderStateMixin {
  TabController? _tabController;
  RefreshController refreshController = RefreshController();
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
    Get.find<OrderController>().tabController = _tabController;
    Get.find<OrderController>().fetchOrders(0);

    _tabController?.addListener(() {
      Get.find<OrderController>().fetchOrders(_tabController!.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();

    searchController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: 90,
          actions: [
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(
                  child: Text('Screen 1'),
                ),
                const PopupMenuItem(
                  child: Text('Screen 2'),
                ),
                const PopupMenuItem(
                  child: Text('All Screen'),
                ),
              ],
            )
          ],
          title: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  if (!isSearching)
                    setState(() {
                      isSearching = true;
                    });
                  _tabController?.index = 0;
                  Get.find<OrderController>().searchOrder(value);
                } else {
                  FocusScope.of(context).unfocus();
                  Get.find<OrderController>()
                      .fetchOrders(_tabController!.index);
                  if (isSearching)
                    setState(() {
                      isSearching = true;
                    });
                }
              },
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                hintText: "Search by Order ID",
                suffixIcon: isSearching
                    ? IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          searchController.clear();
                          Get.find<OrderController>()
                              .fetchOrders(_tabController!.index);

                          if (isSearching)
                            setState(() {
                              isSearching = false;
                            });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.black,
                        ))
                    : Icon(Icons.search),
                hintStyle: const TextStyle(
                  color: Color(0xFFBBB7B6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 10),
              child: SizedBox(
                height: 35,
                child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    indicatorPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.only(right: 15),
                    dividerHeight: 0,
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    unselectedLabelStyle: const TextStyle(
                      color: Color(0xFF4F4F4F),
                    ),
                    tabs: const [
                      Tab(
                        text: "All",
                      ),
                      Tab(
                        text: "Confirmed",
                      ),
                      Tab(
                        text: "Cooked",
                      ),
                      Tab(
                        text: "Done",
                      ),
                    ]),
              )),
        ),
        body: SmartRefresher(
          onRefresh: () async {
            await Get.find<OrderController>()
                .fetchOrders(_tabController?.index);
            refreshController.refreshCompleted();
          },
          controller: refreshController,
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(15),
            child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  OrderListView(
                    activeTab: _tabController?.index ?? 0,
                  ),
                  OrderListView(
                    activeTab: _tabController?.index ?? 0,
                  ),
                  OrderListView(
                    activeTab: _tabController?.index ?? 0,
                  ),
                  OrderListView(
                    activeTab: _tabController?.index ?? 0,
                  ),
                ]),
          )),
        ));
  }
}

class OrderListView extends StatefulWidget {
  const OrderListView({
    super.key,
    required this.activeTab,
  });

  final int activeTab;

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      List<Orders>? orderList = orderController.orderList;
      return orderController.isLoading
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Center(child: CupertinoActivityIndicator()),
                  Text("Fetching Orders...")
                ])
          : Container(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                options: CarouselOptions(
                  pageSnapping: true,
                  scrollDirection: Axis.horizontal,
                  aspectRatio: 3 / 5,
                  enlargeFactor: 0.1,
                  enlargeCenterPage: true,
                  viewportFraction: .9,
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

  @override
  void initState() {
    super.initState();
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
                Container(
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
                            'Order ID: ${widget.item?.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                      Text(
                        widget.item.deliveryAddress?.contactPersonName ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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
                              if (widget.item.orderNote != "")
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
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFCECECEB),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(widget.item.orderNote ?? ''),
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
                            ConnectionState.waiting) ...[
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
                            thumbVisibility: true,
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
                                for (var addOn in addonsData) {
                                  if (order!.addOnIds!.contains(addOn.id)) {
                                    addOns.add(addOn);
                                  }
                                }
                                return OrderList(
                                  order: order!,
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
                                  "ready_for_delivering")
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
                                          ? CupertinoActivityIndicator()
                                          : Text(
                                              () {
                                                switch (
                                                    widget.item.orderStatus) {
                                                  case "cooking":
                                                    return "Done Cooking";
                                                  default:
                                                    return "Start Cooking";
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

class OrderSummaryItem extends StatelessWidget {
  const OrderSummaryItem({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6F6F6F),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          subtitle ?? '',
          style: const TextStyle(
            color: Color(0xFF190600),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class OrderList extends StatelessWidget {
  const OrderList({
    Key? key,
    required this.order,
    required this.addOns,
  }) : super(key: key);

  final Details order;
  final List<AddOns> addOns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Column(
          children: [
            ItemList(
              title: order.productDetails?.name ?? "",
              subtitle: "x${order.quantity.toString()}",
            ),
          ],
        ),
        if (addOns.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'ADD-ONS',
            style: TextStyle(
              color: Color(0xFF868686),
              fontSize: 12,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: addOns.length,
              itemBuilder: (context, addOnIndex) {
                var addOn = addOns[addOnIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ItemList(
                          isAddOn: true,
                          title:
                              "${addOn.name} x${order.addOnQtys![addOnIndex]}",
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ],
        Divider(
          color: Colors.grey.shade300,
          height: 30,
        ),
      ],
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.title,
    this.subtitle,
    this.isAddOn = false,
  });

  final String title;
  final String? subtitle;
  final bool isAddOn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isAddOn ? Icons.circle_outlined : Icons.circle_sharp,
              size: isAddOn ? 14 : 18,
              color: const Color(0xFF868686),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                  fontSize: isAddOn ? 12 : 14,
                  fontWeight: isAddOn ? FontWeight.w500 : FontWeight.bold),
            ),
          ],
        ),
        Text(
          subtitle ?? '',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
