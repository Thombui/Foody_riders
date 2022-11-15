import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodpanda_riders_app/assistantMethods/get_current_location.dart';
import 'package:foodpanda_riders_app/authentication/auth_screen.dart';
import 'package:foodpanda_riders_app/global/global.dart';
import 'package:foodpanda_riders_app/mainScreens/earnings_screen.dart';
import 'package:foodpanda_riders_app/mainScreens/history_screen.dart';
import 'package:foodpanda_riders_app/mainScreens/new_orders_screen.dart';
import 'package:foodpanda_riders_app/mainScreens/not_yet_delivered_screen.dart';
import 'package:foodpanda_riders_app/mainScreens/parcel_in_progress_screen.dart';
import 'package:foodpanda_riders_app/splashScreen/splash_screen.dart';

class HomeScreen extends StatefulWidget
{


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  Card makeDashboardItem(String title, IconData iconData, int index)
  {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: index == 0 || index ==3 || index ==4
            ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber,
                Colors.cyan,
              ],
              begin:  FractionalOffset((0.0), 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0,1.0],
              tileMode: TileMode.clamp,
            )
        )
            : const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.redAccent,
                Colors.amber,
              ],
              begin:  FractionalOffset((0.0), 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0,1.0],
              tileMode: TileMode.clamp,
            )
        ),
        child: InkWell(
          onTap: ()
          {
            if(index == 0)
            {
              // New Available Orders
              Navigator.push(context, MaterialPageRoute(builder: (c)=> NewOrdersScreen()));

            }
            if(index == 1)
            {
              //Parcels in Progress
              Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelInProgressScreen()));

            }
            if(index == 2)
            {
              // Not Yet Delivered
              Navigator.push(context, MaterialPageRoute(builder: (c)=> NotYetDeliveredScreen()));

            }
            if(index == 3)
            {
              // History
              Navigator.push(context, MaterialPageRoute(builder: (c)=> HistoryScreen()));

            }

            if(index == 4)
            {
              // Total Earnings
              Navigator.push(context, MaterialPageRoute(builder: (c)=> EarningsScreen()));

            }
            if(index == 5)
            {
              //Logout
              firebaseAuth.signOut().then((value)
              {
                Navigator.push(context, MaterialPageRoute(builder: (c)=>const AuthScreen()));
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const SizedBox(height: 50.0,),
              Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0,),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
  restrictBlockedRidersFromUsingApp() async
  {
    await FirebaseFirestore.instance.collection("riders")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot) {
      if (snapshot.data()!["status"] != "approved") {
        Fluttertoast.showToast(msg: "Tài khoản của bạn đã bị chặn");

        firebaseAuth.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
      }
      else
      {

        UserLocation uLocation = UserLocation();
        uLocation.getCurrentLocation();
        getPerParcelDeliveryAmount();
        getRiderPreviousEarnings();

      }
    });
  }


  @override
  void initState()
  {
    restrictBlockedRidersFromUsingApp();


  }
  getRiderPreviousEarnings()
  {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get().then((snap)
    {
      previousRiderEarnings = snap.data()!["earnings"].toString();

    });
  }


  getPerParcelDeliveryAmount()
  {
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("thom123")
        .get().then((snap)
    {
     perParcelDeliveryAmount =  snap.data()!["amount"].toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
        ),
        title: Text(
          "Wellcome ${sharedPreferences!.getString("name")!}",
          style: const TextStyle(
            fontSize: 30.0,
            color: Colors.black,
            fontFamily: "Signatra",
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 1),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
          children: [
            makeDashboardItem("Đơn hàng mới", Icons.assessment,0),
            makeDashboardItem("Nhà hàng Go", Icons.airport_shuttle,1),
            makeDashboardItem("Khách hàng Go", Icons.location_history,2),
            makeDashboardItem("Lịch sử đơn hàng", Icons.done_all,3),
            makeDashboardItem("Doanh thu", Icons.monetization_on,4),
            makeDashboardItem("Đăng xuất", Icons.logout,5),


          ],
        ),
      ),

    );
  }
}
