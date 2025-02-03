// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/view/base/animated_dialog.dart';
import 'package:happy_belly_kitchen/view/base/logout_dialog.dart';
import 'package:happy_belly_kitchen/view/screens/auth/login_screen.dart';
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
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    Get.find<OrderController>().tabController = _tabController;
    Get.find<OrderController>().fetchOrders(0).then((value) {
      Get.find<OrderController>().isLoading = false;
      Get.find<OrderController>().update();
    });

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
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        _onWillPop(context);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarHeight: 90,
            actions: [
              PopupMenuButton(
                onSelected: (value) => {
                  if (value == "logout")
                    {
                      showAnimatedDialog(
                          context: context,
                          barrierDismissible: true,
                          animationType:
                              DialogTransitionType.slideFromBottomFade,
                          builder: (BuildContext context) {
                            return CustomLogOutDialog(
                              icon: Icons.exit_to_app_rounded,
                              title: "Logout",
                              description: "Are you sure you want to logout?",
                              onTapFalse: () =>
                                  Navigator.of(context).pop(false),
                              onTapTrue: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                    (route) => false);
                              },
                              onTapTrueText: 'yes'.tr,
                              onTapFalseText: 'no'.tr,
                            );
                          })
                    }
                  else
                    {
                      setState(() {
                        active_screen_index = value as int;
                      })
                    }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Screen 1'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Screen 2'),
                  ),
                  const PopupMenuItem(
                    value: 0,
                    child: Text('All Screen'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
            title: Container(
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
            ),
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
              await Get.find<OrderController>()
                  .fetchOrders(_tabController?.index);
              refreshController.refreshCompleted();
            },
            controller: refreshController,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                constraints: screen.height > 800 && screen.width > 800
                    ? const BoxConstraints(maxHeight: 750)
                    : null,
                child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      OrderListView(
                        activeTab: _tabController?.index ?? 0,
                        activeScreen: active_screen_index,
                      ),
                      OrderListView(
                        activeTab: _tabController?.index ?? 0,
                        activeScreen: active_screen_index,
                      ),
                      OrderListView(
                        activeTab: _tabController?.index ?? 0,
                        activeScreen: active_screen_index,
                      ),
                      // OrderListView(
                      //   activeTab: _tabController?.index ?? 0,
                      //   activeScreen: active_screen_index,
                      // ),
                    ]),
              ),
            ),
          )),
    );
  }
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
