import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_riders_app/Widgets/order_card.dart';
import 'package:foodpanda_riders_app/Widgets/progress_bar.dart';
import 'package:foodpanda_riders_app/Widgets/simple_app_bar.dart';


import 'package:foodpanda_riders_app/assistantMethods/assistant_methods.dart';
import 'package:foodpanda_riders_app/global/global.dart';


class ParcelInProgressScreen extends StatefulWidget
{


  @override
  State<ParcelInProgressScreen> createState() => _ParcelInProgressScreenState();
}

class _ParcelInProgressScreenState extends State<ParcelInProgressScreen>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(title: "Nhà hàng Go",),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("riderUID", isEqualTo: sharedPreferences!.getString("uid"))
              .where("status", isEqualTo: "Chờ lấy hàng")
              .snapshots(),
          builder: (c, snapshot)
          {
            return snapshot.hasData? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (c, index)
              {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("items")
                      .where("itemID", whereIn: separateOrdersItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"] ))
                      .orderBy("publishedDate", descending: true)
                      .get(),
                  builder: (c, snap)
                  {
                    return snap.hasData
                        ? OrderCard(
                      itemCount: snap.data!.docs.length,
                      data: snap.data!.docs,
                      orderID: snapshot.data!.docs[index].id,
                      seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"] ),
                    )
                        : Center(child: circularProgress(),);
                  },
                );
              },
            )
                : Center(child: circularProgress(),);
          },

        ),
      ),
    );
  }
}
