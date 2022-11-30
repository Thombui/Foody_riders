import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_riders_app/Widgets/progress_bar.dart';
import 'package:foodpanda_riders_app/Widgets/shipment_address_design.dart';
import 'package:foodpanda_riders_app/Widgets/status_banner.dart';
import 'package:foodpanda_riders_app/global/global.dart';
import 'package:foodpanda_riders_app/models/address.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget
{

  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
{

  String orderStatus = "";
  String orderByUser = "";
  String sellerId = "";


  getOrderInfo()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID).get().then((DocumentSnapshot)
    {
      orderStatus = DocumentSnapshot.data()!["status"].toString();
      orderByUser = DocumentSnapshot.data()!["orderBy"].toString();
      sellerId = DocumentSnapshot.data()!["sellerUID"].toString();



    });
  }

  @override
  void initState() {

    super.initState();

    getOrderInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (c, snapshot)
          {
            Map? dataMap;
            if(snapshot.hasData)
            {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
                      child: Column(
                        children: [
                          StatusBanner(
                            status: dataMap!["isSuccess"],
                            orderStatus: orderStatus,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Tổng tiền đơn hàng: ${dataMap["totalAmount"]} Đ",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Mã vận đơn: ${widget.orderID!}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Thời gian đặt hàng: ${DateFormat("dd MMMM, yyyy -  hh:mm aa")
                                  .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"])))}",
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),

                          orderStatus == "Giao thành công"
                          ?
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Thời gian giao hàng: ${DateFormat("dd MMMM, yyyy -  hh:mm aa")
                                  .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["endedTime"])))}",
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          )
                          :
                              Text(""),

                          const Divider(thickness: 4,),
                          orderStatus == "Giao thành công"
                              ? Image.asset("images/success.jpg")
                              : Image.asset("images/food-delivery-service-vector.jpg"),
                          const Divider(thickness: 4,),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(orderByUser)
                                .collection("userAddress")
                                .doc(dataMap["addressID"])
                                .get(),
                            builder: (c, snapshot)
                            {
                              return snapshot.hasData
                                  ? ShipmentAddressDesign(
                                model: Address.fromJson(
                                  snapshot.data!.data()! as Map<String, dynamic>
                                ),
                                orderStatus: orderStatus,
                                orderId: widget.orderID,
                                sellerId: sellerId,
                                orderByUser: orderByUser,
                              ) : Center(child: circularProgress(),);
                            },
                          )
                        ],
                      ),
            )
                : Center(child: circularProgress(),);

          },
        ),
      ),
    );
  }
}
