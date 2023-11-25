import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:investment_agro/constant/AppColors.dart';
import 'package:investment_agro/src/ui/product_details_screen.dart';

class LongTerm extends StatefulWidget {
  const LongTerm({Key? key}) : super(key: key);

  @override
  _LongTermState createState() => _LongTermState();
}

class _LongTermState extends State<LongTerm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Long Term Projects",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width:440,

                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("long-term").snapshots(),
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

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = snapshot.data!.docs[index];
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
                        },
                      );

                    },
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
