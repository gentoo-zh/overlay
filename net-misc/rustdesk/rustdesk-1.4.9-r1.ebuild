# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

declare -A GIT_CRATES=(
	[android-wakelock]='https://github.com/rustdesk-org/android-wakelock;d0292e5a367e627c4fa6f1ca6bdfad005dca7d90;android-wakelock-%commit%'
	[arboard]='https://github.com/rustdesk-org/arboard;c7d5781f563176df9efd8df6287e823fb1b9bed5;arboard-%commit%'
	[cacao]='https://github.com/clslaid/cacao;05e1536b0b43aaae308ec72c0eed703e875b7b95;cacao-%commit%'
	[cidre-macros]='https://github.com/yury/cidre;f05c4288f9870c9fab53272ddafd6ec01c7b2dbf;cidre-%commit%/cidre-macros'
	[cidre]='https://github.com/yury/cidre;f05c4288f9870c9fab53272ddafd6ec01c7b2dbf;cidre-%commit%/cidre'
	[clipboard-master]='https://github.com/rustdesk-org/clipboard-master;7762d74e38db37cfeb6ded88c964b9cdbddfb6db;clipboard-master-%commit%'
	[confy]='https://github.com/rustdesk-org/confy;83db9ec19a2f97e9718aef69e4fc5611bb382479;confy-%commit%'
	[core-foundation-sys]='https://github.com/madsmtm/core-foundation-rs;7d593d016175755e492a92ef89edca68ac3bd5cd;core-foundation-rs-%commit%/core-foundation-sys'
	[core-foundation]='https://github.com/madsmtm/core-foundation-rs;7d593d016175755e492a92ef89edca68ac3bd5cd;core-foundation-rs-%commit%/core-foundation'
	[core-graphics-types]='https://github.com/madsmtm/core-foundation-rs;7d593d016175755e492a92ef89edca68ac3bd5cd;core-foundation-rs-%commit%/core-graphics-types'
	[core-graphics]='https://github.com/madsmtm/core-foundation-rs;7d593d016175755e492a92ef89edca68ac3bd5cd;core-foundation-rs-%commit%/core-graphics'
	[cpal]='https://github.com/rustdesk-org/cpal;6b374bcaed076750ca8fce6da518ab39b882e14a;cpal-%commit%'
	[default_net]='https://github.com/rustdesk-org/default_net;78f8f70cd85151a3a2c4a3230d80d5272703c02e;default_net-%commit%'
	[evdev]='https://github.com/rustdesk-org/evdev;cec616e37790293d2cd2aa54a96601ed6b1b35a9;evdev-%commit%'
	[filedescriptor]='https://github.com/rustdesk-org/wezterm;80174f8009f41565f0fa8c66dab90d4f9211ae16;wezterm-%commit%/filedescriptor'
	[hwcodec]='https://github.com/rustdesk-org/hwcodec;778df1f99597722473b29443bac22ae6c23946fe;hwcodec-%commit%'
	[impersonate_system]='https://github.com/rustdesk-org/impersonate-system;2f429010a5a10b1fe5eceb553c6672fd53d20167;impersonate-system-%commit%'
	[kcp-sys]='https://github.com/rustdesk-org/kcp-sys;32a6c09fc6223f54aea83981a6aa8995931d29be;kcp-sys-%commit%'
	[keepawake]='https://github.com/rustdesk-org/keepawake-rs;64d568586dd16551d02120e19668d2b0fec8e3c9;keepawake-rs-%commit%'
	[machine-uid]='https://github.com/rustdesk-org/machine-uid;381ff579c1dc3a6c54db9dfec47c44bcb0246542;machine-uid-%commit%'
	[magnum-opus]='https://github.com/rustdesk-org/magnum-opus;588c6e1f9ed50c3a01fa64f3bd3e7cdb0378a114;magnum-opus-%commit%'
	[nokhwa-bindings-linux]='https://github.com/rustdesk-org/nokhwa;c2f74662b6ce117f7f94301693fdfadc0b1ec91a;nokhwa-%commit%/nokhwa-bindings-linux'
	[nokhwa-bindings-macos]='https://github.com/rustdesk-org/nokhwa;c2f74662b6ce117f7f94301693fdfadc0b1ec91a;nokhwa-%commit%/nokhwa-bindings-macos'
	[nokhwa-bindings-windows]='https://github.com/rustdesk-org/nokhwa;c2f74662b6ce117f7f94301693fdfadc0b1ec91a;nokhwa-%commit%/nokhwa-bindings-windows'
	[nokhwa-core]='https://github.com/rustdesk-org/nokhwa;c2f74662b6ce117f7f94301693fdfadc0b1ec91a;nokhwa-%commit%/nokhwa-core'
	[nokhwa]='https://github.com/rustdesk-org/nokhwa;c2f74662b6ce117f7f94301693fdfadc0b1ec91a;nokhwa-%commit%'
	[pam-sys]='https://github.com/rustdesk-org/pam-sys;3337c9bb9a9c68d7497ec8c93cad2368c26091b7;pam-sys-%commit%'
	[pam]='https://github.com/rustdesk-org/pam;7bfd25510202cd269292cbdd7c71f3977a6fd762;pam-%commit%'
	[parity-tokio-ipc]='https://github.com/rustdesk-org/parity-tokio-ipc;d0ae39bffe5d5a3e8d82a1b6bcb1ca5a9b2f1c01;parity-tokio-ipc-%commit%'
	[portable-pty]='https://github.com/rustdesk-org/wezterm;80174f8009f41565f0fa8c66dab90d4f9211ae16;wezterm-%commit%/pty'
	[rdev]='https://github.com/rustdesk-org/rdev;871bf1c856d6a30af2f56ab8848396a025140855;rdev-%commit%'
	[rust-pulsectl]='https://github.com/rustdesk-org/pulsectl;aa34dde499aa912a3abc5289cc0b547bd07dd6e2;pulsectl-%commit%'
	[sciter-rs]='https://github.com/rustdesk-org/rust-sciter;5322f3a755a0e6bf999fbc60d1efc35246c0f821;rust-sciter-%commit%'
	[sysinfo]='https://github.com/rustdesk-org/sysinfo;90b1705d909a4902dbbbdea37ee64db17841077d;sysinfo-%commit%'
	[tao-macros]='https://github.com/rustdesk-org/tao;288c219cb0527e509590c2b2d8e7072aa9feb2d3;tao-%commit%/tao-macros'
	[tao]='https://github.com/rustdesk-org/tao;288c219cb0527e509590c2b2d8e7072aa9feb2d3;tao-%commit%'
	[tfc]='https://github.com/rustdesk-org/The-Fat-Controller;78bb80a8e596e4c14ae57c8448f5fca75f91f2b0;The-Fat-Controller-%commit%'
	[tokio-socks]='https://github.com/rustdesk-org/tokio-socks;bdb9aa3de5bac41602d0742b8ef6bbc6bfebd127;tokio-socks-%commit%'
	[tray-icon]='https://github.com/tauri-apps/tray-icon;0a5835b0e6828e37a1f781de9c2d671ae7a939e6;tray-icon-%commit%'
	[wallpaper]='https://github.com/rustdesk-org/wallpaper.rs;ce4a0cd3f58327c7cc44d15a63706fb0c022bacf;wallpaper.rs-%commit%'
	[webm-sys]='https://github.com/rustdesk-org/rust-webm;d2c4d3ac133c7b0e4c0f656da710b48391981e64;rust-webm-%commit%/src/sys'
	[webm]='https://github.com/rustdesk-org/rust-webm;d2c4d3ac133c7b0e4c0f656da710b48391981e64;rust-webm-%commit%'
	[x11-clipboard]='https://github.com/clslaid/x11-clipboard;5fc2e73bc01ada3681159b34cf3ea8f0d14cd904;x11-clipboard-%commit%'
	[x11]='https://github.com/bjornsnoen/x11-rs;c2e9bfaa7b196938f8700245564d8ac5d447786a;x11-rs-%commit%/x11'
)

