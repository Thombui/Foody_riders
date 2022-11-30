import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodpanda_riders_app/Widgets/error_dialog.dart';
import 'package:foodpanda_riders_app/assistantMethods/get_current_location.dart';
import 'package:foodpanda_riders_app/global/global.dart';
import 'package:foodpanda_riders_app/mainScreens/home_screen.dart';
import 'package:foodpanda_riders_app/mainScreens/parcel_picking_screen.dart';
import 'package:foodpanda_riders_app/maps/map_utils.dart';
import 'package:foodpanda_riders_app/splashScreen/splash_screen.dart';


class ParcelDeliveringScreen extends StatefulWidget
{

  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? sellerId;
  String? getOrderId;

  ParcelDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
});



  @override
  State<ParcelDeliveringScreen> createState() => _ParcelDeliveringScreenState();
}



class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen>
{

  String orderTotalAmount = "";

  //Xác nhận đã giao hàng thành công
  confirmParcelHasBeenDelivered(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    String endedTime = DateTime.now().millisecondsSinceEpoch.toString();
    String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) + (double.parse(perParcelDeliveryAmount))).toString();
    //orderTotalSeller();

    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "Giao thành công",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings": perParcelDeliveryAmount,// pay per parcel delivery amount
      "endedTime": endedTime,
    }).then((value) {
      FirebaseFirestore.instance
          .collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .update(
          {
            "earnings": riderNewTotalEarningAmount, // total earnings amount of rider
          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId)
          .update(
          {
            "earnings" : (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString() ,

          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId)
          .update(
          {
            "status": "Giao thành công",
            "riderUID": sharedPreferences!.getString("uid"),
            "endedTime": endedTime,
          });
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));

  }

  orderHasBeenCancel(getOrderId, purchaserId)
  {
        FirebaseFirestore.instance.collection("users")
            .doc(purchaserId)
            .collection("orders")
            .doc(getOrderId)
            .update({
          "status": "Người mua hủy đơn",
        })
            .then((snapshot)
        {
          FirebaseFirestore.instance
              .collection("orders")
              .doc(getOrderId)
              .update({
            "status": "Người mua hủy đơn",
          });

          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          Fluttertoast.showToast(msg: "Đơn hàng bị được hủy bởi người mua");
        }
        );

    // send rider to shipmentScreen
  }


  getOrderTotalAmount()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap)
    {
      orderTotalAmount = snap.data()!["totalAmount"].toString();
      widget.sellerId = snap.data()!["sellerUID"].toString();

    }).then((value)
    {
      getSellerData();
    });
  }


  getSellerData()
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .get().then((snap)
    {
      previousEarnings = snap.data()!["earnings"].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();


    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm2.png",
            width: 380,

          ),

          const SizedBox(height: 5,),

          GestureDetector(
            onTap: ()
            {
              //show location from rider current location towards seller location
              MapUtils.launchMapFrmSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);

            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/home.png',
                  width: 50,
                ),
                const SizedBox(width: 7,),
                Column(
                  children:const [
                    SizedBox(height: 12,),
                    Text(
                      "Xem địa chỉ khách hàng",
                      style: TextStyle(
                        fontFamily: "Regular",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],

            ),
          ),

          const SizedBox(height: 40,),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  // rider location update
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();
                  // confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin:  FractionalOffset((0.0), 0.0),
                        end:  FractionalOffset(1.0, 0.0),
                        stops: [0.0,1.0],
                        tileMode: TileMode.clamp,
                      )
                  ),
                  width: MediaQuery.of(context).size.width -90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Giao hàng thành công - Xác nhận",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  orderHasBeenCancel(widget.getOrderId, widget.purchaserId);
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin:  FractionalOffset((0.0), 0.0),
                        end:  FractionalOffset(1.0, 0.0),
                        stops: [0.0,1.0],
                        tileMode: TileMode.clamp,
                      )
                  ),
                  width: MediaQuery.of(context).size.width -90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Giao hàng không thành công",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}
