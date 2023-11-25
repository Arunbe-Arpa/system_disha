import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:investment_agro/src/ui/fixReturn.dart';
import 'package:investment_agro/src/ui/longTerm.dart';
import 'package:investment_agro/src/ui/shortTerm.dart';
import 'package:investment_agro/src/ui/variableReturn.dart';

import '../../../constant/AppColors.dart';
import '../allProjects.dart';
import '../product_details_screen.dart';
import '../search_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _carouselImages = [];
  var _dotPosition = 0;
  var _firestoreInstance = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _products = [];
  TextEditingController _searchController = TextEditingController();

  Future<void> fetchCursorImages() async {
    try {
      QuerySnapshot qn = await _firestoreInstance.collection("Carousel_slider").get();
      print("Fetched data: ${qn.docs}");
      setState(() {
        _carouselImages = qn.docs.map((doc) => doc["img"] as String).toList();
      });
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestoreInstance.collection("products").get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _products = querySnapshot.docs.map((doc) {
            return {
              "name": doc["name"],
              "description": doc["description"],
              "price": doc["price"],
              "img": doc["img"],
            };
          }).toList();
        });
      } else {
        print("No products found");
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }



  @override
  void initState() {
    fetchCursorImages();
    fetchProducts();
    super.initState();
  }

  /*Future addToFavorites()async{
    final FirebaseAuth _auth=FirebaseAuth.instance;
    var currentUser=_auth.currentUser;
    CollectionReference _collectionRef=FirebaseFirestore.instance.collection("favorites");
    return _collectionRef.doc(currentUser!.email).collection("items").doc().set(
     {
       "name": _products["name"],
       "price": _products["price"],
       "img":product["img"],

     }
    ).then((value) => print("Added"));
  }
*/

  Future<void> addToFavorites(Map<String, dynamic> product) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;
      CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection("favorites");
      await _collectionRef
          .doc(currentUser!.email)
          .collection("items")
          .add({
        "name": product["name"],
        "price": product["price"],
        "img": product["img"],
      })
          .then((value) => print("Added to favorites"));
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            borderSide: BorderSide(color: Color(0xFF9BC27E)),
                          ),
                          hintText: "Search here",
                          hintStyle: TextStyle(fontSize: 15.sp),
                        ),
                        onTap: () => Navigator.push(
                            context, CupertinoPageRoute(builder: (__) => SearchScreen())),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        color: AppColors.light_green,
                        height: 50.h,
                        width: 50.h,
                        child: Center(
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {},
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.h),
             AspectRatio(
                aspectRatio: 1.5,
                child: CarouselSlider(
                  items: _carouselImages.map((item) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(item),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )).toList(),
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.99,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (val, carouselPageChangedReason) {
                      setState(() {
                        _dotPosition = val;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              DotsIndicator(
                dotsCount: _carouselImages.length == 0 ? 1 : _carouselImages.length,
                position: _dotPosition,
                decorator: DotsDecorator(
                  activeColor: Colors.green,
                  color: Colors.green.withOpacity(0.5),
                  spacing: EdgeInsets.all(2),
                  activeSize: Size(8, 8),
                  size: Size(6, 6),
                ),
              ),
              SizedBox(height: 5.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Text(
                      "Invest by categories",
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Add your navigation logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ShortTerm()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          ),
                          elevation: 3,
                          child: Container(
                            width: 110,
                            height: 130,
                            color: AppColors.lightest_green,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shortcut_rounded,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Short Term",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Add your navigation logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LongTerm()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          ),
                          elevation: 3,
                          child: Container(
                            width: 110,
                            height: 130,
                            color: AppColors.lightest_green,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Long Term",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Add your navigation logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VariableReturn()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          ),
                          elevation: 3,
                          child: Container(
                            width: 110,
                            height: 130,
                            color: AppColors.lightest_green,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.difference,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Variable return",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Add your navigation logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FixReturn()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          ),
                          elevation: 3,
                          child: Container(
                            width: 110,
                            height: 130,
                            color: AppColors.lightest_green,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.gps_not_fixed,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Fixed Return",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),







              SizedBox(height: 5.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Your GestureDetector and Card widgets for categories
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Projects",
                      style: TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Add your view all logic here
                        Navigator.push(context,CupertinoPageRoute(builder: (__)=>AllProjects()));
                      },
                      child: Text(
                        "View all",
                        style: TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (__) => ProductDetails(_products[index])),
                    ),
                    child: Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 2.1,
                            child: Image.network(
                              _products[index]["img"],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_products[index]["name"]}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                Text(
                                  "${_products[index]["price"]}",
                                  style: TextStyle(color: Colors.green, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.green,
                                ),
                                onPressed: () =>addToFavorites(_products[index]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
