import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/app_setting_widget.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/setting_third_page.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/screens/auth/change_password_screen.dart';
import 'package:kivicare_flutter/screens/language_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/patient_encounter_screen.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/edit_patient_profile_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientSettingFragment extends StatefulWidget {
  @override
  _PatientSettingFragmentState createState() => _PatientSettingFragmentState();
}

class _PatientSettingFragmentState extends State<PatientSettingFragment>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    tabController = new TabController(initialIndex: 0, length: 3, vsync: this);
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Widgets

  Widget buildEditProfileWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            CachedImageWidget(
                url: appStore.profileImage.validate(),
                height: 90,
                circle: true,
                fit: BoxFit.cover),
            Positioned(
              bottom: -8,
              left: 0,
              right: -60,
              child: GestureDetector(
                onTap: () {
                  EditPatientProfileScreen().launch(context);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: appPrimaryColor,
                    boxShape: BoxShape.circle,
                    border: Border.all(color: white, width: 3),
                  ),
                  child: Image.asset(ic_edit,
                      height: 20, width: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        22.height,
        Text(
          getRoleWiseName(
              name:
                  "${appStore.firstName.validate()} ${appStore.lastName.validate()}"),
          style: boldTextStyle(),
        ),
        Text(
          appStore.userMobileNumber.validate(),
          style: primaryTextStyle(),
        ),
      ],
    );
  }

  Widget buildFirstWidget() {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        AppSettingWidget(
          name: locale.lblEncounters,
          image: ic_services,
          widget: PatientEncounterScreen(),
          subTitle: locale.lblYourEncounters,
        ),
      ],
    );
  }

  Widget buildSecondWidget() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // AppSettingWidget for theme selection
        AppSettingWidget(
          name: locale.lblSelectTheme,
          image: ic_darkmode,
          subTitle: locale.lblChooseYourAppTheme,
          onTap: () => showThemeSelectionDialog(context),
        ),

        // AppSettingWidget for changing password
        AppSettingWidget(
          name: locale.lblChangePassword,
          image: ic_unlock,
          widget: ChangePasswordScreen(),
        ),

        // AppSettingWidget for selecting language
        AppSettingWidget(
          name: locale.lblLanguage,
          isLanguage: true,
          subTitle: selectedLanguageDataModel!.name.validate(),
          image: selectedLanguageDataModel!.flag.validate(),
          onTap: () async {
            await LanguageScreen().launch(context).then((value) {
              setState(() {});
            });
          },
        ),
      ],
    );
  }

  void showThemeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(locale.lblSelectTheme, style: primaryTextStyle()),
          children: [
            for (int i = 0; i < themeModeList.length; i++)
              SimpleDialogOption(
                child: Text(themeModeList[i], style: primaryTextStyle()),
                onPressed: () {
                  setState(() {
                    currentIndex = i;

                    if (i == THEME_MODE_SYSTEM) {
                      appStore.setDarkMode(
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark,
                      );
                    } else if (i == THEME_MODE_LIGHT) {
                      appStore.setDarkMode(false);
                    } else {
                      if (i == THEME_MODE_DARK) {
                        appStore.setDarkMode(true);
                      }
                    }

                    setValue(THEME_MODE_INDEX, i);
                  });
                  // if (i == THEME_MODE_DARK) {
                  //   appStore.setTextColor(Colors.white as bool);
                  // }

                  finish(context);
                },
              ),
          ],
        );
      },
    );
  }
  //endregion

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  50.height,
                  buildEditProfileWidget(),
                  20.height,
                  TabBar(
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor:
                        appStore.isDarkModeOn ? Colors.white : primaryColor,
                    isScrollable: false,
                    labelStyle: boldTextStyle(),
                    unselectedLabelStyle: primaryTextStyle(),
                    unselectedLabelColor:
                        appStore.isDarkModeOn ? gray : textSecondaryColorGlobal,
                    indicator: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: radius()),
                        color: context.cardColor),
                    tabs: [
                      Tab(
                          icon: Text(locale.lblGeneralSetting,
                              textAlign: TextAlign.center)),
                      Tab(
                          icon: Text(locale.lblAppSettings,
                              textAlign: TextAlign.center)),
                      Tab(
                          icon: Text(locale.lblOther,
                              textAlign: TextAlign.center)),
                    ],
                  ).paddingAll(16).center(),
                  Container(
                    height: constraint.maxHeight,
                    child: TabBarView(
                      controller: tabController,
                      physics: BouncingScrollPhysics(),
                      children: [
                        buildFirstWidget().paddingAll(16),
                        buildSecondWidget().paddingAll(16),
                        SettingThirdPage().paddingAll(16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
