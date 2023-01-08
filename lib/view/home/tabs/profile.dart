import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
        const   SizedBox(
            height: 30,
          ),
          _getSettingRow(
            color: CstColors.g,
            iconPath: "assets/icons/ic_fluent_earth_24_filled.svg",
            onTap: (x) {},
            title: 'Language',
            subtitle: 'English',
          ),
          _getSettingRow(
            color: CstColors.a,
            iconPath: "assets/icons/ic_fluent_alert_24_regular.svg",
            onTap: (x) {},
            title: 'Natifications',
            subtitle: 'enabled',
          ),
          _getSettingRow(
            color: CstColors.k,
            iconPath: "assets/icons/ic_fluent_weather_moon_24_regular.svg",
            onTap: (isTurnedOn) {
              setState(() {
                isDarkMode = isTurnedOn!;
              });
            },
            title: 'Dark Mode',
            subtitle: isDarkMode ? 'on' : 'off',
            useSwitcher: true,
            switcherOn: isDarkMode,
          ),
        ],
      ),
    );
  }

  _getSettingRow({
    required String iconPath,
    required Color color,
    required String title,
    String? subtitle,
    required Function(bool? switcherState) onTap,
    bool? useSwitcher = false,
    bool? switcherOn = false,
  }) {
    return MaterialButton(
      padding:const  EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      color: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      highlightElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      onPressed: () => onTap(!switcherOn!),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            radius: 20,
            child: SvgPicture.asset(
              iconPath,
              color: color,
              height: 20,
            ),
          ),
         const  SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: Get.theme.textTheme.headline4!.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            subtitle ?? "",
            style: Get.theme.textTheme.headline3!.copyWith(
              color: Get.theme.colorScheme.secondary.withOpacity(.5),
            ),
          ),
         const  SizedBox(
            width: 15,
          ),
          SizedBox.square(
            dimension: 40,
            child: useSwitcher!
                ? Transform.scale(
                    scale: .65,
                    child: CupertinoSwitch(
                      value: switcherOn!,
                      onChanged: onTap,
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.tertiary.withOpacity(.5),
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Get.theme.colorScheme.secondary.withOpacity(.5),
                      size: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
