




import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      this.controller,
      this.textHint,
      this.minLines = 1,
      this.maxLines = 1,
      this.expands = false,
      this.maxLength})
      : super(key: key);
  final TextEditingController? controller;
  final String? textHint;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      expands: expands,
      controller: controller,
      cursorColor: Get.theme.colorScheme.secondary,
      style: Get.theme.textTheme.headline4!.copyWith(
        color: Get.theme.colorScheme.secondary,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        hintText: textHint,
        hintStyle: Get.theme.textTheme.headline4!.copyWith(
          color: Get.theme.colorScheme.secondary.withOpacity(.5),
        ),
        filled: true,
        fillColor: Get.theme.colorScheme.surface.withOpacity(.4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.5),
          borderSide: BorderSide(
            style: BorderStyle.none,
            color: Get.theme.colorScheme.surface,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.5),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.surface,
            width: 4,
          ),
        ),
      ),
    );
  }
}
