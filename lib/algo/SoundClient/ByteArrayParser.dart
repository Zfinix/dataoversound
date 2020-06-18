import 'dart:typed_data';

class ByteArrayParser {
  //Array used when merging
  Uint8List outputByteArray;

  Uint8List concatenateTwoArrays(final Uint8List array1, Uint8List array2) {
    return Uint8List.fromList([...array1, ...array2]);
  }

  //Called to divide given byte array into byte arrays of size 256-errorDetNum
  List<Uint8List> divideInto256Chunks(List<int> inputArray, int errorDetBNum) {
    List<Uint8List> tempList;
    int startPos = 0;
    int endPos = 256 - errorDetBNum;
    int bytesLeft = inputArray.length;
    while ((bytesLeft + errorDetBNum) > 256) {
      Uint8List tempArr = inputArray.getRange(startPos, endPos).toList();

      tempList.add(tempArr);
      startPos = endPos;
      endPos = startPos + 256 - errorDetBNum;
      bytesLeft -= (256 - errorDetBNum);
    }
    Uint8List tempArr = inputArray.getRange(startPos, inputArray.length);
    tempList.add(tempArr);
    return tempList;
  }

  //Called to add given array into one
  void mergeArray(inputArray) {
    if (outputByteArray == null) {
      outputByteArray = inputArray;
    } else {
      outputByteArray = concatenateTwoArrays(outputByteArray, inputArray);
    }
  }

  //Called to return all given arrays as one and reset it
  getAndResetOutputByteArray() {
    var tempArr = outputByteArray;
    outputByteArray = null;
    return tempArr;
  }
}
