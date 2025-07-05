void main() {
  //declare Varibles
  String original = "VidariApp";
  String reversed = reverse(original);
  List<int> numbers = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 5];
  List<int> uniqueNumber = uniquevalues(numbers);

  //Output
  print("original: $reversed");
  print("uniqueNumbers: $uniqueNumber");
} 

//functions
reverse(String input) => input.split('').reversed.join();
List<T> uniquevalues<T>(List<T> items) => items.toSet().toList();