LLVM_COMPAT=( 18 19 20 21 22 )
# the vendored rustix 0.37 and 0.38 broke on newer rustc, so the toolchain is
# capped at the newest version this release was built with
# https://github.com/bytecodealliance/rustix/issues/1620
RUST_MAX_VER="1.96.1"
RUST_MIN_VER="1.81.0"
# pinned by flutter-version in .github/workflows/flutter-build.yml; re-check
# it on every bump
FLUTTER_PV="3.24.5"

inherit cargo desktop flutter-app systemd toolchain-funcs xdg

DESCRIPTION="An open-source remote desktop, and alternative to TeamViewer"
HOMEPAGE="https://rustdesk.com/"

# Generated by pubspec2ebuild from flutter/pubspec.lock with the gpu renderer
# plugin patch applied and then `flutter pub get` run with Flutter
# ${FLUTTER_PV}: upstream's lock leaves out flutter_test, whose SDK pins move
# nine test-only packages and add five.
PUB_HOSTED=(
	"_fe_analyzer_shared 72.0.0 f256b0c0ba6c7577c15e2e4e114755640a875e885099367bf6e012b19314c834"
	"after_layout 1.2.0 95a1cb2ca1464f44f14769329fbf15987d20ab6c88f8fc5d359bd362be625f29"
	"analyzer 6.7.0 b652861553cd3990d8ed361f7979dc6d7053a9ac8843fa73820ab68ce5410139"
	"animations 2.0.11 d3d6dcfb218225bbe68e87ccf6378bbb2e32a94900722c5f81611dad089911cb"
	"archive 3.6.1 cb6a278ef2dbb298455e1a713bda08524a175630ec643a242c399c932a0a1f7d"
	"args 2.7.0 d0481093c50b1da8910eb0bb301626d4d8eb7284aa739614d2b394ee09e3ea04"
	"async 2.11.0 947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
	"auto_size_text 3.0.0 3f5261cd3fb5f2a9ab4e2fc3fba84fd9fcaac8821f20a1d4e71f557521b22599"
	"auto_size_text_field 2.2.4 41c90b2270e38edc6ce5c02e5a17737a863e65e246bdfc94565a38f3ec399144"
	"back_button_interceptor 6.0.2 e47660f2178a4392eb72001f9594d3fdcb5efde93e59d2819d61fda499e781c8"
	"boolean_selector 2.1.1 6cfb5af12253eaf2b368f07bacc5a80d1301a071c73360d746b7f2e32d762c66"
	"bot_toast 4.1.3 6b93030a99a98335b8827ecd83021e92e885ffc61d261d3825ffdecdd17f3bdf"
	"build 2.4.1 80184af8b6cb3e5c1c4ec6d8544d27711700bc3e6d2efad04238c7b5290889f0"
	"build_cli_annotations 2.1.0 b59d2769769efd6c9ff6d4c4cede0be115a566afc591705c2040b707534b1172"
	"build_config 1.1.1 bf80fcfb46a29945b423bd9aad884590fb1dc69b330a4d4700cac476af1708d1"
	"build_daemon 4.0.2 79b2aef6ac2ed00046867ed354c88778c9c0f029df8a20fe10b5436826721ef9"
	"build_resolvers 2.4.2 339086358431fa15d7eca8b6a36e5d783728cf025e559b834f4609a1fcfb7b0a"
	"build_runner 2.4.13 028819cfb90051c6b5440c7e574d1896f8037e3c96cf17aaeb054c9311cfbf4d"
	"build_runner_core 7.3.2 f8126682b87a7282a339b871298cc12009cb67109cfa1614d6436fb0289193e0"
	"built_collection 5.1.1 376e3dd27b51ea877c28d525560790aee2e6fbb5f20e2f85d5081027d94e2100"
	"built_value 8.10.1 082001b5c3dc495d4a42f1d5789990505df20d8547d42507c29050af6933ee27"
	"cached_network_image 3.3.1 28ea9690a8207179c319965c13cd8df184d5ee721ae2ce60f398ced1219cea1f"
	"cached_network_image_platform_interface 4.0.0 9e90e78ae72caa874a323d78fa6301b3fb8fa7ea76a8f96dc5b5bf79f283bf2f"
	"cached_network_image_web 1.2.0 205d6a9f1862de34b93184f22b9d2d94586b2f05c581d546695e3d8f6a805cd7"
	"characters 1.3.0 04a925763edad70e8443c99234dc3328f442e811f1d8fd1a72f1c8ad0f69a605"
	"charcode 1.4.0 fb0f1107cac15a5ea6ef0a6ef71a807b9e4267c713bb93e00e92d737cc8dbd8a"
	"checked_yaml 2.0.3 feb6bed21949061731a7a75fc5d2aa727cf160b91af9a3e464c5e3a32e28b5ff"
	"cli_util 0.4.2 ff6785f7e9e3c38ac98b2fb035701789de90154024a75b6cb926445e83197d1c"
	"clock 1.1.1 cb6d7f03e1de671e34607e909a7213e31d7752be4fb66a86d29fe1eb14bfb5cf"
	"code_builder 4.10.1 0ec10bf4a89e4c613960bf1e8b42c64127021740fb21640c29c909826a5eea3e"
	"collection 1.18.0 ee67cb0715911d28db6bf4af1026078bd6f0128b07a5f66fb2ed94ec6783c09a"
	"contextmenu 3.0.0 e0c7d60e2fc9f316f5b03f5fe2c0f977d65125345d1a1f77eea02be612e32d0c"
	"convert 3.1.2 b30acd5944035672bc15c6b7a8b47d773e41e2f17de064350988c5d02adb1c68"
	"cross_file 0.3.4+2 7caf6a750a0c04effbb52a676dce9a4a592e10ad35c34d6d2d0e4811160d5670"
	"crypto 3.0.6 1e445881f28f22d6140f181e07737b22f1e099a5e1ff94b0af2f9e4a463f4855"
	"csslib 1.0.2 09bad715f418841f976c77db72d5398dc1253c21fb9c0c7f0b0b985860b2d58e"
	"dart_style 2.3.7 7856d364b589d1f08986e140938578ed36ed948581fbc3bc9aef1805039ac5ab"
	"dbus 0.7.11 79e0c23480ff85dc68de79e2cd6334add97e48f7f4865d17686dd6ea81a47e8c"
	"debounce_throttle 2.0.0 c95cf47afda975fc507794a52040a16756fb2f31ad3027d4e691c41862ff5692"
	"desktop_drop 0.4.4 d55a010fe46c8e8fcff4ea4b451a9ff84a162217bdb3b2a0aa1479776205e15d"
	"device_info_plus 9.1.2 77f757b789ff68e4eaf9c56d1752309bd9f7ad557cb105b938a7f8eb89e59110"
	"device_info_plus_platform_interface 7.0.2 0b04e02b30791224b31969eb1b50d723498f402971bff3630bca2ba839bd1ed2"
	"draggable_float_widget 0.1.0 075675c56f6b2bfc9f972a3937dc1b59838489a312f75fe7e90ba6844a84dce4"
	"dropdown_button2 2.3.9 b0fe8d49a030315e9eef6c7ac84ca964250155a6224d491c1365061bc974a9e1"
	"equatable 2.0.7 567c64b3cb4cf82397aac55f4f0cbd3ca20d77c6c03bedbc4ceaddc08904aef7"
	"extended_text 14.0.0 38c1cac571d6eaf406f4b80040c1f88561e7617ad90795aac6a1be0a8d0bb676"
	"extended_text_library 12.0.1 13d99f8a10ead472d5e2cf4770d3d047203fe5054b152e9eb5dc692a71befbba"
	"external_path 1.0.3 2095c626fbbefe70d5a4afc9b1137172a68ee2c276e51c3c1283394485bea8f4"
	"fake_async 1.3.1 511392330127add0b769b75a987850d136345d9227c6b94c96a04cf4a391bf78"
	"ffi 2.1.3 16ed7b077ef01ad6170a3d0c57caa4a112a38d7a2ed5602e0aca9ca6f3d98da6"
	"ffigen 8.0.2 d3e76c2ad48a4e7f93a29a162006f00eba46ce7c08194a77bb5c5e97d1b5ff0a"
	"file 6.1.4 1b92bec4fc2a72f59a8e15af5f52cd441e4a7860b49499d69dfa817af20e925d"
	"file_picker 5.5.0 be325344c1f3070354a1d84a231a1ba75ea85d413774ec4bdf444c023342e030"
	"file_selector_linux 0.9.3+2 54cbbd957e1156d29548c7d9b9ec0c0ebb6de0a90452198683a7d23aed617a33"
	"file_selector_macos 0.9.4+2 271ab9986df0c135d45c3cdb6bd0faa5db6f4976d3e4b437cf7d0f258d941bfc"
	"file_selector_platform_interface 2.6.2 a3994c26f10378a039faa11de174d7b78eb8f79e4dd0af2a451410c1a5c3f66b"
	"file_selector_windows 0.9.3+4 320fcfb6f33caa90f0b58380489fc5ac05d99ee94b61aa96ec2bff0ba81d3c2b"
	"fixnum 1.1.1 b6dc7065e46c974bc7c5f143080a6764ec7a4be6da1285ececdc37be96de53be"
	"flex_color_picker 3.6.0 12dc855ae8ef5491f529b1fc52c655f06dcdf4114f1f7fdecafa41eec2ec8d79"
	"flex_seed_scheme 3.4.1 7639d2c86268eff84a909026eb169f008064af0fb3696a651b24b0fa24a40334"
	"flutter_breadcrumb 1.0.1 1531680034def621878562ad763079933dabe9f9f5d5add5a094190edc33259b"
	"flutter_cache_manager 3.3.1 8207f27539deb83732fdda03e259349046a39a4c767269285f449ade355d54ba"
	"flutter_custom_cursor 0.0.4 3850a32ac6de351ccc5e4286b6d94ff70c10abecd44479ea6c5aaea17264285d"
	"flutter_keyboard_visibility 5.4.1 4983655c26ab5b959252ee204c2fffa4afeb4413cd030455194ec0caa3b8e7cb"
	"flutter_keyboard_visibility_linux 1.0.0 6fba7cd9bb033b6ddd8c2beb4c99ad02d728f1e6e6d9b9446667398b2ac39f08"
	"flutter_keyboard_visibility_macos 1.0.0 c5c49b16fff453dfdafdc16f26bdd8fb8d55812a1d50b0ce25fc8d9f2e53d086"
	"flutter_keyboard_visibility_platform_interface 2.0.0 e43a89845873f7be10cb3884345ceb9aebf00a659f479d1c8f4293fcb37022a4"
	"flutter_keyboard_visibility_web 2.0.0 d3771a2e752880c79203f8d80658401d0c998e4183edca05a149f5098ce6e3d1"
	"flutter_keyboard_visibility_windows 1.0.0 fc4b0f0b6be9b93ae527f3d527fb56ee2d918cd88bbca438c478af7bcfd0ef73"
	"flutter_launcher_icons 0.13.1 526faf84284b86a4cb36d20a5e45147747b7563d921373d4ee0559c54fcdbcea"
	"flutter_lints 2.0.3 a25a15ebbdfc33ab1cd26c63a6ee519df92338a9c10f122adda92938253bef04"
	"flutter_parsed_text 2.2.1 529cf5793b7acdf16ee0f97b158d0d4ba0bf06e7121ef180abe1a5b59e32c1e2"
	"flutter_plugin_android_lifecycle 2.0.17 b068ffc46f82a55844acfa4fdbb61fad72fa2aef0905548419d97f0f95c456da"
	"flutter_rust_bridge 1.80.1 ff90d5ddd0cda6d94ed048cc9c4a4d993d1a4bb11605d60a1282fc1bbf173c77"
	"flutter_svg 2.1.0 d44bf546b13025ec7353091516f6881f1d4c633993cb109c3916c3a0159dadf1"
	"freezed 2.5.7 44c19278dd9d89292cf46e97dc0c1e52ce03275f40a97c5a348e802a924bf40e"
	"freezed_annotation 2.4.4 c2e2d632dd9b8a2b7751117abcfc2b4888ecfe181bd9fca7170d9ef02e595fe2"
	"frontend_server_client 4.0.0 f64a0333a82f30b0cca061bc3d143813a486dc086b574bfb233b7c1372427694"
	"get 4.7.2 c79eeb4339f1f3deffd9ec912f8a923834bec55f7b49c9e882b8fef2c139d425"
	"glob 2.1.3 c3f1ee72c96f8f78935e18aa8cecced9ab132419e8625dc187e1c2408efc20de"
	"google_fonts 6.2.1 b1ac0fe2832c9cc95e5e88b57d627c5e68c223b9657f4b96e1487aa9098c7b82"
	"graphs 2.3.2 741bbf84165310a68ff28fe9e727332eef1407342fca52759cb21ad8177bb8d0"
	"html 0.15.6 6d1264f2dffa1b1101c25a91dff0dc2daee4c18e87cd8538729773c073dbf602"
	"http 1.4.0 2c11f3f94c687ee9bad77c171151672986360b2b001d109814ee7140b2cf261b"
	"http_multi_server 3.2.2 aa6199f908078bb1c5efb8d8638d4ae191aac11b311132c3ef48ce352fb52ef8"
	"http_parser 4.0.2 2aa08ce0341cc9b354a498388e30986515406668dbcc4f7c950c3e715496693b"
	"icons_launcher 2.1.7 9b514ffed6ed69b232fd2bf34c44878c8526be71fc74129a658f35c04c9d4a9d"
	"image 4.3.0 f31d52537dc417fdcde36088fdf11d191026fd5e4fae742491ebd40e5a8bea7d"
	"image_picker 1.1.2 021834d9c0c3de46bf0fe40341fa07168407f694d9b2bb18d532dc1261867f7a"
	"image_picker_android 0.8.12+21 82652a75e3dd667a91187769a6a2cc81bd8c111bbead698d8e938d2b63e5e89a"
	"image_picker_for_web 3.0.6 717eb042ab08c40767684327be06a5d8dbb341fe791d514e4b92c7bbe1b7bb83"
	"image_picker_ios 0.8.12+2 05da758e67bc7839e886b3959848aa6b44ff123ab4b28f67891008afe8ef9100"
	"image_picker_linux 0.2.1+2 34a65f6740df08bbbeb0a1abd8e6d32107941fd4868f67a507b25601651022c9"
	"image_picker_macos 0.2.1+2 1b90ebbd9dcf98fb6c1d01427e49a55bd96b5d67b8c67cf955d60a5de74207c1"
	"image_picker_platform_interface 2.10.1 886d57f0be73c4b140004e78b9f28a8914a09e50c2d816bdd0520051a71236a0"
	"image_picker_windows 0.2.1+1 6ad07afc4eb1bc25f3a01084d28520496c4a3bb0cb13685435838167c9dcedeb"
	"intl 0.19.0 d6f56758b7d3014a48af9701c085700aac781a92a87a62b1333b46d8879661cf"
	"io 1.0.5 dfd5a80599cf0165756e3181807ed3e77daf6dd4137caaad72d0b7931597650b"
	"js 0.6.7 f2c445dce49627136094980615a031419f7f3eb393237e4ecd97ac15dea343f3"
	"json_annotation 4.9.0 1ce844379ca14835a50d2f019a3099f419082cfdd231cd86a142af94dd5c6bb1"
	"leak_tracker 10.0.5 3f87a60e8c63aecc975dda1ceedbc8f24de75f09e4856ea27daf8958f2f0ce05"
	"leak_tracker_flutter_testing 3.0.5 932549fb305594d82d7183ecd9fa93463e9914e1b67cacc34bc40906594a1806"
	"leak_tracker_testing 3.0.1 6ba465d5d76e67ddf503e1161d1f4a6bc42306f9d66ca1e8f079a47290fb06d3"
	"lints 2.1.1 0a217c6c989d21039f1498c3ed9f3ed71b354e69873f13a8dfc3c9fe76f1b452"
	"logging 1.3.0 c8245ada5f1717ed44271ed1c26b8ce85ca3228fd2ffdb75468ab01979309d61"
	"macros 0.1.2-main.4 0acaed5d6b7eab89f63350bccd82119e6c602df0f391260d0e32b5e23db79536"
	"matcher 0.12.16+1 d2323aa2060500f906aa31a895b4030b6da3ebdcc5619d14ce1aada65cd161cb"
	"material_color_utilities 0.11.1 f7142bb1154231d7ea5f96bc7bde4bda2a0945d2806bb11670e30b850d56bdec"
	"meta 1.15.0 bdb68674043280c3428e9ec998512fb681678676b3c54e773629ffe74419f8c7"
	"mime 2.0.0 41a20518f0cb1256669420fdba0cd90d21561e560ac240f26ef8322e45bb7ed6"
	"nested 1.0.0 03bac4c528c64c95c722ec99280375a6f2fc708eec17c7b3f07253b626cd2a20"
	"octo_image 2.1.0 34faa6639a78c7e3cbe79be6f9f96535867e879748ade7d17c9b1ae7536293bd"
	"package_config 2.2.0 f096c55ebb7deb7e384101542bfba8c52696c1b56fca2eb62827989ef2353bbc"
	"package_info_plus 4.2.0 7e76fad405b3e4016cd39d08f455a4eb5199723cf594cd1b8916d47140d93017"
	"package_info_plus_platform_interface 2.0.1 9bc8ba46813a4cc42c66ab781470711781940780fd8beddd0c3da62506d3a6c6"
	"password_strength 0.2.0 0e51e3d864e37873a1347e658147f88b66e141ee36c58e19828dc5637961e1ce"
	"path 1.9.0 087ce49c3f0dc39180befefc60fdb4acd8f8620e5682fe2476afd0b3688bb4af"
	"path_parsing 1.1.0 883402936929eac138ee0a45da5b0f2c80f89913e6dc3bf77eb65b84b409c6ca"
	"path_provider 2.1.5 50c5dd5b6e1aaf6fb3a78b33f6aa3afca52bf903a8a5298f53101fdaee55bbcd"
	"path_provider_android 2.2.15 4adf4fd5423ec60a29506c76581bc05854c55e3a0b72d35bb28d661c9686edf2"
	"path_provider_foundation 2.4.1 4843174df4d288f5e29185bd6e72a6fbdf5a4a4602717eed565497429f179942"
	"path_provider_linux 2.2.1 f7a1fe3a634fe7734c8d3f2766ad746ae2a2884abe22e241a8b301bf5cac3279"
	"path_provider_platform_interface 2.1.2 88f5779f72ba699763fa3a3b06aa4bf6de76c8e5de842cf6f29e2e06476c2334"
	"path_provider_windows 2.3.0 bd6f00dbd873bfb70d0761682da2b3a2c2fccc2b9e84c495821639601d81afe7"
	"pedantic 1.11.1 67fc27ed9639506c856c840ccce7594d0bdcd91bc8d53d6e52359449a1d50602"
	"percent_indicator 4.2.5 157d29133bbc6ecb11f923d36e7960a96a3f28837549a20b65e5135729f0f9fd"
	"petitparser 6.0.2 c15605cd28af66339f8eb6fbe0e541bfe2d1b72d5825efc6598f3e0a31b9ad27"
	"platform 3.1.6 5d6b1b0036a5f331ebc77c850ebc8506cbc1e9416c27e59b439f917a902a4984"
	"plugin_platform_interface 2.1.8 4820fbfdb9478b1ebae27888254d445073732dae3d6ea81f0b7e06d5dedc3f02"
	"pool 1.5.1 20fe868b6314b322ea036ba325e6fc0711a22948856475e2c2b6306e8ab39c2a"
	"provider 6.1.5 4abbd070a04e9ddc287673bf5a030c7ca8b685ff70218720abab8b092f53dd84"
	"pub_semver 2.2.0 5bfcf68ca79ef689f8990d1160781b4bad40a3bd5e5218ad4076ddb7f4081585"
	"pubspec_parse 1.4.0 81876843eb50dc2e1e5b151792c9a985c5ed2536914115ed04e9c8528f6647b0"
	"pull_down_button 0.9.4 48b928203afdeafa4a8be5dc96980523bc8a2ddbd04569f766071a722be22379"
	"puppeteer 3.16.0 7a990c68d33882b642214c351f66492d9a738afa4226a098ab70642357337fa2"
	"qr 3.0.2 5a1d2586170e172b8a8c8470bbbffd5eb0cd38a66c0d77155ea138d3af3a4445"
	"qr_code_scanner 1.0.1 f23b68d893505a424f0bd2e324ebea71ed88465d572d26bb8d2e78a4749591fd"
	"qr_flutter 4.1.0 5095f0fc6e3f71d08adef8feccc8cea4f12eec18a2e31c2e8d82cb6019f4b097"
	"quiver 3.2.2 ea0b925899e64ecdfbf9c7becb60d5b50e706ade44a85b2363be2a22d88117d2"
	"rxdart 0.27.7 0c7c0cedd93788d996e33041ffecda924cc54389199cde4e6a34b440f50044cb"
	"screen_retriever 0.1.9 6ee02c8a1158e6dae7ca430da79436e3b1c9563c8cf02f524af997c201ac2b90"
	"scroll_pos 0.4.0 4246bff3afc779d87cdf650a67d42d67ae71b23ff020d14592e6b89e28a7f9cc"
	"settings_ui 2.0.2 d9838037cb554b24b4218b2d07666fbada3478882edefae375ee892b6c820ef3"
	"shelf 1.4.1 ad29c505aee705f41a4d8963641f91ac4cee3c8fad5947e033390a7bd8180fa4"
	"shelf_static 1.1.3 c87c3875f91262785dade62d135760c2c69cb217ac759485334c5857ad89f6e3"
	"shelf_web_socket 1.0.4 9ca081be41c60190ebcb4766b2486a7d50261db7bd0f5d9615f2d653637a84c1"
	"simple_observable 2.0.0 b392795c48f8b5f301b4c8f73e15f56e38fe70f42278c649d8325e859a783301"
	"source_gen 1.5.0 14658ba5f669685cd3d63701d01b31ea748310f7ab854e471962670abcf57832"
	"source_span 1.10.0 53e943d4206a5e30df338fd4c6e7a077e02254531b138a15aec3bd143c1a8b3c"
	"sqflite 2.2.0 a9a8c6dfdf315f87f2a23a7bad2b60c8d5af0f88a5fde92cf9205202770c2753"
	"sqflite_common 2.5.4+6 761b9740ecbd4d3e66b8916d784e581861fd3c3553eda85e167bc49fdb68f709"
	"stack_trace 1.11.1 73713990125a6d93122541237550ee3352a2d84baad52d375a4cad2eb9b7ce0b"
	"stream_channel 2.1.2 ba2aa5d8cc609d96bbb2899c28934f9e1af5cddbd60a827822ea467161eb54e7"
	"stream_transform 2.1.1 ad47125e588cfd37a9a7f86c7d6356dde8dfe89d071d293f80ca9e9273a33871"
	"string_scanner 1.2.0 556692adab6cfa87322a115640c11f13cb77b3f076ddcc5d6ae3c20242bedcde"
	"synchronized 3.3.0+3 69fe30f3a8b04a0be0c15ae6490fc859a78ef4c43ae2dd5e8a623d45bfcf9225"
	"term_glyph 1.2.1 a29248a84fbb7c79282b40b8c72a1209db169a2e0542bce341da992fe1bc7e84"
	"test_api 0.7.2 5b8a98dafc4d5c4c9c72d8b31ab2b23fc13422348d2997120294d3bac86b4ddb"
	"timing 1.0.2 62ee18aca144e4a9f29d212f5a4c6a053be252b895ab14b5821996cff4ed90fe"
	"toggle_switch 2.3.0 dca04512d7c23ed320d6c5ede1211a404f177d54d353bf785b07d15546a86ce5"
	"tuple 2.0.2 a97ce2013f240b2f3807bcbaf218765b6f301c3eff91092bcfa23a039e7dd151"
	"typed_data 1.4.0 f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006"
	"uni_links_desktop 0.1.7 692de81efc32ef72df56d428902afb5216d5f9e43d71c7b315d360acd7a1e115"
	"uni_links_platform_interface 1.0.0 929cf1a71b59e3b7c2d8a2605a9cf7e0b125b13bc858e55083d88c62722d4507"
	"uni_links_web 0.1.0 7539db908e25f67de2438e33cc1020b30ab94e66720b5677ba6763b25f6394df"
	"universal_io 2.2.2 1722b2dcc462b4b2f3ee7d188dad008b6eb4c40bbd03a3de451d82c78bba9aad"
	"url_launcher 6.3.1 9d06212b1362abc2f0f0d78e6f09f726608c74e3b9462e8368bb03314aa8d603"
	"url_launcher_android 6.3.14 6fc2f56536ee873eeb867ad176ae15f304ccccc357848b351f6f0d8d4a40d193"
	"url_launcher_ios 6.3.3 7f2022359d4c099eea7df3fdf739f7d3d3b9faf3166fb1dd390775176e0b76cb"
	"url_launcher_linux 3.2.1 4e9ba368772369e3e08f231d2301b4ef72b9ff87c31192ef471b380ef29a4935"
	"url_launcher_macos 3.2.2 17ba2000b847f334f16626a574c702b196723af2a289e7a93ffcb79acff855c2"
	"url_launcher_platform_interface 2.3.2 552f8a1e663569be95a8190206a38187b531910283c3e982193e4f2733f01029"
	"url_launcher_web 2.3.3 772638d3b34c779ede05ba3d38af34657a05ac55b06279ea6edd409e323dca8e"
	"url_launcher_windows 3.1.4 3284b6d2ac454cf34f114e1d3319866fdd1e19cdc329999057e44ffe936cfa77"
	"uuid 3.0.7 648e103079f7c64a36dc7d39369cabb358d377078a051d6ae2ad3aa539519313"
	"vector_graphics 1.1.18 44cc7104ff32563122a929e4620cf3efd584194eec6d1d913eb5ba593dbcf6de"
	"vector_graphics_codec 1.1.13 99fd9fbd34d9f9a32efd7b6a6aae14125d8237b10403b422a6a6dfeac2806146"
	"vector_graphics_compiler 1.1.16 1b4b9e706a10294258727674a340ae0d6e64a7231980f9f9a3d12e4b42407aad"
	"vector_math 2.1.4 80b3257d1492ce4d091729e3a67a60407d227c27241d6927be0130c98e741803"
	"video_player 2.9.5 7d78f0cfaddc8c19d4cb2d3bebe1bfef11f2103b0a03e5398b303a1bf65eeb14"
	"video_player_android 2.7.16 391e092ba4abe2f93b3e625bd6b6a6ec7d7414279462c1c0ee42b5ab8d0a0898"
	"video_player_avfoundation 2.7.1 9ee764e5cd2fc1e10911ae8ad588e1a19db3b6aa9a6eb53c127c42d3a3c3f22f"
	"video_player_platform_interface 6.3.0 df534476c341ab2c6a835078066fc681b8265048addd853a1e3c78740316a844"
	"video_player_web 2.3.5 e8bba2e5d1e159d5048c9a491bb2a7b29c535c612bb7d10c1e21107f5bd365ba"
	"visibility_detector 0.4.0+2 dd5cc11e13494f432d15939c3aa8ae76844c42b723398643ce9addb88a5ed420"
	"vm_service 14.2.5 5c5f338a667b4c644744b661f309fb8080bb94b18a7e91ef1dbd343bed00ed6d"
	"wakelock_plus 1.2.1 104d94837bb28c735894dcd592877e990149c380e6358b00c04398ca1426eed4"
	"wakelock_plus_platform_interface 1.2.3 e10444072e50dbc4999d7316fd303f7ea53d31c824aa5eb05d7ccbdd98985207"
	"watcher 1.1.2 0b7fd4a0bbc4b92641dbf20adfd7e3fd1398fe17102d94b674234563e110088a"
	"web 0.5.1 97da13628db363c635202ad97068d47c5b8aa555808e7a9411963c533b449b27"
	"web_socket_channel 2.4.5 58c6666b342a38816b2e7e50ed0f1e261959630becd4c879c4f26bfa14aa5a42"
	"win32 5.10.1 daf97c9d80197ed7b619040e86c8ab9a9dad285e7671ee7390f9180cc828a51e"
	"win32_registry 1.1.5 21ec76dfc731550fd3e2ce7a33a9ea90b828fdf19a5c3bcf556fa992cfa99852"
	"xdg_directories 1.1.0 7a3f37b05d989967cdddcbb571f1ea834867ae2faa29725fd085180e0883aa15"
	"xml 6.5.0 b015a8ad1c488f66851d762d3090a21c600e479dc75e68328c52774040cf9226"
	"xterm 4.0.0 168dfedca77cba33fdb6f52e2cd001e9fde216e398e89335c19b524bb22da3a2"
	"yaml 3.1.3 b9da305ac7c39faa3f030eccd175340f968459dae4af175130b3fc47e40d76ce"
	"yaml_edit 2.2.2 fb38626579fb345ad00e674e2af3a5c9b0cc4b9bfb8fd7f7ff322c7c9e62aef5"
	"zmodem 0.0.6 3b7e5b29f3a7d8aee472029b05165a68438eff2f3f7766edf13daba1e297adbf"
	"zxing2 0.2.4 2677c49a3b9ca9457cb1d294fd4bd5041cac6aab8cdb07b216ba4e98945c684f"
)
PUB_GIT=(
	"dash_chat_2 https://github.com/rustdesk-org/Dash-Chat-2 bd6b5b41254e57c5bcece202ebfb234de63e6487 ."
	"desktop_multi_window https://github.com/rustdesk-org/rustdesk_desktop_multi_window b47e8385e5a75d38319ad706a64b0ead3108b093 ."
	"dynamic_layouts https://github.com/rustdesk-org/dynamic_layouts.git 24cb88413fa5181d949ddacbb30a65d5c459e7d9 ."
	"texture_rgba_renderer https://github.com/rustdesk-org/flutter_texture_rgba_renderer 42797e0f03141dc2b585f76c64a13974508058b4 ."
	"uni_links https://github.com/rustdesk-org/uni_links f416118d843a7e9ed117c7bb7bdc2deda5a9e86f uni_links"
	"window_manager https://github.com/rustdesk-org/window_manager 85789bfe6e4cfaf4ecc00c52857467fdb7f26879 ."
	"window_size https://github.com/google/flutter-desktop-embedding.git eb3964990cf19629c89ff8cb4a37640c7b3d5601 plugins/window_size"
)

