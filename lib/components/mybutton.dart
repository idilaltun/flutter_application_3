import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  //final Function()? onTap;
   final void Function(BuildContext) onTap;

  const MyButton({super.key, required this.onTap});
   

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: () {
        onTap(context); // Call the onTap callback with the context
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}