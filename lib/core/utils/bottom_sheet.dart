import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheet {
  BottomSheet.close() {
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }
  BottomSheet.open(
    Widget child, {
    required String title,
    Color? barrierColor,
    bool? isDismissible,
    bool? ignoreSafeArea,
    Color? elevationColor,
    Function()? onOkClick,
    Function()? onCancelClick,
    String? okLabel,
    String? cancelLabel,
  }) {
    Get.bottomSheet(
      DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: elevationColor ?? Colors.black.withOpacity(.2),
                blurRadius: 150),
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 7, right: 25, left: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 4.5,
                  width: Get.size.width / 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Get.theme.colorScheme.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  SizedBox.square(
                    dimension: 20,
                    child: onCancelClick != null
                        ? Center(
                            child: GestureDetector(
                              onTap: () {
                                onCancelClick();
                                Get.back();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 22,
                                color: Get.theme.colorScheme.secondary,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.headline5!.copyWith(
                      height: 1.4,
                      color: Get.theme.colorScheme.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  SizedBox.square(
                    dimension: 20,
                    child: onOkClick != null
                        ? Center(
                            child: GestureDetector(
                              onTap: () {
                                onOkClick();
                                Get.back();
                              },
                              child: Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: Get.theme.colorScheme.secondary,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.size.height - 150,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: SingleChildScrollView(
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: ignoreSafeArea ?? false,
      isDismissible: isDismissible ?? true,
      barrierColor: Colors.transparent,
    );
  }
}
