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

    final response = await apiClient.getData(AppConstants.kitchenProducts);

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

  void showEditPriceDialog(Map<String, dynamic> item) {
    TextEditingController priceController =
        TextEditingController(text: item['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Price for ${item['name']}"),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Price"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateProductPrice(item['id'], priceController.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProductPrice(int productId, String newPrice) async {

  int index = menuItems.indexWhere((item) => item['id'] == productId);
  if (index == -1) return;

  // Update the local price immediately
  setState(() {
    menuItems[index]['price'] = newPrice;
  });

  try {
    // Send updated price as a string
    final response = await apiClient.patchData(
       AppConstants.updateProductPrice,
      {
        'product_id': productId.toString(),
        'price': newPrice,
      },
    );

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Product price updated');
    } else {
      Get.snackbar('Error', 'Failed to update product price');
    }
  } catch (e) {
    debugPrint("Exception: $e");
    Get.snackbar('Error', 'An error occurred while updating product price');
  }
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
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(label: Text("SL", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Product", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Enable", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: filteredItems.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item["id"].toString())),
                              DataCell(Text(item["name"])),
                              DataCell(Text("₦${item["price"]}")),
                              DataCell(
                                Switch(
                                  value: item["available"] ?? false,
                                  onChanged: (value) {
                                    toggleProductStatus(item["id"], value);
                                  },
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () => showEditPriceDialog(item),
                                  child: const SizedBox(
                                    height: 10,
                                    width: 10,
                                    child: Icon(Icons.edit, color: Colors.blue, size: 15,),
                                  ),
                                )
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
