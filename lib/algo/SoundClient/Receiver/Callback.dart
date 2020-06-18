//Interface for father activity of recorder
mixin Callback {
  //Called when recorder finishes recording one byte array
  void onBufferAvailable(List<int> buffer);

  //Set size of byte arrays that recorder will produce
  void setBufferSize(int size);
}
