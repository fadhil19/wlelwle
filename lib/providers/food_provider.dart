import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  List<FoodItem> foodItems = [];

  FoodProvider() {
    tz.initializeTimeZones();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String foodItemsString = prefs.getString('foodItems') ?? '[]';
      List<dynamic> foodItemsJson = jsonDecode(foodItemsString);
      foodItems = foodItemsJson.map((item) => FoodItem.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      print("Error loading food items: $e");
    }
  }

  Future<void> _saveFoodItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> foodItemsJson = foodItems.map((item) => jsonEncode(item.toJson())).toList();
      prefs.setString('foodItems', jsonEncode(foodItemsJson));
      notifyListeners();
    } catch (e) {
      print("Error saving food items: $e");
    }
  }

  void addFoodItem(FoodItem item) {
    foodItems.add(item);
    _saveFoodItems();
    notifyListeners();
  }

  void removeFoodItem(FoodItem item) {
    foodItems.remove(item);
    _saveFoodItems();
    notifyListeners();
  }

  Future<void> pickImage(FoodItem item) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        String imageUrl;
        if (kIsWeb) {
          imageUrl = await _uploadImageWeb(pickedFile);
        } else {
          imageUrl = await _uploadImage(File(pickedFile.path));
        }
        item.imageUrl = imageUrl;
        _saveFoodItems();
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('food_images/${DateTime.now().toIso8601String()}');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  Future<String> _uploadImageWeb(XFile pickedFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('food_images/${DateTime.now().toIso8601String()}');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = ref.putData(await pickedFile.readAsBytes(), metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }
}
