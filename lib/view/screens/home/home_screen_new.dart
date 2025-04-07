// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/view/base/animated_dialog.dart';
import 'package:happy_belly_kitchen/view/base/logout_dialog.dart';
import 'package:happy_belly_kitchen/view/screens/auth/login_screen.dart';
import 'package:happy_belly_kitchen/view/screens/products/products_screen.dart';
import 'package:pull_to_refresh_plus/pull_to_refresh_plus.dart';
import 'widget/new/order_list_view.dart';

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
  int active_screen_index = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final orderController = Get.find<OrderController>();
    orderController.tabController = _tabController;
    orderController.fetchOrders(0).then((_) {
      orderController.isLoading = false;
      orderController.update();
    });

    _tabController?.addListener(() {
      orderController.fetchOrders(_tabController!.index);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    searchController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  void _setGeneralSurge() {
    Get.find<OrderController>().setGeneralSurge(10);
  }

  void _resetSurge() {
    Get.find<OrderController>().resetSurge();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return _onWillPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: 90,
          actions: [
            PopupMenuButton(
              onSelected: (value) {
                if (value == "logout") {
                  _showLogoutDialog(context);
                } else if (value == "general_surge") {
                  _showGeneralSurgeDialog();
                } else if (value == "reset_surge") {
                  _resetSurge();
                } else if (value == "products_screen") {
                  Get.to(() => const ProductsScreen()); // Navigate to Products Screen
                } else if (value is int) {
                  setState(() {
                    active_screen_index = value;
                  });
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 1, child: Text('Screen 1')),
                const PopupMenuItem(value: 2, child: Text('Screen 2')),
                const PopupMenuItem(value: 0, child: Text('All Screen')),
                const PopupMenuItem(value: "general_surge", child: Text('General Surge')),
                const PopupMenuItem(value: "reset_surge", child: Text('Reset Surge')),
                const PopupMenuItem(value: "products_screen", child: Text('Products')),
                const PopupMenuItem(
                  value: "logout",
                  child: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
          title: _buildSearchField(),
          bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 10),
                child: SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                            controller: _tabController,
                            indicatorColor: Theme.of(context).primaryColor,
                            labelColor: Theme.of(context).primaryColor,
                            indicatorPadding: EdgeInsets.zero,
                            padding: const EdgeInsets.only(right: 15),
                            dividerHeight: 0,
                            overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent),
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
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                            active_screen_index == 0
                                ? "All Screens"
                                : "Screen $active_screen_index",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ),
                    ],
                  ),
                )),
        ),
        body: SmartRefresher(
          onRefresh: () async {
            await Get.find<OrderController>().fetchOrders(_tabController!.index);
            refreshController.refreshCompleted();
          },
          controller: refreshController,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: _buildTabBarView(screen),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
              height: 45,
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
                    if (!isSearching) {
                      setState(() {
                        isSearching = true;
                      });
                    }
                    _tabController?.index = 0;
                    Get.find<OrderController>().searchOrder(value);
                  } else {
                    FocusScope.of(context).unfocus();
                    Get.find<OrderController>()
                        .fetchOrders(_tabController!.index);
                    if (isSearching) {
                      setState(() {
                        isSearching = true;
                      });
                    }
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

                            if (isSearching) {
                              setState(() {
                                isSearching = false;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.black,
                          ))
                      : const Icon(Icons.search),
                  hintStyle: const TextStyle(
                    color: Color(0xFFBBB7B6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).primaryColor,
      isScrollable: true,
      tabs: const [
        Tab(text: "All"),
        Tab(text: "Confirmed"),
        Tab(text: "Cooked"),
      ],
    );
  }

  Widget _buildTabBarView(Size screen) {
    return Container(
      constraints: screen.height > 800 && screen.width > 800
          ? const BoxConstraints(maxHeight: 750)
          : null,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(3, (index) => OrderListView(
          activeTab: _tabController?.index ?? 0,
          activeScreen: active_screen_index,
        )),
      ),
    );
  }
  void _showGeneralSurgeDialog() {
  TextEditingController timeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Set General Surge Time"),
        content: TextField(
          controller: timeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter extra time in minutes",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredTime = int.tryParse(timeController.text);
              if (enteredTime == null || enteredTime < 0) {
                Get.snackbar("Invalid Input", "Please enter a valid number",
                    backgroundColor: Colors.red.withOpacity(0.8),
                    colorText: Colors.white);
                return;
              }
              Navigator.of(context).pop();
              Get.find<OrderController>().setGeneralSurge(enteredTime);
            },
            child: const Text("Apply Surge"),
          ),
        ],
      );
    },
  );
}

}

void _showLogoutDialog(BuildContext context) {
  showAnimatedDialog(
    context: context,
    barrierDismissible: true,
    animationType: DialogTransitionType.slideFromBottomFade,
    builder: (context) => CustomLogOutDialog(
      icon: Icons.exit_to_app_rounded,
      title: "Logout",
      description: "Are you sure you want to logout?",
      onTapFalse: () => Navigator.of(context).pop(false),
      onTapTrue: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      ),
      onTapTrueText: 'yes'.tr,
      onTapFalseText: 'no'.tr,
    ),
  );
}

Future<bool> _onWillPop(BuildContext context) async {
  showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      animationType: DialogTransitionType.slideFromBottomFade,
      builder: (BuildContext context) {
        return CustomLogOutDialog(
          icon: Icons.exit_to_app_rounded,
          title: 'exit_app'.tr,
          description: 'do_you_want_to_exit_from_this_account'.tr,
          onTapFalse: () => Navigator.of(context).pop(false),
          onTapTrue: () {
            SystemNavigator.pop();
          },
          onTapTrueText: 'yes'.tr,
          onTapFalseText: 'no'.tr,
        );
      });
  return true;
}