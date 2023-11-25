import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investment_agro/constant/AppColors.dart';
import 'package:investment_agro/src/ui/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var inputText = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Preventing the back action
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.light_green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  onChanged: (val) {
                    setState(() {
                      inputText = val;
                      print(inputText);
                    });
                  },
                ),
                SizedBox(height: 5.h),
                Expanded(
                  child: Container(
                    height: 1000,
                    width: 500,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("products").snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Something went wrong"),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Text("Loading"),
                          );
                        }

                        // Filter the products based on the input text
                        var filteredProducts = snapshot.data!.docs.where((document) {
                          return document
                              .data()
                              .toString()
                              .toLowerCase()
                              .contains(inputText.toLowerCase());
                        }).toList();

                        return ListView(
                          children: filteredProducts.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                            String imageUrl = data["img"];

                            return GestureDetector(
                              onTap: () {
                                // Navigate to the product details screen and pass the product data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProductDetails(data)),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.network(
                                        imageUrl,
                                        height: 130,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Text('Failed to load image');
                                        },
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            data['name'],
                                            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            data['price'],
                                            style: TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
