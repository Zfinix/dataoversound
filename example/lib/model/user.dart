import 'package:flutter/material.dart';

class Message {
  //Message content
  final String message;
  //User who sent message, 0-current user, 1-other user
  final int user;
  final int userID;
  final isBold;

  Message({
    @required this.message,
    @required this.user,
    @required this.userID,
    this.isBold = false,
  });
}
