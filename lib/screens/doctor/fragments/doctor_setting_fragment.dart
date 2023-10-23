import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/app_setting_widget.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/role_widget.dart';
import 'package:kivicare_flutter/components/setting_third_page.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/response_model.dart';
import 'package:kivicare_flutter/network/google_repository.dart';
import 'package:kivicare_flutter/screens/auth/change_password_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/doctor_session_list_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/edit_profile_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/holiday_list_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service_list_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/telemed/telemed_screen.dart';
import 'package:kivicare_flutter/screens/language_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/app_widgets.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorSettingFragment extends StatefulWidget {
  @override
  _DoctorSettingFragmentState createState() => _DoctorSettingFragmentState();
}

class _DoctorSettingFragmentState extends State<DoctorSettingFragment>
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

  Widget buildDoctorEditProfileWidget() {
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
                onTap: () => EditProfileScreen().launch(context),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: boxDecorationDefault(
                      border: Border.all(color: white, width: 3),
                      shape: BoxShape.circle,
                      color: appPrimaryColor),
                  child: ic_edit.iconImage(
                      size: 20, color: Colors.white, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
        20.height,
        Text(
          getRoleWiseName(
              name:
                  "${appStore.firstName.validate()} ${appStore.lastName.validate()}"),
          style: boldTextStyle(size: 20),
        ),
        RoleWidget(
          isShowDoctor: appStore.userEnableGoogleCal == ON && isProEnabled(),
          child: Column(
            children: [
              20.height,
              googleCalendar(context).onTap(
                () async {
                  if (appStore.userDoctorGoogleCal != ON) {
                    await authService.signInWithGoogle().then((user) async {
                      if (user != null) {
                        appStore.setLoading(true);

                        Map<String, dynamic> request = {
                          'code':
                              await user.getIdToken().then((value) => value),
                        };

                        await connectGoogleCalendar(request: request)
                            .then((value) async {
                          ResponseModel data = value;

                          appStore.setUserDoctorGoogleCal(ON);

                          appStore.setGoogleUsername(
                              user.displayName.validate(),
                              initiliaze: true);
                          appStore.setGoogleEmail(user.email.validate(),
                              initiliaze: true);
                          appStore.setGooglePhotoURL(user.photoURL.validate(),
                              initiliaze: true);

                          toast(data.message);
                          appStore.setLoading(false);
                        }).catchError((e) {
                          toast(e.toString());
                          appStore.setLoading(false);
                        });
                      }
                    }).catchError((e) {
                      appStore.setLoading(false);
                      toast(e.toString());
                    });
                  } else {
                    appStore.setLoading(true);
                    showConfirmDialogCustom(
                      context,
                      onAccept: (c) {
                        disconnectGoogleCalendar().then((value) {
                          appStore.setUserDoctorGoogleCal(OFF);

                          appStore.setGoogleUsername("", initiliaze: true);
                          appStore.setGoogleEmail("", initiliaze: true);
                          appStore.setGooglePhotoURL("", initiliaze: true);
                          appStore.setLoading(false);
                          toast(value.message.validate());
                        }).catchError((e) {
                          appStore.setLoading(false);
                          toast(e.toString());
                        });
                      },
                      title: locale.lblAreYouSureYouWantToDisconnect,
                      dialogType: DialogType.CONFIRMATION,
                      positiveText: locale.lblYes,
                    );
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDoctorFirstWidget() {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        AppSettingWidget(
          name: locale.lblServices,
          image: ic_services,
          widget: ServiceListScreen(),
          subTitle: locale.lblClinicServices,
        ),
        AppSettingWidget(
          name: locale.lblHoliday,
          image: ic_holiday,
          widget: HolidayScreen(),
          subTitle: locale.lblClinicHoliday,
        ),
        AppSettingWidget(
          name: locale.lblSessions,
          image: ic_calendar,
          widget: DoctorSessionListScreen(),
          subTitle: locale.lblClinicSessions,
        ),
        if (appStore.userTelemedOn.validate() ||
            appStore.userMeetService.validate())
          AppSettingWidget(
            name: locale.lblTelemed,
            image: ic_telemed,
            widget: TelemedScreen(),
            subTitle: locale.lblVideoConsulting,
          ),
      ],
    );
  }

  Widget buildDoctorSecondWidget() {
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
                  buildDoctorEditProfileWidget(),
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
                        buildDoctorFirstWidget().paddingAll(16),
                        buildDoctorSecondWidget().paddingAll(16),
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
