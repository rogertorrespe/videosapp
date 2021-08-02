import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

import '../helpers/helper.dart';
import '../models/gender.dart';
import '../models/login_model.dart';
import '../models/user_profile_model.dart';
import '../models/videos_model.dart';
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/socket_repository.dart' as socketRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/complete_profile_view.dart';
import '../views/password_login_view.dart';
import '../views/reset_forgot_password_view.dart';
import '../views/verify_otp_screen.dart';
import 'dashboard_controller.dart';
import 'following_controller.dart';

class UserController extends ControllerMVC {
  List<Video> users = <Video>[];
  GlobalKey<ScaffoldState> userScaffoldKey;
  GlobalKey<ScaffoldState> otpScaffoldKey;
  GlobalKey<ScaffoldState> completeProfileScaffoldKey;
  GlobalKey<ScaffoldState> forgotPasswordScaffoldKey;
  GlobalKey<ScaffoldState> resetForgotPasswordScaffoldKey;
  GlobalKey<ScaffoldState> editVideoScaffoldKey;

  ValueNotifier<bool> updateViewState = new ValueNotifier(false);
  ValueNotifier<int> userIdValue = new ValueNotifier(0);
  GlobalKey<FormState> formKey = new GlobalKey();
  GlobalKey<FormState> otpFormKey = new GlobalKey();
  GlobalKey<FormState> registerFormKey = new GlobalKey(debugLabel: "register");
  GlobalKey<FormState> completeProfileFormKey = new GlobalKey(debugLabel: "completeProfile");
  GlobalKey<FormState> resetForgotPassword = new GlobalKey(debugLabel: "resetForgotPassword");
  GlobalKey<FormState> editVideoFormKey = new GlobalKey(debugLabel: "editVideoForm");
  ValueNotifier<bool> showBannerAd = new ValueNotifier(false);
  Map userProfile;
  OverlayEntry loader;
  DashboardController homeCon;
  String timezone = 'Unknown';
  bool showUserLoader = false;
  ScrollController scrollController1;
  ScrollController scrollController2;
  int page = 1;
  int followUserId = 0;
  String searchKeyword = '';
  bool showLoadMoreUsers = true;
  String largeProfilePic = '';
  String smallProfilePic = '';
  LoginData completeProfile;
  int curIndex = 0;
  String otp = "";
  bool showLoader = false;
  bool showLoadMore = true;
  var searchController = TextEditingController();
  bool followUnfollowLoader = false;
  String followText = "Follow";
  int countTimer = 60;
  bool bHideTimer = false;
  String iosUuId = "";
  String iosEmail = "";
  InterstitialAd _interstitialAd;
  RewardedAd myRewarded;
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  IO.Socket socket;
  String fullName = "";
  String email = "";
  String userName = "";
  String password = "";
  String confirmPassword = "";
  PanelController pc = new PanelController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController profileUsernameController = TextEditingController();
  TextEditingController profileEmailController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController otpController;
  FollowingController followCon;
  String url = '${GlobalConfiguration().get('node_url')}';
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
  ]);

  final FacebookLogin facebookSignIn = FacebookLogin();

  bool showSendOtp = false;

  ScrollController scrollController;

  String profileUsername = '';
  DateTime profileDOB;
  String profileDOBString = '';
  final picker = ImagePicker();

  File selectedDp;

  String loginType = '';
  List<Gender> gender = <Gender>[const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')];

  // Gender selectedGender = Gender('', 'Select Gender');
  String selectedGender;
  bool visibleSocialButtons = true;

  GlobalKey<ScaffoldState> myProfileScaffoldKey;

  String description;

  int privacy;

  @override
  void initState() {
    userScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_loginPage');
    otpScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_otpPage');
    completeProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_completeProfilePage');
    forgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_ForgotPasswordPage');
    resetForgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_resetForgotPasswordScaffoldPage');
    myProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_myProfileScaffoldPage');
    editVideoScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editVideoScaffoldPage');

    scrollController = new ScrollController();
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }
    setState(() {
      timezone = timezone;
    });
  }

  Future<void> getAds() {
    setState(() {});

    appId = Platform.isAndroid ? hashRepo.adsData.value['android_app_id'] : hashRepo.adsData.value['ios_app_id'];
    bannerUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_banner_app_id'] : hashRepo.adsData.value['ios_banner_app_id'];
    screenUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_interstitial_app_id'] : hashRepo.adsData.value['ios_interstitial_app_id'];
    videoUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_video_app_id'] : hashRepo.adsData.value['ios_video_app_id'];
    bannerShowOn = hashRepo.adsData.value['banner_show_on'];
    interstitialShowOn = hashRepo.adsData.value['interstitial_show_on'];
    videoShowOn = hashRepo.adsData.value['video_show_on'];
    print("bannerShowOn + interstitialShowOn + videoShowOn");
    print(bannerShowOn + interstitialShowOn + videoShowOn);

    if (appId != "") {
      MobileAds.instance.initialize().then((value) async {
        if (bannerShowOn.indexOf("2") > -1) {
          showBannerAd.value = true;
          showBannerAd.notifyListeners();
          // createBannerAd(bannerUnitId);

        }

        if (interstitialShowOn.indexOf("2") > -1) {
          // _interstitialAd?.dispose();
          createInterstitialAd(screenUnitId);
        }

        if (videoShowOn.indexOf("2") > -1) {
          await createRewardedAd(videoUnitId);

          // RewardedVideoAd.instance.show();
        }
      });
    }
  }

  Future<void> createInterstitialAd(adUnit) {
    _interstitialAd ??= InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          ad.dispose();
          print('Ad closed.');
        },
        // Called when an ad is in the process of leaving the application.
        onApplicationExit: (Ad ad) => print('Left application.'),
        // Called when a RewardedAd triggers a reward.
        onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
          print('Reward earned: $reward');
        },
      ),
    );
    Future<void>.delayed(Duration(seconds: 1), () => _interstitialAd.load());
    Future<void>.delayed(Duration(seconds: 3), () => _interstitialAd.show());
    ;
  }

  Future<void> createRewardedAd(adUnitId) {
    myRewarded ??= RewardedAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      listener: AdListener(
          onAdLoaded: (Ad ad) {
            print('${ad.runtimeType} loaded.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('${ad.runtimeType} failed to load: $error');
            ad.dispose();

            createRewardedAd(adUnitId);
          },
          onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
          onAdClosed: (Ad ad) {
            print('${ad.runtimeType} closed.');
            ad.dispose();
            // createRewardedAd(adUnitId);
          },
          onApplicationExit: (Ad ad) => print('${ad.runtimeType} onApplicationExit.'),
          onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
            print(
              '$RewardedAd with reward $RewardItem(${reward.amount}, ${reward.type})',
            );
          }),
    );
    Future<void>.delayed(Duration(seconds: 1), () => myRewarded.load());
    Future<void>.delayed(Duration(seconds: 10), () => myRewarded.show());
  }

  getUuId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    print("pref.getString(ios_uuid)");
    print(pref.getString("ios_uuid"));
