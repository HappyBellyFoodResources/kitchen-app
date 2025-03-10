import 'package:happy_belly_kitchen/data/api/api_client.dart';
import 'package:happy_belly_kitchen/util/app_constants.dart';
import 'package:get/get.dart';

class OrderRepo {
  ApiClient apiClient;
  OrderRepo({required this.apiClient});

  Future<Response> getOrderList(int offset) async {
    return await apiClient
        .getData('${AppConstants.orderList}?limit=20&offset=$offset');
  }

  Future<Response> searchOrder(String orderId) async {
    return await apiClient.getData('${AppConstants.searchOrder}$orderId');
  }

  Future<Response> filterOrder(String orderType, int offset) async {
    return await apiClient
        .getData('${AppConstants.filterOrder}$orderType&limit=20&page=$offset');
  }

  Future<Response> getOrderDetails(int orderId) async {
    return await apiClient
        .getData('${AppConstants.orderDetails}?order_id=$orderId');
  }

  Future<Response> markNoteAsSeen(int orderId) async {
    return await apiClient.patchData('/api/v1/kitchen/order/$orderId/mark-kitchen-note-seen', {});
  }

  Future<Response> updateOrderStatus(int orderId, String orderStatus) async {
    return await apiClient.postData(AppConstants.orderStatusUpdate,
        {"order_id": orderId, "order_status": orderStatus, "_method": "put"});
  }

  Future<Response> setIndividualSurge(int orderId, int extraTime) async {
    return await apiClient.postData(
      '/api/v1/set-individual-surge',
      {
        "order_id": orderId,
        "extra_time": extraTime
      }
    );
  }

  Future<Response> setGeneralSurge(int preparationTime) async {
    return await apiClient.postData('/api/v1/set_general_surge', {"preparation_time": preparationTime});
  }

  Future<Response> resetSurge() async {
    return await apiClient.postData('/api/v1/reset-surge', {});
  }
}
