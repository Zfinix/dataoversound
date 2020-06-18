mixin CallbackSendRec {
  //Parameter to be returned in action done function if sending finished
  static const  int SEND_ACTION = 0;
  //Parameter to be returned in action done function if receiving finished
  static const int RECEIVE_ACTION = 1;

  //Called to notify callback class that sending or receiving is done
  void actionDone(int srFlag, String message);

  //Called to notify callback class that receiving has started
  void receivingSomething();
}