# Several of the crates above vendor another repository as a subdirectory that
# the GitHub archive leaves empty, so those are fetched separately and linked
# into place in src_prepare. Each commit is the submodule pointer: read it with
# git ls-tree <tag> <path> in the crate's repository.
LIBWEBM_COMMIT="3b630045052e1e4d563207ab9e3be8d137c26067"
KCP_COMMIT="7f9805887b0909c52c825925f123e7a84da37167"
HBB_COMMON_COMMIT="7e1c392c62d39c364127307cd408421dd5f8cfb0"
HWCODEC_EXTERNALS_COMMIT="8903740a1f47884906a6e347ad3d8d56304d9771"
# pinned by the vcpkg checkout in .github/workflows/flutter-build.yml
VCPKG_TAG="2025.08.27"
SRC_URI="
	https://github.com/rustdesk/rustdesk/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/rustdesk-vcpkg/releases/download/${PV}/${P}-vcpkg-${VCPKG_TAG}-lite.tar.gz
	https://github.com/webmproject/libwebm/archive/${LIBWEBM_COMMIT}.tar.gz
		-> libwebm-${LIBWEBM_COMMIT}.tar.gz
	https://github.com/skywind3000/kcp/archive/${KCP_COMMIT}.tar.gz
		-> kcp-${KCP_COMMIT}.tar.gz
	https://github.com/rustdesk/hbb_common/archive/${HBB_COMMON_COMMIT}.tar.gz
		-> hbb_common-${HBB_COMMON_COMMIT}.tar.gz
	https://github.com/rustdesk-org/externals/archive/${HWCODEC_EXTERNALS_COMMIT}.tar.gz
		-> hwcodec-externals-${HWCODEC_EXTERNALS_COMMIT}.tar.gz
	https://github.com/gentoo-zh-drafts/${PN}/releases/download/${PV}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
	$(dart-pub_src_uri)
