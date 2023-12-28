import 'package:happy_belly_kitchen/data/model/response/language_model.dart';
import 'package:happy_belly_kitchen/util/app_constants.dart';
import 'package:flutter/material.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({required BuildContext context}) {
    return AppConstants.languages;
  }
}
