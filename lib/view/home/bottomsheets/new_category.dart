import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/core/utils/menu.dart' as CoreUtils;
import 'package:task_manager/core/utils/bottom_sheet.dart' as CoreUtils;
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/view/home/widgets/custom_textfield.dart';

class NewCategoryBottomSheet extends StatefulWidget {
  NewCategoryBottomSheet({Key? key}) : super(key: key);

  NewCategoryBottomSheet.open({Key? key, Function(int _cateogoryId)? onDone, Function()? onDismiss})
      : super(key: key) {
    print('opening bottom sheet');
    CoreUtils.BottomSheet.open(
      this,
      title: 'Create Category',
      onOkClick: () async {
        print('sucessss');
        _buildingModel
          ..title = _categoryTitleController.text
          ..color = _categoryColors.values.elementAt(_categoryColorIndex);
        final _cateogoryId = await _controller.createCategory(_buildingModel);

        if (onDone != null) onDone(_cateogoryId);
      },
      onDismiss: onDismiss, 
    );
  }
  final TasksController _controller = Get.find();

  final CategoryModel _buildingModel = CategoryModel();
  final TextEditingController _categoryTitleController =
      TextEditingController();
  int _categoryColorIndex = 0;

  final Map<String, Color> _categoryColors = {
    'green': CstColors.l,
    'blue': CstColors.j,
    'purple': CstColors.i,
    'brown': CstColors.s,
  };

  @override
  State<NewCategoryBottomSheet> createState() => _NewCategoryBottomSheetState();
}

class _NewCategoryBottomSheetState extends State<NewCategoryBottomSheet> {
  final _categoryColorWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const String prefixTitlesSpace = '    ';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prefixTitlesSpace + 'Category title',
          style: Get.theme.textTheme.headline4!.copyWith(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        CustomTextField(
          textHint: 'Category title',
          controller: widget._categoryTitleController,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          prefixTitlesSpace + 'Category color',
          style: Get.theme.textTheme.headline4!.copyWith(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        GestureDetector(
          onTap: () {
            CoreUtils.Menu.open(
              selectedItemIndex: widget._categoryColorIndex,
              onSelectedItem: (newColorIndex) {
                setState(() {
                  widget._categoryColorIndex = newColorIndex;
                });
              },
              openFromWidgetKey: _categoryColorWidgetKey,
              items: List.generate(
                widget._categoryColors.length,
                (index) {
                  return CoreUtils.MenuItem(
                    label: widget._categoryColors.keys.elementAt(index),
                    preLabel: _getColorButton(
                        widget._categoryColors.values.elementAt(index)),
                  );
                },
              ),
            );
          },
          child: Container(
            key: _categoryColorWidgetKey,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface.withOpacity(.4),
              borderRadius: BorderRadius.circular(12.5),
            ),
            child: Row(
              children: [
                _getColorButton(widget._categoryColors.values
                    .elementAt(widget._categoryColorIndex)),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    widget._categoryColors.keys
                        .elementAt(widget._categoryColorIndex),
                    style: Get.theme.textTheme.headline4!.copyWith(
                      color: Get.theme.colorScheme.secondary.withOpacity(.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: Get.theme.colorScheme.secondary.withOpacity(.5),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _getColorButton(Color color) => CircleAvatar(
        radius: 10,
        backgroundColor: color.withOpacity(.3),
        child: CircleAvatar(
          radius: 7,
          backgroundColor: color,
        ),
      );
}
