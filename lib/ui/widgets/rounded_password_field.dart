import 'package:flutter/material.dart';
import 'package:Gemu/ui/widgets/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final isPasswordObscure = {"condition": true};
  RoundedPasswordField({
    Key key,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: isPasswordObscure["condition"],
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        cursorColor: Color(0xFF6F35A5),
        style: TextStyle(color: Colors.black),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.black),
          icon: Icon(
            Icons.lock,
            color: Color(0xFF6F35A5),
          ),
          suffixIcon: new GestureDetector(
            onTap: () {
              isPasswordObscure["condition"] = !isPasswordObscure["condition"];
              //
              // Permet changer une valeur dans un Sateless !!! OMG type bool
              //
              (context as Element).markNeedsBuild();
            },
            onLongPress: () {
              isPasswordObscure["condition"] = !isPasswordObscure["condition"];
              (context as Element).markNeedsBuild();
            },
            onLongPressUp: () {
              isPasswordObscure["condition"] = !isPasswordObscure["condition"];
              (context as Element).markNeedsBuild();
            },
            child: new Icon(
              isPasswordObscure["condition"]
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Color(0xFF6F35A5),
            ),
          ),
          // suffixIcon: Icon(
          //   Icons.visibility,
          //   color: Color(0xFF6F35A5),
          //   // onPressed: () {
          //   //   // Update the state i.e. toogle the state of passwordVisible variable
          //   //   setState(() {
          //   //     _passwordVisible = !_passwordVisible;
          //   //   });
          //   // },
          // ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
