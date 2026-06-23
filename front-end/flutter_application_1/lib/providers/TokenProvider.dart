import "package:flutter/material.dart";


class TokenProvider  extends ChangeNotifier{
   String? token;

   void set_token(String newToken){
    token=newToken;
    notifyListeners();
   }
   void logout() {
    token = null;
    notifyListeners();
  }
}

