
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState()=> _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Welcome Back,",
            style: TextStyle(color:Colors.grey[400],fontSize: 16),),
            const Text("Mohammad Fakih",
            style:TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            )
          ],),
          const SizedBox(height: 24,),
          GestureDetector(
            onTap: ()=>{},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [Colors.blueAccent.shade400,Colors.blueAccent.shade700]),
              ),
            )
          )
        ],
      )
    );
  }
  
}