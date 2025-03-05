import 'package:flutter/material.dart';
import 'package:happy_belly_kitchen/data/api/api_client.dart';
import 'package:happy_belly_kitchen/util/app_constants.dart';
import 'package:get/get.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController searchController = TextEditingController();
  final ApiClient apiClient = Get.find<ApiClient>();

  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
  try {
    setState(() {
      isLoading = true;
    });

    final response = await apiClient.getData(
      AppConstants.kitchenProducts,
      headers: {"Authorization": "Bearer ${apiClient.token}"},
    );

    debugPrint("API Response: ${response.body}");

    if (response.statusCode == 200 && response.body != null) {
      List<dynamic> products = response.body is List ? response.body : response.body['data'] ?? [];

      setState(() {
        menuItems = products.map((product) {
          return {
            'id': product['id'],
            'name': product['name'],
            'price': product['price']?.toDouble() ?? 0.0,
            'available': (product['available'] ?? product['status']) == 1,
          };
        }).toList();
        filteredItems = List.from(menuItems);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load products');
    }
  } catch (e) {
    debugPrint("Fetch error: $e");
    setState(() {
      isLoading = false;
    });
    Get.snackbar('Error', 'An error occurred while fetching products');
  }
}



  void filterSearch(String query) {
    setState(() {
      filteredItems = menuItems.where((item) {
        return item['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> toggleProductStatus(int productId, bool newStatus) async {
  final url = AppConstants.productToggle.replaceFirst("{productId}", productId.toString());

  int index = menuItems.indexWhere((item) => item['id'] == productId);
  if (index == -1) return;

  bool oldStatus = menuItems[index]['available'];

  setState(() {
    menuItems[index]['available'] = newStatus;
  });

  try {
    final response = await apiClient.patchData(
      url,
      {'status': newStatus ? 1 : 0},
      headers: {"Authorization": "Bearer ${apiClient.token}"},
    );

    if (response.statusCode == 200) {
      final responseData = response.body;
      setState(() {
        menuItems[index]['available'] = responseData['product']['status'] == 1;
      });
    } else {
      setState(() {
        menuItems[index]['available'] = oldStatus;
      });
      Get.snackbar('Error', 'Failed to update product status');
    }
  } catch (e) {
    debugPrint("Toggle error: $e");
    setState(() {
      menuItems[index]['available'] = oldStatus;
    });
    Get.snackbar('Error', 'An error occurred while updating product status');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Products", style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: InputDecoration(
                          hintText: "Search menu..",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text("SL", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Product", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Enable", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: filteredItems.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item["id"].toString())),
                              DataCell(Text(item["name"])),
                              DataCell(Text("₦${item["price"].toStringAsFixed(2)}")),
                              DataCell(
                                Switch(
                                  value: item["available"] ?? false,
                                  onChanged: (value) {
                                    toggleProductStatus(item["id"], value);
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
