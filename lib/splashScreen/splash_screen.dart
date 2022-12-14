import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodpanda_riders_app/authentication/auth_screen.dart';
import 'package:foodpanda_riders_app/global/global.dart';
import 'package:foodpanda_riders_app/mainScreens/home_screen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen>
{
  
  startTimer()
  {
    Timer(const Duration(seconds: 1), () async
    {
      //If rider is loggedin already
      if(firebaseAuth.currentUser != null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  HomeScreen() ));

      }
      //If rider is NOT loggedin already
      else
      {
       Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen() ));

      }
    });
  }
 //chức năng này được gọi tự động bất cứ khi nào người dùng đến màn hình của họ.
  @override
  void initState() {

    super.initState();
    startTimer();
  }

  @override

  Widget build(BuildContext context) {
    return Material(
      child: Container(

        color: Colors.white38,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/service.jpg"),
              const SizedBox(height: 10,),

             const Padding(
               padding: EdgeInsets.all(10.0),
               child: Text(
                 "Foody - Giao hàng mọi lúc mọi nơi",
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Colors.black54,
                   fontSize: 30,
                   fontFamily: "Regular",
                   letterSpacing: 3,
                 ),
               ),
             ),

            ],
          ),
        ),
      ),
    );
  }
}