"

LICENSE="AGPL-3"
# bundled crates and Dart packages
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0
	CC-BY-SA-2.5 CC0-1.0 CDLA-Permissive-2.0 EUPL-1.2 GPL-3+ IJG ISC
	MIT MIT-0 MPL-2.0 Unicode-DFS-2016 Unlicense W3C WTFPL-2 ZLIB
	public-domain
"
# the Flutter engine copied in bundles ICU, HarfBuzz, Skia, FreeType,
# libjpeg-turbo, expat, libpng, libwebp, zlib and more
LICENSE+=" FTL Old-MIT Unicode-3.0 libpng"
SLOT="0"
KEYWORDS="~amd64"

IUSE="wayland +hwaccel"

FLUTTER_APP_DIR="${S}/flutter"

DEPEND="
	app-accessibility/at-spi2-core
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/gst-plugins-base
	media-libs/gstreamer
	media-libs/harfbuzz
	media-libs/libepoxy
	media-libs/libpulse
	sys-apps/dbus
	sys-libs/pam
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXtst
	x11-libs/pango
	hwaccel? (
		media-libs/libva:0/2[X]
		x11-libs/libvdpau
	)
"
RDEPEND="
	${DEPEND}
	x11-misc/xdotool
	wayland? ( media-video/pipewire[gstreamer] )
