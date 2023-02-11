import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MenuItem {
  final String label;
  final Widget? preLabel;
  final Widget? sufLabel;

  MenuItem({required this.label, this.preLabel, this.sufLabel});
}

class Menu {
  final GlobalKey? openFromWidgetKey;
  final Size? initialSize;
  final Offset? initialOffset;
  final List<MenuItem> items;
  final Function(int newItemIndex) onSelectedItem;
  final bool useFromWigetHeight;
  int selectedItemIndex;
  Menu.open(
      {this.openFromWidgetKey,
      this.selectedItemIndex = 0,
      this.initialSize,
      this.initialOffset,
      this.useFromWigetHeight = false,
      required this.onSelectedItem,
      required this.items}) {
    assert(openFromWidgetKey != null ||
        initialSize != null && initialOffset != null);
    final RenderBox? box = openFromWidgetKey != null
        ? openFromWidgetKey!.currentContext!.findRenderObject()! as RenderBox
        : null;

    Offset offset =
        box != null ? box.localToGlobal(Offset.zero) : initialOffset!;
    final Size size = box != null ? box.size : initialSize!;

    offset = Offset(offset.dx + size.width, offset.dy);

    final int itemCount = items.length;
    final double itemHeight = useFromWigetHeight ? size.height : 50;
    final double containerInitialHeight = size.height;
    final bool openToTop =
        offset.dy + (containerInitialHeight / 2) > Get.size.height / 2;
    double containerHeight = itemHeight * itemCount;
    double containerMaxHeight = openToTop
        ? (offset.dy + containerInitialHeight) - 20
        : (Get.size.height - offset.dy) - 20;

    Get.generalDialog(
      transitionDuration: 200.milliseconds,
      barrierLabel: 'BarrierLabel',
      barrierDismissible: true,
      barrierColor: Colors.black45.withOpacity(.1),
      pageBuilder: (ctx, a1, a2) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: a1,
              builder: (ctx, c) {
                return Positioned(
                  right: Get.size.width - offset.dx,
                  bottom: openToTop
                      ? Get.size.height - offset.dy - containerInitialHeight
                      : null,
                  top: !openToTop ? offset.dy : null,
                  child: AnimatedContainer(
                    width: size.width,
                    curve: Curves.linearToEaseOut,
                    duration: 200.milliseconds,
                    height: a1.value == 1
                        ? containerHeight
                        : containerInitialHeight,
                    constraints: BoxConstraints(maxHeight: containerMaxHeight),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: itemCount,
                      itemBuilder: (ctx, i) {
                        final item = items.elementAt(i);
                        final isSelected = i == selectedItemIndex;
                        return GestureDetector(
                          onTap: () {
                            selectedItemIndex = i;
                            onSelectedItem(i);
                            Get.back();
                          },
                          child: SizedBox(
                            height: itemHeight,
                            child: Container(
                              margin: isSelected
                                  ? EdgeInsets.all(5)
                                  : EdgeInsets.zero,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Get.theme.colorScheme.tertiary
                                          .withOpacity(.2),
                                    )
                                  : null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSelected ? 10 : 15),
                                child: Row(
                                  children: [
                                    if (item.preLabel != null) ...[
                                      item.preLabel!,
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Get.theme.textTheme.headline4!
                                            .copyWith(
                                          color: Get.theme.colorScheme.secondary
                                              .withOpacity(.5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      SvgPicture.asset(
                                        'assets/icons/ic_fluent_checkmark_24_filled.svg',
                                        color: Get.theme.colorScheme.secondary
                                            .withOpacity(.5),
                                        height: 18,
                                      ),
                                    if (item.sufLabel != null) item.sufLabel!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