//    pref.setString("ios_uuid", "");
//    pref.setString("ios_email", "");
    setState(() {
      iosUuId = pref.getString("ios_uuid") == null ? "" : pref.getString("ios_uuid");
      iosEmail = pref.getString("ios_email") == null ? "" : pref.getString("ios_email");
    });
    print("iosUuId $iosUuId");
    print("iosEmail $iosEmail");
  }

  signInWithApple() async {
    setState(() {
      showLoader = true;
    });
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId: 'com.leuke.applogin',
          redirectUri: Uri.parse(
            'https://smiling-abrupt-screw.glitch.me/callbacks/sign_in_with_apple',
          ),
        ),
      );

      print("apple credential");
      print(credential.userIdentifier);
      print(credential.givenName);
      print(credential.familyName);
      print(credential.email);
      print("Credentials Reached");
      var firstName = credential.givenName;
      var lastName = credential.familyName;
      var email = credential.email;
      var userDp = "";
      var gender = "";
      var dob = "";
      var mobile = "";
      var country = "";
      if (iosUuId == "") {
//                          print(userInfo);
        if (Platform.isIOS) {
          String uuid;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          uuid = credential.userIdentifier; //UUID for iOS
          print("uuid $uuid");
          final Map<String, String> userInfo = {
            'first_name': firstName != null ? firstName : "",
            'last_name': lastName != null ? lastName : "",
            'email': email != null ? email : "",
            'mobile': mobile != null ? mobile : "",
            'gender': gender != null ? gender : "",
            'user_dp': userDp != null ? userDp : "",
            'dob': dob != null ? dob : "",
            'country': country != null ? country : "",
            'languages': "",
            'player_id': "",
            'time_zone': timezone,
            'login_type': "A",
            'ios_email': email,
            'ios_uuid': uuid,
          };
//          final SharedPreferences prefUuId = await SharedPreferences.getInstance();
//          prefUuId.setString("ios_uuid", uuid);
//          prefUuId.setString("ios_email", email);
          userRepo
              .socialLogin(
            userInfo,
            timezone,
            'A',
          )
              .then((value) {
            if (value != null) {
              if (value) {
                connectUserSocket();
                Helper.hideLoader(loader);
                videoRepo.homeCon.value.showFollowingPage.value = false;
                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
                videoRepo.homeCon.value.getVideos();
              } else {
                // userRepo.errorString.addListener(() {
                if (userRepo.errorString.value == "") {
                  Helper.hideLoader(loader);

                  Navigator.push(
                    userScaffoldKey?.currentContext,
                    MaterialPageRoute(
                      builder: (context) => CompleteProfileView(
                        loginType: "A",
                      ),
                    ),
                  );
                } else {
                  Helper.hideLoader(loader);
                  userScaffoldKey?.currentState?.showSnackBar(SnackBar(
                    content: Text(userRepo.errorString.value),
                  ));
                }
//                });
              }
            }
          }).catchError((e) {
            print(e.toString());
            Helper.hideLoader(loader);
            userScaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text("Sign In with Apple failed!"),
            ));
          });
        }
      } else {
        print("abccd");
        final Map<String, String> userInfo = {
          'first_name': firstName != null ? firstName : "",
          'last_name': lastName != null ? lastName : "",
          'email': email != null ? email : "",
          'mobile': mobile != null ? mobile : "",
          'gender': gender != null ? gender : "",
          'user_dp': userDp != null ? userDp : "",
          'dob': dob != null ? dob : "",
          'country': country != null ? country : "",
          'languages': "",
          'player_id': "",
          'time_zone': timezone,
          'login_type': "A",
          'ios_uuid': iosUuId,
          'ios_email': iosEmail,
        };
        userRepo
            .socialLogin(
          userInfo,
          timezone,
          'A',
        )
            .then((value) {
          if (value != null) {
            if (value) {
              connectUserSocket();
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
              videoRepo.homeCon.value.getVideos();
            } else {
              // userRepo.errorString.addListener(() {
              if (userRepo.errorString.value == "") {
                Helper.hideLoader(loader);

                Navigator.push(
                  userScaffoldKey?.currentContext,
                  MaterialPageRoute(
                    builder: (context) => CompleteProfileView(
                      loginType: "A",
                    ),
                  ),
                );
              } else {
                Helper.hideLoader(loader);
                userScaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text(userRepo.errorString.value),
                ));
              }
//              });
            }
          }
        }).catchError((e) {
          print(e.toString());
          Helper.hideLoader(loader);
          userScaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Sign In with Apple failed!"),
          ));
        });
      }

      print("Session Reached");
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      setState(() {
        showLoader = false;
      });
      if (e.toString().contains("Unsupported platform")) {
        userScaffoldKey?.currentState?.showSnackBar(
          Helper.toast("Unsupported platform iOS version. Please try some other login method.", Colors.redAccent),
        );
      } else {
        userScaffoldKey?.currentState?.showSnackBar(
          Helper.toast(
            e.toString() + " Please try Again with some other method.",
            Colors.redAccent,
          ),
        );
      }
    }
  }

  loginWithFB() async {
    final FacebookLoginResult result = await facebookSignIn.logIn([
      'email',
    ]);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        OverlayEntry loader = Helper.overlayLoader(userScaffoldKey?.currentContext);
        Overlay.of(userScaffoldKey?.currentContext).insert(loader);
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(720).height(720),birthday,gender,languages,location{location}&access_token=${accessToken.token}'));
        final profile = jsonDecode(graphResponse.body);

        print("profile");
        String userEmailId = json.decode(json.encode(profile))['email'];
        // if (userEmailId != '') {
        userRepo.socialLogin(profile, timezone, 'FB').then((value) async {
          if (value != null) {
            if (value) {
              connectUserSocket();
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
              videoRepo.homeCon.value.getVideos();
            } else {
              // userRepo.errorString.addListener(() {
              if (userRepo.errorString.value == "") {
                Helper.hideLoader(loader);

                Navigator.push(
                  userScaffoldKey?.currentContext,
                  MaterialPageRoute(
                    builder: (context) => CompleteProfileView(
                      loginType: "FB",
                    ),
                  ),
                );
              } else {
                Helper.hideLoader(loader);
                userScaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text(userRepo.errorString.value),
                ));
              }
//                });
            }
          }
        }).catchError((e) {
          print(e);
          Helper.hideLoader(loader);
          userScaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Facebook login failed!"),
          ));
        });
        /*} else {
          Helper.hideLoader(loader);
          userScaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Facebook login failed as your email field is empty!"),
          ));
        }*/
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
  }

  loginWithGoogle() async {
    await googleSignIn.signIn();
    OverlayEntry loader = Helper.overlayLoader(userScaffoldKey?.currentContext);
    Overlay.of(userScaffoldKey?.currentContext).insert(loader);

    if (googleSignIn.currentUser != null) {
      print("googleSignIn");
      print(googleSignIn);
      await getGoogleInfo(googleSignIn).then((profile) {
        userRepo.socialLogin(profile, timezone, 'G').then((value) {
          if (value != null) {
            if (value) {
              connectUserSocket();
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
              videoRepo.homeCon.value.getVideos();
            } else {
              Helper.hideLoader(loader);
              print("Entered else");
              print(userRepo.errorString.value);
//              // userRepo.errorString.addListener(() {
              print("Entered else listener");
              if (userRepo.errorString.value == "") {
                Helper.hideLoader(loader);

                Navigator.push(
                  userScaffoldKey?.currentContext,
                  MaterialPageRoute(
                    builder: (context) => CompleteProfileView(
                      loginType: "G",
                    ),
                  ),
                );
              } else {
                print("Entered else else");
                Helper.hideLoader(loader);
                userScaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text(userRepo.errorString.value),
                ));
              }
//              });
            }
          }
        }).catchError((e) {
          Helper.hideLoader(loader);
          userScaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Google login failed!"),
          ));
        });
      });
    } else {
      Helper.hideLoader(loader);
    }
  }

  Future getGoogleInfo(googleSignIn) async {
    List name = googleSignIn.currentUser.displayName.split(' ');
    // final headers = await googleSignIn.currentUser.authHeaders;
    // final r = await http.get("https://people.googleapis.com/v1/people/me?personFields=birthdays,genders,phoneNumbers,", headers: {"Authorization": headers["Authorization"]});
    // final response = jsonDecode(r.body);
    // print("aaaasasa");
    // print(response);
    // var gender = response['genders'][0]['value'] == "male" ? "M" : (response['genders'][0]['value'] == "female" ? "F" : "O");
    // String dob = response['birthdays'][0]['date']['year'] != null
    //     ? response['birthdays'][0]['date']['year'].toString()
    //     : response['birthdays'][1]['date']['year'].toString() + '-' + response['birthdays'][0]['date']['month'].toString() != null
    //         ? response['birthdays'][0]['date']['month'].toString()
    //         : response['birthdays'][1]['date']['month'].toString() + '-' + response['birthdays'][0]['date']['day'].toString() != null
    //             ? response['birthdays'][0]['date']['day'].toString()
    //             : response['birthdays'][1]['date']['day'].toString();

    final Map<String, String> userInfo = {
      'first_name': name[0],
      'last_name': name[name.length - 1],
      'email': googleSignIn.currentUser.email,
      'user_dp': googleSignIn.currentUser.photoUrl != null ? googleSignIn.currentUser.photoUrl.replaceAll('=s96-c', '=s512-c') : "",
      // 'gender': gender != null ? gender : "",
      // 'birthday': dob != null ? dob : "",
      'time_zone': timezone,
      'login_type': "G",
    };
    return userInfo;
  }

  Future<Video> getUsers(page) {
    followCon = FollowingController();
    setState(() {});
    showLoader = true;
    scrollController1 = new ScrollController();
    userRepo.getUsers(page, searchKeyword).then((value) {
      showLoader = false;
      print("value");
      print(value);
      if (value.videos.length == value.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (value.videos.length != value.totalVideos && showLoadMore) {
            page = page + 1;
            getUsers(page);
          }
        }
      });
    });
  }

  Future<void> followUnfollowUser(userId, index) async {
    setState(() {
      followUserId = userId;
    });
    showLoader = true;

    userRepo.followUnfollowUser(userId).then((value) {
      showLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
        followCon.friendsList(1);
        setState(() {
          userRepo.usersData.value.videos.elementAt(index).followText = response['followText'];
          userRepo.usersData.notifyListeners();
        });
      }
    }).catchError((e) {
      print("AAAAAA");
      print(e);
      showLoader = false;
      userScaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  Future<void> followUnfollowUserFromUserProfile(userId) async {
    setState(() {});
    followUnfollowLoader = true;
    userRepo.followUnfollowUser(userId).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      print(response);
      if (response['status'] == 'success') {
        videoRepo.homeCon.value.loadMoreUpdateView.value = true;
        videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
        // getFollowingUserVideos();
        for (var item in videoRepo.videosData.value.videos) {
          if (userId == item.userId) {
            item.isFollowing = response['followText'] == 'Follow' ? 0 : 1;
          }
        }
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
        userRepo.userProfile.value.followText = response['followText'];
        userRepo.userProfile.value.totalFollowers = response['totalFollowers'].toString();
        userRepo.userProfile.notifyListeners();
      }
    }).catchError((e) {
      showLoader = false;
      userScaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  Future<UserProfileModel> getUsersProfile(userId, page) {
    homeCon = videoRepo.homeCon.value;
    showLoader = true;
    scrollController1 = new ScrollController();
    userRepo.getUserProfile(userId, page).then((userValue) {
      showLoader = false;
      if (userValue.userVideos.length == userValue.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (userValue.userVideos.length != userValue.totalVideos && showLoadMore) {
            page = page + 1;
            getUsersProfile(userId, page);
          }
        }
      });
    });
  }

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<UserProfileModel> getMyProfile(page) {
    homeCon = videoRepo.homeCon.value;
    showLoader = true;
    scrollController1 = new ScrollController();
    userRepo.getMyProfile(page).then((userValue) {
      showLoader = false;
      print(userValue);
      if (userValue.userVideos.length == userValue.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (userValue.userVideos.length != userValue.totalVideos && showLoadMore) {
            page = page + 1;
            getMyProfile(page);
          }
        }
      });
    });
  }

  Future<void> refreshUserProfile() async {
    if (userIdValue.value > 0) {
      print(userIdValue.value);
      await getUsersProfile(userIdValue.value, 1);
    }
    return Future.value();
  }

  Future<void> refreshMyProfile() async {
    await getMyProfile(1);
    return Future.value();
  }

  blockUser(userId) async {
    homeCon = videoRepo.homeCon.value;
    showLoader = true;
    userRepo.blockUser(userId).then((value) async {
      showLoader = false;
      videoRepo.homeCon.value.showFollowingPage.value = false;
      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
      Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
      videoRepo.homeCon.value.getVideos();
      var response = json.decode(value);
      if (response['status'] == 'success') {
        print(response);
        userRepo.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userRepo.userProfile.notifyListeners();
        userScaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(response['msg']),
        ));
        videoRepo.homeCon.value.getVideos().whenComplete(() {
          videoRepo.homeCon.notifyListeners();
          Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
        });
      } else {
        userScaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There are some error"),
        ));
      }
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Wrap(
      children: [
        Align(
            alignment: Alignment.center,
            child: Text(
              "Loading...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'RockWellStd',
              ),
            )),
      ],
    ));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  connectUserSocket() async {
    print("connectUserSocket");
    try {
      socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socketRepo.clientSocket.value = socket;
      socketRepo.clientSocket.notifyListeners();
      socket.emit("user-id", userRepo.currentUser.value.userId);
    } catch (e) {
      print("catch socket");
      print(e.toString());
    }
  }

  String validateField(String value, String field) {
    Pattern pattern = r'^[0-9A-Za-z.\-_]*$';
    RegExp regex = new RegExp(pattern);

    if (value.length == 0) {
      return "$field is required!";
    } else if (field == "Confirm Password" && value != password) {
      return "Confirm Password doesn't match!";
    } else if (field == "Username" && !regex.hasMatch(value)) {
      return "It must contain only _ . and alphanumeric";
    } else {
      return null;
    }
  }

  String validateEmail(String value) {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value);
    if (value.length == 0) {
      return "Email field is required!";
    } else if (!emailValid) {
      return "Email field is not valid!";
    } else {
      return null;
    }
  }

  Future<bool> register() async {
    if (completeProfileFormKey.currentState.validate()) {
      completeProfileFormKey.currentState.save();
      setState(() {
        showLoader = true;
      });

      List name = fullName.split(' ');
      final Map<String, String> userProfile = {
        'fname': name[0],
        'lname': name[name.length - 1],
        'email': email,
        'password': password,
        'username': userName,
        'time_zone': timezone,
        'login_type': "O",
        'profile_pic_file': selectedDp != null ? selectedDp.path ?? "" : "",
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userRepo.register(userProfile).then((value) async {
        setState(() {
          showLoader = false;
        });
        if (value != null) {
          print("Register Response");
          print(value);
          showLoader = false;
          var response = json.decode(value);
          if (response['status'] != 'success') {
            String msg = response['msg'];
            print("msg");
            print(msg);
            showAlertDialog("Error Registering User", msg, completeProfileScaffoldKey.currentContext);
            return Future.value(false);
          } else {
            var content = json.decode(json.encode(response['content']));
            print("content");
            print(content);
            prefs.setString("otp_user_id", content['user_id'].toString());
            prefs.setString("otp_app_token", content['app_token']);
            Navigator.push(
              completeProfileFormKey.currentContext,
              MaterialPageRoute(
                builder: (context) => VerifyOTPView(),
              ),
            );
            return Future.value(true);
          }
        }
      });
    } else {
      return Future.value(false);
    }
  }

  Future<bool> registerSocial() async {
    print("registerSocial");

    if (completeProfileFormKey.currentState.validate()) {
      completeProfileFormKey.currentState.save();
      setState(() {
        showLoader = true;
      });
      List name = completeProfile.name.split(' ');
      final Map<String, String> userProfile = {
        'fname': name[0],
        'lname': name[name.length - 1],
        'email': completeProfile.email == '' || completeProfile.email == null ? email : completeProfile.email,
        'password': password,
        'confirm_password': confirmPassword,
        'username': userName,
        'gender': selectedGender,
        'time_zone': timezone,
        'login_type': loginType,
        'profile_pic': completeProfile.userDP,
      };
      if (selectedDp != null) {
        userProfile['profile_pic_file'] = selectedDp.path;
      } else {
        userProfile['profile_pic'] = completeProfile.userDP;
      }
      print("userProfile");
      print(userProfile);
      userRepo.socialRegister(userProfile).then((value) async {
        setState(() {
          showLoader = false;
        });
        print("socialRegister value");
        print(value);
        if (value != null) {
          print("Register Response");
          print(value);
          showLoader = false;
          var response = json.decode(value);
          if (response['status'] != 'success') {
            String msg = response['msg'];
            print("msg");
            print(msg);
            showAlertDialog("Error Registering User", msg, completeProfileScaffoldKey.currentContext);
            return Future.value(false);
          } else {
            print("response.body");
            print(value);
            userRepo.setCurrentUser(value);
            userRepo.currentUser.value = LoginData.fromJson(json.decode(value)['content']);
            userRepo.currentUser.value.auth = true;
            userRepo.currentUser.notifyListeners();
            connectUserSocket();
            videoRepo.homeCon.value.showFollowingPage.value = false;
            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
            Navigator.of(completeProfileScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
            videoRepo.homeCon.value.getVideos();
          }
        }
      });
    } else {
      return Future.value(false);
    }
  }

  Future<bool> login() async {
    if (registerFormKey.currentState.validate()) {
      registerFormKey.currentState.save();
      setState(() {
        showLoader = true;
      });

      final Map<String, String> userProfile = {
        'email': email,
        'password': password,
        'time_zone': timezone,
        'login_type': "O",
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userRepo.login(userProfile).then((value) async {
        setState(() {
          showLoader = false;
        });
        if (value != null) {
          var resp = json.encode(json.decode(value));
          print("Login Response");
          print(value);
          showLoader = false;
          var response = json.decode(resp);
          if (response['status'] != 'success') {
            if (response['status'] == 'email_not_verified') {
              print("Abcvcd");
              setState(() {
                showSendOtp = true;
              });
              var content = json.decode(json.encode(response['content']));
              print("content");
              print(content);
              prefs.setString("otp_user_id", content['user_id'].toString());
              prefs.setString("otp_app_token", content['app_token']);
            }
            String msg = response['msg'];
            print("msg");
            print(msg);
            showAlertDialog("Error Logging in", msg, userScaffoldKey.currentContext);
            return Future.value(false);
          } else {
            var content = json.decode(json.encode(response['content']));
            print("content");
            print(content);
            userRepo.setCurrentUser(value);
            userRepo.currentUser.value = LoginData.fromJson(response['content']);
            userRepo.currentUser.value.auth = true;
            userRepo.currentUser.notifyListeners();
            connectUserSocket();
            videoRepo.homeCon.value.showFollowingPage.value = false;
            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
            Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
            videoRepo.homeCon.value.getVideos();
          }
        }
      });
    } else {
      return Future.value(false);
    }
  }

  verifyOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("otp_user_id");
    String userToken = prefs.getString("otp_app_token");
    print("verifyOtp  $userId $userToken");
    setState(() {
      showLoader = true;
    });
    if (otpFormKey.currentState.validate()) {
      otpFormKey.currentState.save();
      final Map<String, String> data = {
        'user_id': userId,
        'app_token': userToken,
        'otp': otp,
      };
      userRepo.verifyOtp(data).then((value) async {
        setState(() {
          showLoader = false;
        });
        print("Verify otp Response");
        print(value);
        showLoader = false;
        var resp = json.encode(json.decode(value));
        print("Login Response");
        print(value);
        showLoader = false;
        var response = json.decode(resp);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          print("msg");
          print(msg);
          /*setState(() {
            showSendOtp = true;
          });*/
          showAlertDialog(
            'Error Verifying OTP',
            msg,
            otpScaffoldKey.currentContext,
          );
        } else {
          /* if (videoRepo.homeCon.value.showFollowingPage.value) {
            await videoRepo.homeCon.value
                .initializeFollowingVideos()
                .whenComplete(() {
              videoRepo.homeCon.notifyListeners();
              videoRepo.dataLoaded.value = true;
              videoRepo.dataLoaded.notifyListeners();
              Navigator.of(userScaffoldKey?.currentContext)
                  .pushReplacementNamed('/redirect-page',
                      arguments: videoRepo.homeCon.value);
            });
          } else {*/
          userRepo.setCurrentUser(value);
          userRepo.currentUser.value = LoginData.fromJson(response['content']);
          userRepo.currentUser.notifyListeners();
          connectUserSocket();
          videoRepo.homeCon.value.showFollowingPage.value = false;
          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
          Navigator.of(otpScaffoldKey?.currentContext).pushReplacementNamed('/redirect-page', arguments: 0);
          videoRepo.homeCon.value.getVideos();

          // }
        }
      });
    }
  }

  resendOtp({verifyPage}) async {
    print("{verifyPage} ");
    print(verifyPage);
    if (verifyPage != null) {
      startTimer();
      setState(() {
        bHideTimer = true;
        countTimer = 60;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("otp_user_id");
    String userToken = prefs.getString("otp_app_token");
    print("resendOtp  $userId $userToken");
    setState(() {
      showLoader = true;
    });

    final Map<String, String> data = {
      'user_id': userId,
      'app_token': userToken,
    };
    userRepo.resendOtp(data).then((value) async {
      setState(() {
        showLoader = false;
      });
      print("Verify otp Response");
      print(value);
      showLoader = false;
      var response = json.decode(value);
      if (response['status'] != 'success') {
        String msg = response['msg'];
        print("msg");
        print(msg);
        setState(() {
          showSendOtp = true;
        });
        showAlertDialog(
          'Error Verifying OTP',
          msg,
          otpScaffoldKey.currentContext,
        );
      } else {
        if (verifyPage == null) {
          Navigator.of(userScaffoldKey?.currentContext).pushReplacementNamed(
            '/verify-otp-screen',
          );
        }
      }
    });
  }

  showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  showAlertDialog(errorTitle, errorString, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          height: 200,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: AlertDialog(
            title: Center(
              child: Text(
                errorTitle,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'RockWellStd',
                ),
              ),
            ),
            insetPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/warning.jpg",
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    errorString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                showSendOtp
                    ? GestureDetector(
                        onTap: () {
                          showLoaderSpinner();
                          Navigator.pop(context);
                          setState(() {
                            showSendOtp = false;
                          });
                          context == otpScaffoldKey.currentContext ?? Navigator.pop(otpScaffoldKey.currentContext);
                          context == otpScaffoldKey.currentContext ? resendOtp(verifyPage: true) : resendOtp();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 20.0,
                          ),
                          child: Container(
                            height: 25,
                            width: 100,
                            decoration: BoxDecoration(gradient: Gradients.blush),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    "Resend OTP",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      fontFamily: 'RockWellStd',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                /*Center(
                  child: FlatButton(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 45,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: Gradients.blush,
                      ),
                      child: Center(
                        child: Text(
                          "Exit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            fontFamily: 'RockWellStd',
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),
                ),*/
                Center(
                  child: FlatButton(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 45,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: Gradients.blush,
                      ),
                      child: Center(
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            fontFamily: 'RockWellStd',
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  startTimer() {
    Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        countTimer--;
        print(countTimer);
        if (countTimer == 0) {
          bHideTimer = false;
          print("bHideTimer $bHideTimer");
        }
        if (countTimer <= 0) timer.cancel();
      });
    });
  }

  // login page data
  getLoginPageData() {
    showLoader = true;
    loginRepo.fetchLoginPageInfo().then((value) {
      // setState(() {
      showLoader = false;
      // });
    });
  }

  Future<bool> ifEmailExists(String email) {
    setState(() {
      showLoader = true;
    });
    userRepo.ifEmailExists(email).then((value) {
      if (value != null) {
        setState(() {
          showLoader = false;
        });
        if (value == true) {
          showAlertDialog(
            'Email Already Exists',
            'Use another email to register or login using existing email.',
            userScaffoldKey.currentContext,
          );
          return false;
        } else {
          print("email true");
          Navigator.push(
            userScaffoldKey.currentContext,
            MaterialPageRoute(
              builder: (context) => CompleteProfileView(
                loginType: "O",
                email: email,
                fullName: fullName,
              ),
            ),
          );

          return true;
        }
      }
    });
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          selectedDp = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      setState(() {
        if (pickedFile != null) {
          selectedDp = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
    print("Picked Image");
    print(selectedDp);
  }

  sendPasswordResetOTP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("sendPasswordResetOTP  $email");
    setState(() {
      showLoader = true;
    });
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      final Map<String, String> data = {
        'email': email,
      };
      userRepo.forgotPassword(data).then((value) async {
        setState(() {
          showLoader = false;
        });
        print("Verify otp Response");
        print(value);
        showLoader = false;
        var resp = json.encode(json.decode(value));
        print("Login Response");
        print(value);
        showLoader = false;
        var response = json.decode(resp);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          print("msg");
          print(msg);
          /*setState(() {
            showSendOtp = true;
          });*/
          showAlertDialog(
            'Account Not Found',
            msg,
            forgotPasswordScaffoldKey.currentContext,
          );
        } else {
          FocusScope.of(forgotPasswordScaffoldKey.currentContext).requestFocus(FocusNode());
          forgotPasswordScaffoldKey?.currentState?.showSnackBar(
            SnackBar(
              content: Text("An OTP is sent to your email please check your email."),
            ),
          );
          await Future.delayed(
            Duration(seconds: 2),
          );
          Navigator.of(forgotPasswordScaffoldKey?.currentContext).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResetForgotPasswordView(
                email: email,
              ),
            ),
          );

          // }
        }
      });
    }
  }

  updateForgotPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("updateForgotPassword  $email");
    setState(() {
      showLoader = true;
    });
    if (resetForgotPassword.currentState.validate()) {
      resetForgotPassword.currentState.save();
      final Map<String, String> data = {
        'email': email,
        'otp': otp,
        'password': password,
        'confirm_password': confirmPassword,
      };
      userRepo.updateForgotPassword(data).then((value) async {
        setState(() {
          showLoader = false;
        });
        print("Verify otp Response");
        print(value);
        showLoader = false;
        var resp = json.encode(json.decode(value));
        print("Login Response");
        print(value);
        showLoader = false;
        var response = json.decode(resp);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          print("msg");
          print(msg);
          /*setState(() {
            showSendOtp = true;
          });*/
          showAlertDialog(
            'Error Resetting Password',
            msg,
            resetForgotPasswordScaffoldKey.currentContext,
          );
        } else {
          FocusScope.of(resetForgotPasswordScaffoldKey.currentContext).requestFocus(FocusNode());
          resetForgotPasswordScaffoldKey?.currentState?.showSnackBar(
            SnackBar(
              content: Text("Password updated Successfully"),
            ),
          );
          await Future.delayed(
            Duration(seconds: 2),
          );
          Navigator.of(resetForgotPasswordScaffoldKey?.currentContext).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PasswordLoginView(),
            ),
          );
        }
      });
    }
  }

  deleteVideo(videoId) async {
    videoRepo.deleteVideo(videoId).then((value) async {
      if (value != null) {
        setState(() {
          showLoader = false;
        });
        print("delete Video Response");
        print(value);
        showLoader = false;
        var response = json.decode(value);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          print("msg");
          print(msg);
          myProfileScaffoldKey?.currentState?.showSnackBar(
            SnackBar(
              content: Text("Video deleted Successfully"),
            ),
          );
        } else {
          myProfileScaffoldKey?.currentState?.showSnackBar(
            SnackBar(
              content: Text("There's some error deleting video"),
            ),
          );
        }
      }
    });
  }

  showDeleteAlert(errorTitle, errorString, videoId) {
    showDialog(
      context: myProfileScaffoldKey.currentContext,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          height: 200,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: AlertDialog(
            title: Center(
              child: Text(
                errorTitle,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'RockWellStd',
                ),
              ),
            ),
            insetPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/warning.jpg",
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    errorString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                      decoration: BoxDecoration(
                        //color: Color(0xff2e2f34),
                        borderRadius: BorderRadius.all(new Radius.circular(32.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                deleteVideo(videoId);
                                Navigator.of(context, rootNavigator: true).pop("Discard");
                              },
                              child: Container(
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                  gradient: Gradients.blush,
                                  borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                                ),
                                child: Center(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RockWellStd'),
                                  ),
                                ),
                              )),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop("Discard");
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: Gradients.blush,
                                borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                              ),
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'RockWellStd',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void editVideo(videoId, videoDescription, privacy) {
    setState(() {
      showLoader = true;
    });
    videoRepo.editVideo(videoId, videoDescription, privacy).then((value) async {
      if (value != null) {
        setState(() {
          showLoader = false;
        });
        if (value == "Yes") {
          editVideoScaffoldKey?.currentState?.showSnackBar(
            SnackBar(
              content: Text("Video Updated Successfully"),
            ),
          );
          await Future.delayed(
            Duration(seconds: 1),
          );
          Navigator.of(editVideoScaffoldKey?.currentContext).pop();
        }
      }
    });
  }

  String validateDescription(String value) {
    if (value.length == 0) {
      return "Description is required!";
    } else {
      return null;
    }
  }
}