"
BDEPEND="
	${FLUTTER_DEPEND}
	dev-lang/nasm
	~dev-util/flutter-rust-bridge-codegen-1.80.1
	dev-lang/yasm
	dev-libs/wayland-protocols
	dev-util/wayland-scanner
	dev-util/patchelf
"

QA_PREBUILT="usr/share/${PN}/lib/libflutter_linux_gtk.so"
QA_PRESTRIPPED="usr/share/${PN}/lib/libflutter_linux_gtk.so"

PATCHES=(
	"${FILESDIR}"/${PN}-1.4.8-fix-llvm22-bindgen.patch
	"${FILESDIR}"/${PN}-1.4.8-disable-check-x11.patch
	"${FILESDIR}"/${P}-drop-gpu-renderer-plugin.patch
)

pkg_setup() {
	# upstream's release profile forces lto = true
	if tc-is-lto; then
		if tc-is-gcc; then
			export CARGO_PROFILE_RELEASE_LTO="true"
		elif tc-is-clang; then
			export CARGO_PROFILE_RELEASE_LTO="thin"
		fi
	else
		export CARGO_PROFILE_RELEASE_LTO="false"
	fi

	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_unpack() {
	flutter-app_src_unpack
	cargo_gen_config
}

# Link a separately fetched tree over the empty directory a crate vendors:
# rustdesk_link_vendored <crate> <subdirectory> <fetched-tree>
rustdesk_link_vendored() {
	local crate=${1} subdir=${2} source=${3} entry commit dir

	# a GIT_CRATES entry is url;commit;directory
	entry=${GIT_CRATES[${crate}]}
	commit=${entry#*;}
	commit=${commit%%;*}
	dir=${WORKDIR}/${entry##*;}
	dir=${dir/\%commit\%/${commit}}/${subdir}

	rm -r "${dir}" || die
	ln -s "${WORKDIR}/${source}" "${dir}" || die
}

src_prepare() {
	flutter-app_src_prepare

	pushd "${WORKDIR}" >/dev/null || die
	eapply "${FILESDIR}/rust-sciter.patch"
	popd >/dev/null || die

	pushd "${EFLUTTER_ROOT}" >/dev/null || die
	eapply "${S}/.github/patches/flutter_3.24.4_dropdown_menu_enableFilter.diff"
	popd >/dev/null || die

	rm -r "${S}"/libs/hbb_common || die
	ln -s "${WORKDIR}/hbb_common-${HBB_COMMON_COMMIT}" "${S}"/libs/hbb_common || die

	rustdesk_link_vendored webm src/sys/libwebm libwebm-${LIBWEBM_COMMIT}
	rustdesk_link_vendored hwcodec externals externals-${HWCODEC_EXTERNALS_COMMIT}
	rustdesk_link_vendored kcp-sys kcp kcp-${KCP_COMMIT}

	# pubspec_overrides.yaml replaces the dependency_overrides section of
	# pubspec.yaml, so carry upstream's two version overrides into it
	cat <<-EOF > "${FLUTTER_APP_DIR}"/pubspec_overrides.yaml || die
		dependency_overrides:
		  intl: ^0.19.0
		  flutter_plugin_android_lifecycle: 2.0.17
	EOF
	flutter-app_pub_get
}

src_configure() {
	local myfeatures=( flutter unix-file-copy-paste )
	use hwaccel && myfeatures+=( hwcodec )

	cargo_src_configure
}

src_compile() {
	# the bridge between src/flutter_ffi.rs and the Dart side, generated the
	# way .github/workflows/bridge.yml does it; ffigen loads libclang, which
	# does not find clang's own headers (stdbool.h) without the resource dir
	flutter-app_setup_env
	flutter_rust_bridge_codegen \
		--rust-input src/flutter_ffi.rs \
		--dart-output flutter/lib/generated_bridge.dart \
		--llvm-path "$(get_llvm_prefix -b)" \
		--llvm-compiler-opts="-I$("$(get_llvm_prefix -b)"/bin/clang -print-resource-dir)/include" || die

	VCPKG_ROOT="${WORKDIR}/vcpkg" cargo_src_compile --lib

	# flutter/linux/CMakeLists.txt installs the library from target/release
	# whatever profile cargo built it with
	if [[ $(cargo_target_dir) != target/release ]]; then
		mkdir -p target/release || die
		cp "$(cargo_target_dir)"/liblibrustdesk.so target/release/ || die
	fi

	cargo_env flutter-app_src_compile
}

src_test() {
	local CARGO_SKIP_TESTS=(
		# reads the cursor from a running X server
		platform::tests::test_get_cursor_pos
		# compares the login user's home with HOME
		platform::linux::desktop::tests::test_desktop_env
	)

	VCPKG_ROOT="${WORKDIR}/vcpkg" cargo_src_test
}

src_install() {
	local bundle dir=/usr/share/${PN}
	bundle=$(flutter-app_bundle_dir)

	exeinto "${dir}"
	doexe "${bundle}"/${PN}
	insinto "${dir}"
	doins -r "${bundle}"/{data,lib}
	newbin "${FILESDIR}"/rustdesk.sh ${PN}

	# these keep the ephemeral build directory as their RUNPATH
	local lib
	for lib in "${ED}${dir}"/lib/librustdesk.so "${ED}${dir}"/lib/lib*plugin.so; do
		[[ -e ${lib} ]] || continue
		patchelf --set-rpath '$ORIGIN' "${lib}" || die
	done

	newicon -s 32 res/32x32.png ${PN}.png
	newicon -s 128 res/128x128.png ${PN}.png
	newicon -s 256 res/128x128@2x.png ${PN}.png

	domenu res/rustdesk{,-link}.desktop
	systemd_dounit "${FILESDIR}"/rustdesk.service
	newinitd "${FILESDIR}"/rustdesk.initd rustdesk
	newconfd "${FILESDIR}"/rustdesk.confd rustdesk

	einstalldocs
}
