import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_riders_app/assistantMethods/get_current_location.dart';
import 'package:foodpanda_riders_app/global/global.dart';
import 'package:foodpanda_riders_app/mainScreens/parcel_picking_screen.dart';
import 'package:foodpanda_riders_app/models/address.dart';
import 'package:foodpanda_riders_app/splashScreen/splash_screen.dart';


class ShipmentAddressDesign extends StatelessWidget
{
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;


  ShipmentAddressDesign({
    this.model,
    this.orderStatus,
    this.orderId,
    this.sellerId,
    this.orderByUser,
  });


  //Xác nhận nhận giao đơn hàng này
  confirmedParcelShipment(BuildContext context, String getOrderID, String sellerID, String purchaserID)
  {
    FirebaseFirestore.instance.collection("users")
        .doc(purchaserID)
        .collection("orders")
        .doc(getOrderID).update({
      "riderUID": sharedPreferences!.getString("uid"),
      "reiderName": sharedPreferences!.getString("name"),
      "status": "Chờ lấy hàng",
      "lat": position!.latitude,
      "lng": position!.longitude,
      "address": completeAddress,
    }).then((value)
    {
       FirebaseFirestore.instance
          .collection("orders")
          .doc(getOrderID)
          .update({
        "riderUID": sharedPreferences!.getString("uid"),
        "reiderName": sharedPreferences!.getString("name"),
        "status": "Chờ lấy hàng",
        "lat": position!.latitude,
        "lng": position!.longitude,
        "address": completeAddress,
      });

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ParcelPickingScreen(
            purchaserId: purchaserID,
            purchaserAddress : model!.fullAddress,
            purchaserLat: model!.lat,
            purchaserLng: model!.lng,
            sellerId: sellerID,
            getOrderID: getOrderID,
          )));

    });
    // send rider to shipmentScreen
  }


  @override
  Widget build(BuildContext context)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Thông tin khách hàng: ',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text(
                    "Tên khách hàng: ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.name!),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Số điện thoại: ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.phoneNumber!),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Địa chỉ: ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.fullAddress!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        orderStatus == "Giao thành công"
            ? Container()
            :  Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
            child: InkWell(
              onTap: ()
              {
                UserLocation uLocation = UserLocation();
                uLocation.getCurrentLocation();
                confirmedParcelShipment(context, orderId!, sellerId!, orderByUser!);
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
                width: MediaQuery.of(context).size.width -40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Xác nhận - Để giao Bưu kiện này",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        )  ,

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MySplashScreen()));
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
                width: MediaQuery.of(context).size.width -40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Quay lại",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20,),

      ],
    );
  }
}

