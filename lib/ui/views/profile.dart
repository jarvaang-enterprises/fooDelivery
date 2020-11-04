import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/profile.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/delivery.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileModel>(
      onModelReady: (model) {
        model.getCurrentUser();
      },
      builder: (context, model, child) {
        return Scaffold(
          key: _key,
          appBar: appBar(context, backAvailable: true, model: model, key: _key),
          drawer: AppDrawer(
            model: model,
            name: model.modelName,
          ),
          body: SafeArea(
            child: model.state == ViewState.Busy
                ? Center(
                    child: SpinKitChasingDots(
                      color: Color(0xfffd5f00),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 12 * 2.5,
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 28.0,
                            ),
                            child: CircleAvatar(
//                              radius: 70.0,
                              maxRadius: 70.0,
                              minRadius: 60.0,
                              backgroundColor: Theme.of(context).platform ==
                                      TargetPlatform.iOS
                                  ? Colors.blue
                                  : Colors.white,
                              child: model.user.photoUrl == null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        model.user.displayName
                                            .split(' ')[0]
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(fontSize: 40.0),
                                      ),
                                    )
                                  : Image(
                                      image: NetworkImage(model.user.photoUrl,
                                          scale: 1),
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                model.user.displayName,
                                style: TextStyle(
                                    fontSize: 24.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                model.user.email,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: MaterialButton(
                                elevation: 0.5,
                                minWidth: double.maxFinite,
                                height: 50,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DeliveryScreen()));
                                },
                                color: Colors.brown,
                                child: Center(
                                  child: Text(
                                    'Update Delivery Data',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
