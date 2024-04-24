// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happy_belly_kitchen/data/model/response/order_details_model.dart';
import 'package:happy_belly_kitchen/view/screens/home/widget/new/item_list.dart';

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
              // reverse: true,
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
