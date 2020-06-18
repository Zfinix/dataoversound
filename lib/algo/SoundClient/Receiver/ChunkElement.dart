//Bean representation of one recorded data
class ChunkElement {
  //Recorded data
  List<int> buffer;

  ChunkElement(this.buffer);

  List<int> getBuffer() => buffer;

  void setBuffer(List<int> buffer) => this.buffer = buffer;
}
