import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/hash_videos_model.dart';
import '../models/videos_model.dart';
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class HashVideosController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<ScaffoldState> hashScaffoldKey;
  GlobalKey<FormState> formKey;
  PanelController pc = new PanelController();
  ScrollController scrollController;
  ScrollController hashScrollController;
  ScrollController videoScrollController;
  ScrollController userScrollController;
  bool showLoader = false;
  bool showLoadMore = true;
  bool showLoadMoreHashTags = true;
  bool showLoadMoreUsers = true;
  bool showLoadMoreVideos = true;
  String searchKeyword = '';
  DashboardController homeCon;
  var searchController = TextEditingController();

  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  int hashesPage = 2;
  int videosPage = 2;
  int usersPage = 2;
  ValueNotifier<bool> showBannerAd = new ValueNotifier(false);
  InterstitialAd _interstitialAd;
  RewardedAd myRewarded;
  HashVideosController() {}

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    hashScaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    super.initState();
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
        if (bannerShowOn.indexOf("3") > -1) {
          showBannerAd.value = true;
          showBannerAd.notifyListeners();
          // createBannerAd(bannerUnitId);
        }

        if (interstitialShowOn.indexOf("3") > -1) {
          // _interstitialAd?.dispose();
          createInterstitialAd(screenUnitId);
        }

        if (videoShowOn.indexOf("3") > -1) {
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

  Future<HashVideosModel> getData(page) {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    setState(() {
      showLoadMoreHashTags = true;
      showLoadMoreUsers = true;
      showLoadMoreVideos = true;
      hashesPage = 2;
      usersPage = 2;
      videosPage = 2;
    });
    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getData(page, searchKeyword).then((value) {
      showLoader = false;
      if (value.videos.length == value.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (value.videos.length != value.totalRecords && showLoadMore) {
            page = page + 1;
            getData(page);
          }
        }
      });
    });
  }

  Future<HashVideosModel> getHashData(page, hash) {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getHashData(page, hash).then((value) {
      if (value != null) {
        showLoader = false;
        if (value.videos.length == value.totalRecords) {
          showLoadMore = false;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if (value.videos.length != value.totalRecords && showLoadMore) {
              page = page + 1;
              getHashData(page, hash);
            }
          }
        });
      }
    });
  }

  Future<HashVideosModel> getHashesData(searchKeyword) {
    print("getHashesData $hashesPage $showLoadMoreHashTags");
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      hashScrollController = new ScrollController();
      hashRepo.getHashesData(hashesPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          print("value.length");
          print(value.length);
          if (value.length == 0) {
            showLoadMoreHashTags = false;
          }
          /*hashScrollController.addListener(() {
            if (hashScrollController.position.pixels == hashScrollController.position.maxScrollExtent - 100) {
              print("Scrolls Hash 1");
              print(hashScrollController.position.pixels + hashScrollController.position.maxScrollExtent);
              if (showLoadMoreHashTags) {
                getHashesData(searchKeyword);
                setState(() {
                  hashesPage++;
                });
              }
            }
          });*/
        }
      });
    }
  }

  Future<List<Video>> getUsersData(searchKeyword) {
    print("getUsersData $usersPage $showLoadMoreUsers");
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      userScrollController = new ScrollController();
      hashRepo.getUsersData(usersPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          if (value.length == 0) {
            showLoadMoreUsers = false;
          }
          /*userScrollController.addListener(() {
            if (userScrollController.position.pixels == userScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreUsers) {
                usersPage++;
                getHashData(usersPage, searchKeyword);
              }
            }
          });*/
        }
      });
    }
  }

  Future<List<Videos>> getVideosData(searchKeyword) {
    print("getVideosData $videosPage $showLoadMoreVideos");
    if (showLoadMoreVideos) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      videoScrollController = new ScrollController();
      hashRepo.getVideosData(videosPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          if (value.length > 0) {
            showLoadMoreVideos = false;
          }
          /*videoScrollController.addListener(() {
            if (videoScrollController.position.pixels == videoScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreVideos) {
                videosPage++;
                getHashData(videosPage, searchKeyword);
              }
            }
          });*/
        }
      });
    }
  }

  Future<HashVideosModel> getSearchData(page) {
    print("getSearchData");
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();

    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getSearchData(page, searchKeyword).then((value) {
      if (value != null) {
        showLoader = false;
        if (value.hashTags.length < 10) {
          print("Hash 10");
          print(value.hashTags.length);
          setState(() {
            showLoadMoreHashTags = false;
          });
        } else {
          print("Hash 11");
          print(value.hashTags.length);
          hashScrollController = new ScrollController();
          hashScrollController.addListener(() {
            print("Scrolls Hash  1");
            print("${hashScrollController.position.pixels} + ${hashScrollController.position.maxScrollExtent}");
            if (hashScrollController.position.pixels >= hashScrollController.position.maxScrollExtent - 100) {
              print("Scrolls Hash 2");
              print("${hashScrollController.position.pixels} + ${hashScrollController.position.maxScrollExtent - 100}");
              print("showLoadMoreHashTags");
              print(showLoadMoreHashTags);
              if (showLoadMoreHashTags) {
                getHashesData(searchKeyword);
                setState(() {
                  hashesPage++;
                });
              }
            }
          });
        }
        if (value.users.length < 10) {
          setState(() {
            showLoadMoreUsers = false;
          });
        } else {
          userScrollController = new ScrollController();
          userScrollController.addListener(() {
            if (userScrollController.position.pixels >= userScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreUsers) {
                getUsersData(searchKeyword);
                setState(() {
                  usersPage++;
                });
              }
            }
          });
        }
        if (value.videos.length < 10) {
          setState(() {
            showLoadMoreVideos = false;
          });
        } else {
          videoScrollController = new ScrollController();
          videoScrollController.addListener(() {
            if (videoScrollController.position.pixels >= videoScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreVideos) {
                getVideosData(searchKeyword);
                setState(() {
                  videosPage++;
                });
              }
            }
          });
        }
      }
    });
  }
}
