import 'package:happy_belly_kitchen/data/model/response/order_details_model.dart';
import 'package:happy_belly_kitchen/data/model/response/order_model.dart';

class DemoDataController {
  var demoOrderList = List.generate(
      4,
      (index) => Orders.fromJson({
            "id": 100178,
            "user_id": 11,
            "is_guest": 0,
            "order_amount": 2733.75,
            "coupon_discount_amount": 0,
            "coupon_discount_title": null,
            "payment_status": "unpaid",
            "order_status": "pending",
            "total_tax_amount": 183.75,
            "payment_method": "paystack",
            "transaction_reference": null,
            "delivery_address_id": 0,
            "created_at": "2024-04-16T04:28:11.000000Z",
            "updated_at": "2024-04-16T04:28:35.000000Z",
            "checked": 1,
            "delivery_man_id": null,
            "delivery_charge": 0,
            "order_note":
                "Suite A8, Platinum Mall, Ikota First Gate, Lekki, Lagos.",
            "coupon_code": null,
            "order_type": "take_away",
            "branch_id": 1,
            "callback": null,
            "delivery_date": "2024-04-16",
            "delivery_time": "05:58:11",
            "extra_discount": "0.00",
            "delivery_address": null,
            "preparation_time": 0,
            "table_id": null,
            "number_of_people": null,
            "table_order_id": null,
            "payment_id": null,
            "remove_cutlery": 0,
            "screen_id": 2,
            "table": null
          }));

  var demoOrderDetails = OrderDetailsModel.fromJson({
    "order": {
      "id": 100178,
      "user_id": 11,
      "is_guest": 0,
      "order_amount": 2733.75,
      "coupon_discount_amount": 0,
      "coupon_discount_title": null,
      "payment_status": "unpaid",
      "order_status": "pending",
      "total_tax_amount": 183.75,
      "payment_method": "paystack",
      "transaction_reference": null,
      "delivery_address_id": 0,
      "created_at": "2024-04-16T04:28:11.000000Z",
      "updated_at": "2024-04-16T04:28:35.000000Z",
      "checked": 1,
      "delivery_man_id": null,
      "delivery_charge": 0,
      "order_note": "Suite A8, Platinum Mall, Ikota First Gate, Lekki, Lagos.",
      "coupon_code": null,
      "order_type": "take_away",
      "branch_id": 1,
      "callback": null,
      "delivery_date": "2024-04-16",
      "delivery_time": "05:58:11",
      "extra_discount": "0.00",
      "delivery_address": null,
      "preparation_time": 0,
      "table_id": null,
      "number_of_people": null,
      "table_order_id": null,
      "payment_id": null,
      "remove_cutlery": 0,
      "screen_id": 2,
      "table": null
    },
    "details": List.generate(
        2,
        (index) => {
              "id": 265,
              "product_id": 8,
              "order_id": 100178,
              "price": 2450,
              "product_details": {
                "id": 8,
                "name": "Party Jollof rice",
                "description":
                    "The OG! \r\nSmokey party jollof rice cooked in spicy tomato sauce, stock, and herbs.",
                "image": "2024-02-10-65c7a7480653f.png",
                "price": 2450,
                "variations": [],
                "add_ons": [
                  {
                    "id": 17,
                    "name": "Assorted Meat",
                    "price": 3950,
                    "tax": 7.5,
                    "category_id": 1,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/Assorted1111zonjpg_1705721712.jpg",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 22,
                    "name": "Boiled Eggs",
                    "price": 500,
                    "tax": 7.5,
                    "category_id": 1,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/IMG8242jpeg_1712667622.jpeg",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 18,
                    "name": "Coleslaw",
                    "price": 550,
                    "tax": 7.5,
                    "category_id": 3,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/Coleslaw11zonjpg_1705721781.jpg",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 15,
                    "name": "Fried goat meat",
                    "price": 1950,
                    "tax": 7.5,
                    "category_id": 1,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/PepperedGotmeat311zonjpg_1705721606.jpg",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 28,
                    "name": "Tama Brew",
                    "price": 1350,
                    "tax": 7.5,
                    "category_id": 2,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/3911zonpng_1705754937.png",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 27,
                    "name": "The OJ",
                    "price": 2350,
                    "tax": 7.5,
                    "category_id": 2,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/2811zonpng_1705754908.png",
                    "description": "",
                    "translations": []
                  },
                  {
                    "id": 30,
                    "name": "Watermelon Sugar High",
                    "price": 1950,
                    "tax": 7.5,
                    "category_id": 2,
                    "image":
                        "https://control.eathappybelly.com/storage/app/public/addon/5311zonpng_1705755019.png",
                    "description": "",
                    "translations": []
                  }
                ],
                "tax": 7.5,
                "available_time_starts": "04:00:00",
                "available_time_ends": "21:00:00",
                "status": 1,
                "created_at": "2024-01-17T18:15:43.000000Z",
                "updated_at": "2024-04-16T04:25:48.000000Z",
                "attributes": [],
                "category_ids": [
                  {"id": "4", "position": 1}
                ],
                "choice_options": [],
                "discount": 0,
                "discount_type": "amount",
                "tax_type": "percent",
                "set_menu": 0,
                "branch_id": 1,
                "colors": null,
                "popularity_count": 106,
                "product_type": "non_veg",
                "grouping_id": 1,
                "translations": []
              },
              "variation": [],
              "discount_on_product": 0,
              "discount_type": "discount_on_product",
              "quantity": 1,
              "tax_amount": 183.75,
              "created_at": "2024-04-16T04:28:11.000000Z",
              "updated_at": "2024-04-16T04:28:11.000000Z",
              "add_on_ids": [18, 11, 22, 18, 11, 22],
              "variant": [],
              "add_on_qtys": [2, 3, 4, 10, 20, 20],
              "add_on_taxes": [],
              "add_on_prices": [100, 100, 100, 10000, 20000, 3000],
              "add_on_tax_amount": 0,
              "review_count": 0,
              "is_product_available": 1
            }).toList()
  });
}
