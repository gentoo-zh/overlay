# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# rhttp (a Dart HTTP plugin) builds a Rust cdylib through cargokit during the
# Flutter Linux build, so a system Rust toolchain is needed. The Flutter Linux
# toolchain itself hard-codes clang++, so an LLVM/clang slot is needed too.
LLVM_COMPAT=( 18 19 20 21 22 )
RUST_MIN_VER="1.80.0"

inherit dart-pub desktop llvm-r2 rust xdg

# grep FLUTTER_VERSION .github/workflows/linux_build.yml
_FLUTTER_VERSION="3.24.5"

DESCRIPTION="An open-source cross-platform alternative to AirDrop"
HOMEPAGE="https://localsend.org"

# The app's resolved Dart dependencies, fetched individually from pub.dev instead of a
# bundled pub-cache. Regenerate with pubspec2ebuild.py on the FOSS pubspec.lock (produced
# by running scripts/remove_proprietary_dependencies.sh then `flutter pub get`).
PUB_HOSTED=(
	"adaptive_number 1.0.0 3a567544e9b5c9c803006f51140ad544aedc79604fd4f3f2c1380003f97c1d77"
	"analyzer 6.2.0 69f54f967773f6c26c7dcb13e93d7ccee8b17a641689da39e878d5cf13b06893"
	"analyzer 6.7.0 b652861553cd3990d8ed361f7979dc6d7053a9ac8843fa73820ab68ce5410139"
	"animated_vector 0.2.2 f1beb10e6fcfd8bd15abb788e20345def786d1c7391d7c1426bb2a1f2adf2132"
	"animated_vector_annotations 0.2.2 07c1ea603a2096f7eb6f1c2b8f16c3c330c680843ea78b7782a3217c3c53f979"
	"ansicolor 2.0.3 50e982d500bc863e1d703448afdbf9e5a72eb48840a4f766fa361ffd6877055f"
	"archive 3.6.1 cb6a278ef2dbb298455e1a713bda08524a175630ec643a242c399c932a0a1f7d"
	"args 2.4.2 eef6c46b622e0494a36c5a12d10d77fb4e855501a91c1b9ef9339326e58f0596"
	"args 2.6.0 bf9f5caeea8d8fe6721a9c358dd8a5c1947b27f1cfaa18b39c301273594919e6"
	"assorted_layout_widgets 9.0.2 5b7f7c76a1a4c7cf95edfb854c3ed09ce9cb7f25a372f2d9a8d4c1569d42ecfb"
	"async 2.11.0 947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
	"basic_utils 5.7.0 2064b21d3c41ed7654bc82cc476fd65542e04d60059b74d5eed490a4da08fc6c"
	"boolean_selector 2.1.1 6cfb5af12253eaf2b368f07bacc5a80d1301a071c73360d746b7f2e32d762c66"
	"build 2.4.1 80184af8b6cb3e5c1c4ec6d8544d27711700bc3e6d2efad04238c7b5290889f0"
	"build_cli_annotations 2.1.0 b59d2769769efd6c9ff6d4c4cede0be115a566afc591705c2040b707534b1172"
	"build_config 1.1.1 bf80fcfb46a29945b423bd9aad884590fb1dc69b330a4d4700cac476af1708d1"
	"build_daemon 4.0.2 79b2aef6ac2ed00046867ed354c88778c9c0f029df8a20fe10b5436826721ef9"
	"build_resolvers 2.4.2 339086358431fa15d7eca8b6a36e5d783728cf025e559b834f4609a1fcfb7b0a"
	"build_runner 2.4.13 028819cfb90051c6b5440c7e574d1896f8037e3c96cf17aaeb054c9311cfbf4d"
	"build_runner_core 7.3.2 f8126682b87a7282a339b871298cc12009cb67109cfa1614d6436fb0289193e0"
	"built_collection 5.1.1 376e3dd27b51ea877c28d525560790aee2e6fbb5f20e2f85d5081027d94e2100"
	"built_value 8.9.2 c7913a9737ee4007efedaffc968c049fd0f3d0e49109e778edc10de9426005cb"
	"characters 1.3.0 04a925763edad70e8443c99234dc3328f442e811f1d8fd1a72f1c8ad0f69a605"
	"checked_yaml 2.0.3 feb6bed21949061731a7a75fc5d2aa727cf160b91af9a3e464c5e3a32e28b5ff"
	"clock 1.1.1 cb6d7f03e1de671e34607e909a7213e31d7752be4fb66a86d29fe1eb14bfb5cf"
	"code_builder 4.10.1 0ec10bf4a89e4c613960bf1e8b42c64127021740fb21640c29c909826a5eea3e"
	"collection 1.18.0 ee67cb0715911d28db6bf4af1026078bd6f0128b07a5f66fb2ed94ec6783c09a"
	"color 3.0.0 ddcdf1b3badd7008233f5acffaf20ca9f5dc2cd0172b75f68f24526a5f5725cb"
	"connectivity_plus 6.1.0 876849631b0c7dc20f8b471a2a03142841b482438e3b707955464f5ffca3e4c3"
	"connectivity_plus_platform_interface 2.0.1 42657c1715d48b167930d5f34d00222ac100475f73d10162ddf43e714932f204"
	"convert 3.1.1 0f08b14755d163f6e2134cb58222dd25ea2a2ee8a195e53983d57c075324d592"
	"convert 3.1.2 b30acd5944035672bc15c6b7a8b47d773e41e2f17de064350988c5d02adb1c68"
	"coverage 1.11.0 4b03e11f6d5b8f6e5bb5e9f7889a56fe6c5cbe942da5378ea4d4d7f73ef9dfe5"
	"coverage 1.6.3 2fb815080e44a09b85e0f2ca8a820b15053982b2e714b59267719e8a9ff17097"
	"cross_file 0.3.4+2 7caf6a750a0c04effbb52a676dce9a4a592e10ad35c34d6d2d0e4811160d5670"
	"crypto 3.0.3 ff625774173754681d66daaf4a448684fb04b78f902da9cb3d308c19cc5e8bab"
	"crypto 3.0.6 1e445881f28f22d6140f181e07737b22f1e099a5e1ff94b0af2f9e4a463f4855"
	"csslib 1.0.2 09bad715f418841f976c77db72d5398dc1253c21fb9c0c7f0b0b985860b2d58e"
	"csv 6.0.0 c6aa2679b2a18cb57652920f674488d89712efaf4d3fdf2e537215b35fc19d6c"
	"dart_mappable 4.3.0 f69a961ae8589724ebb542e588f228ae844c5f78028899cbe2cc718977c1b382"
	"dart_mappable_builder 4.3.0 04a6e7117382f8a8689b3e363bee6c3de8c9ea4332e664148fe01bd576eb1126"
	"dart_style 2.3.7 7856d364b589d1f08986e140938578ed36ed948581fbc3bc9aef1805039ac5ab"
	"dartx 1.2.0 8b25435617027257d43e6508b5fe061012880ddfdaa75a71d607c3de2a13d244"
	"dbus 0.7.10 365c771ac3b0e58845f39ec6deebc76e3276aa9922b0cc60840712094d9047ac"
	"desktop_drop 0.5.0 03abf1c0443afdd1d65cf8fa589a2f01c67a11da56bbb06f6ea1de79d5628e94"
	"device_apps 2.2.0 e84dc74d55749993fd671148cc0bd53096e1be0c268fc364285511b1d8a4c19b"
	"device_info_plus 11.1.1 f545ffbadee826f26f2e1a0f0cbd667ae9a6011cc0f77c0f8f00a969655e6e95"
	"device_info_plus_platform_interface 7.0.1 282d3cf731045a2feb66abfe61bbc40870ae50a3ed10a4d3d217556c35c8c2ba"
	"dynamic_color 1.7.0 eae98052fa6e2826bdac3dd2e921c6ce2903be15c6b7f8b6d8a5d49b5086298d"
	"ed25519_edwards 0.3.1 6ce0112d131327ec6d42beede1e5dfd526069b18ad45dcf654f15074ad9276cd"
	"extended_image 9.0.7 613875dc319f17546ea07499b5f0774755709a19a36dfde812e5eda9eb7a5c8c"
	"extended_image_library 4.0.5 9a94ec9314aa206cfa35f16145c3cd6e2c924badcc670eaaca8a3a8063a68cd7"
	"fake_async 1.3.1 511392330127add0b769b75a987850d136345d9227c6b94c96a04cf4a391bf78"
	"_fe_analyzer_shared 64.0.0 eb376e9acf6938204f90eb3b1f00b578640d3188b4c8a8ec054f9f479af8d051"
	"_fe_analyzer_shared 72.0.0 f256b0c0ba6c7577c15e2e4e114755640a875e885099367bf6e012b19314c834"
	"ffi 2.1.3 16ed7b077ef01ad6170a3d0c57caa4a112a38d7a2ed5602e0aca9ca6f3d98da6"
	"file 6.1.4 1b92bec4fc2a72f59a8e15af5f52cd441e4a7860b49499d69dfa817af20e925d"
	"file 7.0.1 a3b4f84adafef897088c160faf7dfffb7696046cb13ae90b508c2cbc95d3b8d4"
	"file_picker 8.1.4 16dc141db5a2ccc6520ebb6a2eb5945b1b09e95085c021d9f914f8ded7f1465c"
	"file_selector 1.0.3 5019692b593455127794d5718304ff1ae15447dea286cdda9f0db2a796a1b828"
	"file_selector_android 0.5.1+11 934850f9702b0f9031bc331a306e7bebc62f894a6e5ca6c0681c7af17e7afb50"
	"file_selector_ios 0.5.3+1 94b98ad950b8d40d96fee8fa88640c2e4bd8afcdd4817993bd04e20310f45420"
	"file_selector_linux 0.9.3+1 b2b91daf8a68ecfa4a01b778a6f52edef9b14ecd506e771488ea0f2e0784198b"
	"file_selector_macos 0.9.4+2 271ab9986df0c135d45c3cdb6bd0faa5db6f4976d3e4b437cf7d0f258d941bfc"
	"file_selector_platform_interface 2.6.2 a3994c26f10378a039faa11de174d7b78eb8f79e4dd0af2a451410c1a5c3f66b"
	"file_selector_web 0.9.4+2 c4c0ea4224d97a60a7067eca0c8fd419e708ff830e0c83b11a48faf566cec3e7"
	"file_selector_windows 0.9.3+3 8f5d2f6590d51ecd9179ba39c64f722edc15226cc93dcc8698466ad36a4a85a4"
	"fixnum 1.1.0 25517a4deb0c03aa0f32fd12db525856438902d9c16536311e76cdc57b31d7d1"
	"fixnum 1.1.1 b6dc7065e46c974bc7c5f143080a6764ec7a4be6da1285ececdc37be96de53be"
	"flutter_displaymode 0.6.0 42c5e9abd13d28ed74f701b60529d7f8416947e58256e6659c5550db719c57ef"
	"flutter_gen_core 5.8.0 46ecf0e317413dd065547887c43f93f55e9653e83eb98dc13dd07d40dd225325"
	"flutter_gen_runner 5.8.0 77f0a02fc30d9fcf2549fe874eb3fde091435724904bcbb1af60aa40cbfab1f4"
	"flutter_lints 5.0.0 5398f14efa795ffb7a33e9b6a08798b26a180edac4ad7db3f231e40f82ce11e1"
	"flutter_markdown 0.7.4+2 999a4e3cb3e1532a971c86d6c73a480264f6a687959d4887cb4e2990821827e4"
	"flutter_plugin_android_lifecycle 2.0.23 9b78450b89f059e96c9ebb355fa6b3df1d6b330436e0b885fb49594c41721398"
	"flutter_rust_bridge 2.7.1 3292ad6085552987b8b3b9a7e5805567f4013372d302736b702801acb001ee00"
	"freezed_annotation 2.4.4 c2e2d632dd9b8a2b7751117abcfc2b4888ecfe181bd9fca7170d9ef02e595fe2"
	"frontend_server_client 3.2.0 408e3ca148b31c20282ad6f37ebfa6f4bdc8fede5b74bc2f08d9d92b55db3612"
	"frontend_server_client 4.0.0 f64a0333a82f30b0cca061bc3d143813a486dc086b574bfb233b7c1372427694"
	"gal 2.3.0 54c9b72528efce7c66234f3b6dd01cb0304fd8af8196de15571d7bdddb940977"
	"github 9.17.0 9966bc13bf612342e916b0a343e95e5f046c88f602a14476440e9b75d2295411"
	"glob 2.1.2 0e7014b3b7d4dac1ca4d6114f82bf1782ee86745b9b42a92c9289c23d8a0ab63"
	"graphs 2.3.2 741bbf84165310a68ff28fe9e727332eef1407342fca52759cb21ad8177bb8d0"
	"gsettings 0.2.8 1b0ce661f5436d2db1e51f3c4295a49849f03d304003a7ba177d01e3a858249c"
	"gtk 2.1.0 e8ce9ca4b1df106e4d72dad201d345ea1a036cc12c360f1a7d5a758f78ffa42c"
	"hashcodes 2.0.0 80f9410a5b3c8e110c4b7604546034749259f5d6dcca63e0d3c17c9258f1a651"
	"hex 0.2.0 4e7cd54e4b59ba026432a6be2dd9d96e4c5205725194997193bf871703b82c4a"
	"html 0.15.5 1fc58edeaec4307368c60d59b7e15b9d658b57d7f3125098b6294153c75337ec"
	"http 1.1.0 759d1a329847dd0f39226c688d3e06a6b8679668e350e2891a6474f8b4bb8525"
	"http 1.2.2 b9c29a161230ee03d3ccf545097fccd9b87a5264228c5d348202e0f0c28f9010"
	"http_client_helper 3.0.0 8a9127650734da86b5c73760de2b404494c968a3fd55602045ffec789dac3cb1"
	"http_multi_server 3.2.1 97486f20f9c2f7be8f514851703d0119c3596d14ea63227af6f7a481ef2b2f8b"
	"http_parser 4.0.2 2aa08ce0341cc9b354a498388e30986515406668dbcc4f7c950c3e715496693b"
	"http_profile 0.1.0 7e679e355b09aaee2ab5010915c932cce3f2d1c11c3b2dc177891687014ffa78"
	"image 4.3.0 f31d52537dc417fdcde36088fdf11d191026fd5e4fae742491ebd40e5a8bea7d"
	"image_picker 1.1.2 021834d9c0c3de46bf0fe40341fa07168407f694d9b2bb18d532dc1261867f7a"
	"image_picker_android 0.8.12+17 8faba09ba361d4b246dc0a17cb4289b3324c2b9f6db7b3d457ee69106a86bd32"
	"image_picker_for_web 3.0.6 717eb042ab08c40767684327be06a5d8dbb341fe791d514e4b92c7bbe1b7bb83"
	"image_picker_ios 0.8.12+1 4f0568120c6fcc0aaa04511cb9f9f4d29fc3d0139884b1d06be88dcec7641d6b"
	"image_picker_linux 0.2.1+1 4ed1d9bb36f7cd60aa6e6cd479779cc56a4cb4e4de8f49d487b1aaad831300fa"
	"image_picker_macos 0.2.1+1 3f5ad1e8112a9a6111c46d0b57a7be2286a9a07fc6e1976fdf5be2bd31d4ff62"
	"image_picker_platform_interface 2.10.0 9ec26d410ff46f483c5519c29c02ef0e02e13a543f882b152d4bfd2f06802f80"
	"image_picker_windows 0.2.1+1 6ad07afc4eb1bc25f3a01084d28520496c4a3bb0cb13685435838167c9dcedeb"
	"image_size_getter 2.2.0 0511799498340b70993d2dfb34b55a2247b5b801d75a6cdd4543acfcafdb12b0"
	"intl 0.19.0 d6f56758b7d3014a48af9701c085700aac781a92a87a62b1333b46d8879661cf"
	"io 1.0.4 2ec25704aba361659e10e3e5f5d672068d332fc8ac516421d483a11e5cbd061e"
	"js 0.6.7 f2c445dce49627136094980615a031419f7f3eb393237e4ecd97ac15dea343f3"
	"js 0.7.1 c1b2e9b5ea78c45e1a0788d29606ba27dc5f71f019f32ca5140f61ef071838cf"
	"json2yaml 3.0.1 da94630fbc56079426fdd167ae58373286f603371075b69bf46d848d63ba3e51"
	"json_annotation 4.8.1 b10a7b2ff83d83c777edba3c6a0f97045ddadd56c944e1a23a3fdf43a1bf4467"
	"json_annotation 4.9.0 1ce844379ca14835a50d2f019a3099f419082cfdd231cd86a142af94dd5c6bb1"
	"leak_tracker 10.0.5 3f87a60e8c63aecc975dda1ceedbc8f24de75f09e4856ea27daf8958f2f0ce05"
	"leak_tracker_flutter_testing 3.0.5 932549fb305594d82d7183ecd9fa93463e9914e1b67cacc34bc40906594a1806"
	"leak_tracker_testing 3.0.1 6ba465d5d76e67ddf503e1161d1f4a6bc42306f9d66ca1e8f079a47290fb06d3"
	"legalize 1.2.2 bc3068aa4f14588575c8b5ba2a9e608c242dad325e7f7c56fedd68adba33526a"
	"lints 2.1.1 0a217c6c989d21039f1498c3ed9f3ed71b354e69873f13a8dfc3c9fe76f1b452"
	"lints 5.0.0 3315600f3fb3b135be672bf4a178c55f274bebe368325ae18462c89ac1e3b413"
	"local_hero 0.3.0 5c85451dd51ecd0e8d3656775fac9a6db82f296f200d9931217186d34fed6089"
	"logging 1.2.0 623a88c9594aa774443aa3eb2d41807a48486b5613e67599fb4c41c0ad47c340"
	"logging 1.3.0 c8245ada5f1717ed44271ed1c26b8ce85ca3228fd2ffdb75468ab01979309d61"
	"macros 0.1.2-main.4 0acaed5d6b7eab89f63350bccd82119e6c602df0f391260d0e32b5e23db79536"
	"markdown 7.2.2 ef2a1298144e3f985cc736b22e0ccdaf188b5b3970648f2d9dc13efd1d9df051"
	"matcher 0.12.16 1803e76e6653768d64ed8ff2e1e67bea3ad4b923eb5c56a295c3e634bad5960e"
	"matcher 0.12.16+1 d2323aa2060500f906aa31a895b4030b6da3ebdcc5619d14ce1aada65cd161cb"
	"material_color_utilities 0.11.1 f7142bb1154231d7ea5f96bc7bde4bda2a0945d2806bb11670e30b850d56bdec"
	"matrix4_transform 3.0.1 42c42610deecc382be2653f4a21358537401bd5b027c168a174c7c6a64959908"
	"menu_base 0.1.1 820368014a171bd1241030278e6c2617354f492f5c703d7b7d4570a6b8b84405"
	"meta 1.15.0 bdb68674043280c3428e9ec998512fb681678676b3c54e773629ffe74419f8c7"
	"meta 1.9.1 3c74dbf8763d36539f114c799d8a2d87343b5067e9d796ca22b5eb8437090ee3"
	"mime 1.0.4 e4ff8e8564c03f255408decd16e7899da1733852a9110a58fe6d1b817684a63e"
	"mime 1.0.6 801fd0b26f14a4a58ccb09d5892c3fbdeff209594300a542492cf13fba9d247a"
	"mockito 5.4.4 6841eed20a7befac0ce07df8116c8b8233ed1f4486a7647c7fc5a02ae6163917"
	"moform 0.2.5 4ef955b2422b0c7c676128b398e417b191647b6a1259d3928000a9a40c63f571"
	"nanoid2 2.0.1 35b5048f836652a1d711db0d716bdee59fcaaa4c37792db8b3568da4f7feb2f9"
	"nested 1.0.0 03bac4c528c64c95c722ec99280375a6f2fc708eec17c7b3f07253b626cd2a20"
	"network_info_plus 6.1.1 bf9e39e523e9951d741868dc33ac386b0bc24301e9b7c8a7d60dbc34879150a8"
	"network_info_plus_platform_interface 2.0.1 b7f35f4a7baef511159e524499f3c15464a49faa5ec10e92ee0bce265e664906"
	"nm 0.5.0 2c9aae4127bdc8993206464fcc063611e0e36e72018696cd9631023a31b24254"
	"node_preamble 2.0.2 6e7eac89047ab8a8d26cf16127b5ed26de65209847630400f9aefd7cd5c730db"
	"open_dir 0.0.2+1 a4884b00e5e5795a9b4b3d582ac6a66e9196795ed760dbc3c63b4837c70c5901"
	"open_dir_linux 0.0.2+1 566cd9e02403971be06af35e1abc8057a4f3f98888c1226042e96a2af333b8bc"
	"open_dir_macos 0.0.2 51fdc8c3a06c9d571b599b5901045ada23d1440b24c3052c0a66cf3ee4ac901b"
	"open_dir_platform_interface 0.0.2 ca189abb02d8e3320f9b2493b6d58e3a33f393d5eb4ccbbef02e0bc0fd393872"
	"open_dir_windows 0.0.2+1 ec48df32ce61adb6f6cede0330d13b0d89714d2ee2df198f32ecd520e3a5d250"
	"open_filex 4.5.0 ba425ea49affd0a98a234aa9344b9ea5d4c4f7625a1377961eae9fe194c3d523"
	"package_config 2.1.0 1c5b77ccc91e4823a5af61ee74e6b972db1ef98c2ff5a18d3161c982a55448bd"
	"package_info_plus 8.1.1 da8d9ac8c4b1df253d1a328b7bf01ae77ef132833479ab40763334db13b91cce"
	"package_info_plus_platform_interface 3.0.1 ac1f4a4847f1ade8e6a87d1f39f5d7c67490738642e2542f559ec38c37489a66"
	"path 1.8.0 2ad4cddff7f5cc0e2d13069f2a3f7a73ca18f66abd6f5ecf215219cdb3638edb"
	"path 1.9.0 087ce49c3f0dc39180befefc60fdb4acd8f8620e5682fe2476afd0b3688bb4af"
	"path_parsing 1.1.0 883402936929eac138ee0a45da5b0f2c80f89913e6dc3bf77eb65b84b409c6ca"
	"path_provider 2.1.5 50c5dd5b6e1aaf6fb3a78b33f6aa3afca52bf903a8a5298f53101fdaee55bbcd"
	"path_provider_android 2.2.12 c464428172cb986b758c6d1724c603097febb8fb855aa265aeecc9280c294d4a"
	"path_provider_foundation 2.4.0 f234384a3fdd67f989b4d54a5d73ca2a6c422fa55ae694381ae0f4375cd1ea16"
	"path_provider_linux 2.2.1 f7a1fe3a634fe7734c8d3f2766ad746ae2a2884abe22e241a8b301bf5cac3279"
	"path_provider_platform_interface 2.1.2 88f5779f72ba699763fa3a3b06aa4bf6de76c8e5de842cf6f29e2e06476c2334"
	"path_provider_windows 2.3.0 bd6f00dbd873bfb70d0761682da2b3a2c2fccc2b9e84c495821639601d81afe7"
	"permission_handler 11.3.1 18bf33f7fefbd812f37e72091a15575e72d5318854877e0e4035a24ac1113ecb"
	"permission_handler_android 12.0.13 71bbecfee799e65aff7c744761a57e817e73b738fedf62ab7afd5593da21f9f1"
	"permission_handler_apple 9.4.5 e6f6d73b12438ef13e648c4ae56bd106ec60d17e90a59c4545db6781229082a0"
	"permission_handler_html 0.1.3+5 38f000e83355abb3392140f6bc3030660cfaef189e1f87824facb76300b4ff24"
	"permission_handler_platform_interface 4.2.3 e9c8eadee926c4532d0305dff94b85bf961f16759c3af791486613152af4b4f9"
	"petitparser 5.4.0 cb3798bef7fc021ac45b308f4b51208a152792445cce0448c9a4ba5879dd8750"
	"petitparser 6.0.2 c15605cd28af66339f8eb6fbe0e541bfe2d1b72d5825efc6598f3e0a31b9ad27"
	"photo_manager 3.6.2 ebe91591ec4148ddb4864352b2612a9c9e70c02384d27c8672d8ab604c7021e6"
	"photo_manager_image_provider 2.2.0 b6015b67b32f345f57cf32c126f871bced2501236c405aafaefa885f7c821e4f"
	"platform 3.1.6 5d6b1b0036a5f331ebc77c850ebc8506cbc1e9416c27e59b439f917a902a4984"
	"platform_linux 0.1.2 856cfc9871e3ff3df6926991729d24bba9b70d0229ae377fa08b562344baaaa8"
	"plugin_platform_interface 2.1.8 4820fbfdb9478b1ebae27888254d445073732dae3d6ea81f0b7e06d5dedc3f02"
	"pointycastle 3.9.1 4be0097fcf3fd3e8449e53730c631200ebc7b88016acecab2b0da2f0149222fe"
	"pool 1.5.1 20fe868b6314b322ea036ba325e6fc0711a22948856475e2c2b6306e8ab39c2a"
	"pretty_qr_code 3.3.0 cbdb4af29da1c1fa21dd76f809646c591320ab9e435d3b0eab867492d43607d5"
	"provider 6.1.2 c8a055ee5ce3fd98d6fc872478b03823ffdb448699c6ebdbbc71d59b596fd48c"
	"pub_semver 2.1.4 40d3ab1bbd474c4c2328c91e3a7df8c6dd629b79ece4c4bd04bee496a224fb0c"
	"pubspec_parse 1.3.0 c799b721d79eb6ee6fa56f00c04b472dcd44a30d258fac2174a6ec57302678f8"
	"qr 3.0.2 5a1d2586170e172b8a8c8470bbbffd5eb0cd38a66c0d77155ea138d3af3a4445"
	"refena 2.1.1 1446e9622451e0cffef2af5b3fd57a52f0688d7c9eb848e969c16ccc2d14e833"
	"refena_flutter 2.1.1 2e57bab72667f37b55f26675d46c0a362e6eb115a70605c90163736b85e97a42"
	"refena_inspector 2.0.3 717a19f70d9667e2459fd8dfd6a72b1306bd2c04bfc255bada4f2eb429ca4757"
	"refena_inspector_client 2.0.1 8bcc1e169bfc0e5ba448f4920067a0579c0b4a42fff39dbdfd4a743bf2b235a6"
	"rhttp 0.10.0 3deabc6c3384b4efa252dfb4a5059acc6530117fdc1b10f5f67ff9768c9af75a"
	"routerino 0.8.0 204affbe5304d107fec4df606a72deb34c4c9d75661d4357961f58d567bb448f"
	"saf_stream 0.10.0 d90bcbf0fe9e99065e3bab5d5711551b1911ed2001ad8cf94258081ed6f6b7b2"
	"screen_retriever 0.2.0 570dbc8e4f70bac451e0efc9c9bb19fa2d6799a11e6ef04f946d7886d2e23d0c"
	"screen_retriever_linux 0.2.0 f7f8120c92ef0784e58491ab664d01efda79a922b025ff286e29aa123ea3dd18"
	"screen_retriever_macos 0.2.0 71f956e65c97315dd661d71f828708bd97b6d358e776f1a30d5aa7d22d78a149"
	"screen_retriever_platform_interface 0.2.0 ee197f4581ff0d5608587819af40490748e1e39e648d7680ecf95c05197240c0"
	"screen_retriever_windows 0.2.0 449ee257f03ca98a57288ee526a301a430a344a161f9202b4fcc38576716fe13"
	"shared_preferences 2.5.2 846849e3e9b68f3ef4b60c60cf4b3e02e9321bc7f4d8c4692cf87ffa82fc8a3a"
	"shared_preferences_android 2.4.6 a768fc8ede5f0c8e6150476e14f38e2417c0864ca36bb4582be8e21925a03c22"
	"shared_preferences_foundation 2.5.3 07e050c7cd39bad516f8d64c455f04508d09df104be326d8c02551590a0d513d"
	"shared_preferences_linux 2.4.1 580abfd40f415611503cae30adf626e6656dfb2f0cee8f465ece7b6defb40f2f"
	"shared_preferences_platform_interface 2.4.1 57cbf196c486bc2cf1f02b85784932c6094376284b3ad5779d1b1c6c6a816b80"
	"shared_preferences_web 2.4.2 d2ca4132d3946fec2184261726b355836a82c33d7d5b67af32692aff18a4684e"
	"shared_preferences_windows 2.4.1 94ef0f72b2d71bc3e700e025db3710911bd51a71cefb65cc609dd0d9a982e3c1"
	"shared_storage 0.8.1 cf20428d06af065311b71e09cbfbbfe431e979a3bf9180001c1952129b7c708f"
	"share_handler 0.0.22 76575533be04df3fecbebd3c5b5325a8271b5973131f8b8b0ab8490c395a5d37"
	"share_handler_android 0.0.9 124dcc914fb7ecd89076d3dc28435b98fe2129a988bf7742f7a01dcb66a95667"
	"share_handler_ios 0.0.15 cdc21f88f336a944157a8e9ceb191525cee3b082d6eb6c2082488e4f09dc3ece"
	"share_handler_platform_interface 0.0.6 7a4df95a87b326b2f07458d937f2281874567c364b7b7ebe4e7d50efaae5f106"
	"shelf 1.4.1 ad29c505aee705f41a4d8963641f91ac4cee3c8fad5947e033390a7bd8180fa4"
	"shelf_packages_handler 3.0.2 89f967eca29607c933ba9571d838be31d67f53f6e4ee15147d5dc2934fee1b1e"
	"shelf_static 1.1.2 a41d3f53c4adf0f57480578c1d61d90342cd617de7fc8077b1304643c2d85c1e"
	"shelf_static 1.1.3 c87c3875f91262785dade62d135760c2c69cb217ac759485334c5857ad89f6e3"
	"shelf_web_socket 1.0.4 9ca081be41c60190ebcb4766b2486a7d50261db7bd0f5d9615f2d653637a84c1"
	"shelf_web_socket 2.0.0 073c147238594ecd0d193f3456a5fe91c4b0abbcc68bf5cd95b36c4e194ac611"
	"shortid 0.1.2 d0b40e3dbb50497dad107e19c54ca7de0d1a274eb9b4404991e443dadb9ebedb"
	"slang 4.4.0 4cdc3d8f4b384dbc56d94c87a5371d4a584460d82a74e18247ec690a0e369ff2"
	"slang_build_runner 4.4.0 2111b409ca65b0adf33db02f21cbe05eb557af920edc71038e2133657ed451c4"
	"slang_flutter 4.4.0 819637a23348adbc4f4e8faee3f274d8908f9af31d57bf1e277cd730b14bacde"
	"source_gen 1.5.0 14658ba5f669685cd3d63701d01b31ea748310f7ab854e471962670abcf57832"
	"source_maps 0.10.12 708b3f6b97248e5781f493b765c3337db11c5d2c81c3094f10904bfa8004c703"
	"source_map_stack_trace 2.1.1 84cf769ad83aa6bb61e0aa5a18e53aea683395f196a6f39c4c881fb90ed4f7ae"
	"source_map_stack_trace 2.1.2 c0713a43e323c3302c2abe2a1cc89aa057a387101ebd280371d6a6c9fa68516b"
	"source_span 1.10.0 53e943d4206a5e30df338fd4c6e7a077e02254531b138a15aec3bd143c1a8b3c"
	"sprintf 7.0.0 1fc9ffe69d4df602376b52949af107d8f5703b77cda567c4d7d86a0693120f23"
	"stack_trace 1.11.1 73713990125a6d93122541237550ee3352a2d84baad52d375a4cad2eb9b7ce0b"
	"stream_channel 2.1.2 ba2aa5d8cc609d96bbb2899c28934f9e1af5cddbd60a827822ea467161eb54e7"
	"stream_transform 2.1.0 14a00e794c7c11aa145a170587321aedce29769c08d7f58b1d141da75e3b1c6f"
	"string_scanner 1.2.0 556692adab6cfa87322a115640c11f13cb77b3f076ddcc5d6ae3c20242bedcde"
	"system_settings 2.1.0 666693f8dace789bcf1200a88f6132b6906026643a5ee93ff140d3a547e5faf1"
	"term_glyph 1.2.1 a29248a84fbb7c79282b40b8c72a1209db169a2e0542bce341da992fe1bc7e84"
	"test 1.24.6 9b0dd8e36af4a5b1569029949d50a52cb2a2a2fdaa20cebb96e6603b9ae241f9"
	"test 1.25.7 7ee44229615f8f642b68120165ae4c2a75fe77ae2065b1e55ae4711f6cf0899e"
	"test_api 0.6.1 5c2f730018264d276c20e4f1503fd1308dfbbae39ec8ee63c5236311ac06954b"
	"test_api 0.7.2 5b8a98dafc4d5c4c9c72d8b31ab2b23fc13422348d2997120294d3bac86b4ddb"
	"test_core 0.5.6 4bef837e56375537055fdbbbf6dd458b1859881f4c7e6da936158f77d61ab265"
	"test_core 0.6.4 55ea5a652e38a1dfb32943a7973f3681a60f872f8c3a05a14664ad54ef9c6696"
	"time 2.1.5 370572cf5d1e58adcb3e354c47515da3f7469dac3a95b447117e728e7be6f461"
	"timing 1.0.1 70a3b636575d4163c477e6de42f247a23b315ae20e86442bebe32d3cabf61c32"
	"toml 0.14.0 157c5dca5160fced243f3ce984117f729c788bb5e475504f3dbcda881accee44"
	"tray_manager 0.2.4 bdc3ac6c36f3d12d871459e4a9822705ce5a1165a17fa837103bc842719bf3f7"
	"typed_data 1.3.2 facc8d6582f16042dd49f2463ff1bd6e2c9ef9f3d5da3d9b087e244a7b564b3c"
	"typed_data 1.4.0 f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006"
	"type_plus 2.1.1 d5d1019471f0d38b91603adb9b5fd4ce7ab903c879d2fbf1a3f80a630a03fcc9"
	"uri_content 2.2.0 ad08e63cd995e2daeace00359399f368e3d5dfe381c1a37daa3f9901108b518e"
	"url_launcher 6.3.1 9d06212b1362abc2f0f0d78e6f09f726608c74e3b9462e8368bb03314aa8d603"
	"url_launcher_android 6.3.14 6fc2f56536ee873eeb867ad176ae15f304ccccc357848b351f6f0d8d4a40d193"
	"url_launcher_ios 6.3.1 e43b677296fadce447e987a2f519dcf5f6d1e527dc35d01ffab4fff5b8a7063e"
	"url_launcher_linux 3.2.1 4e9ba368772369e3e08f231d2301b4ef72b9ff87c31192ef471b380ef29a4935"
	"url_launcher_macos 3.2.1 769549c999acdb42b8bcfa7c43d72bf79a382ca7441ab18a808e101149daf672"
	"url_launcher_platform_interface 2.3.2 552f8a1e663569be95a8190206a38187b531910283c3e982193e4f2733f01029"
	"url_launcher_web 2.3.3 772638d3b34c779ede05ba3d38af34657a05ac55b06279ea6edd409e323dca8e"
	"url_launcher_windows 3.1.3 44cf3aabcedde30f2dba119a9dea3b0f2672fbe6fa96e85536251d678216b3c4"
	"uuid 4.5.1 a5be9ef6618a7ac1e964353ef476418026db906c4facdedaa299b7a2e71690ff"
	"vector_graphics_codec 1.1.12 2430b973a4ca3c4dbc9999b62b8c719a160100dcbae5c819bae0cacce32c9cdb"
	"vector_graphics_compiler 1.1.15 ab9ff38fc771e9ee1139320adbe3d18a60327370c218c60752068ebee4b49ab1"
	"vector_math 2.1.4 80b3257d1492ce4d091729e3a67a60407d227c27241d6927be0130c98e741803"
	"version 3.0.0 2307e23a45b43f96469eeab946208ed63293e8afca9c28cd8b5241ff31c55f55"
	"video_player 2.9.2 4a8c3492d734f7c39c2588a3206707a05ee80cef52e8c7f3b2078d430c84bc17"
	"video_player_android 2.7.16 391e092ba4abe2f93b3e625bd6b6a6ec7d7414279462c1c0ee42b5ab8d0a0898"
	"video_player_avfoundation 2.6.3 0b146e5d82e886ff43e5a46c6bcbe390761b802864a6e2503eb612d69a405dfa"
	"video_player_platform_interface 6.2.3 229d7642ccd9f3dc4aba169609dd6b5f3f443bb4cc15b82f7785fcada5af9bbb"
	"video_player_web 2.3.3 881b375a934d8ebf868c7fb1423b2bfaa393a0a265fa3f733079a86536064a10"
	"visibility_detector 0.4.0+2 dd5cc11e13494f432d15939c3aa8ae76844c42b723398643ce9addb88a5ed420"
	"vm_service 11.9.0 0fae432c85c4ea880b33b497d32824b97795b04cdaa74d270219572a1f50268d"
	"vm_service 14.2.5 5c5f338a667b4c644744b661f309fb8080bb94b18a7e91ef1dbd343bed00ed6d"
	"wakelock_plus 1.2.8 bf4ee6f17a2fa373ed3753ad0e602b7603f8c75af006d5b9bdade263928c0484"
	"wakelock_plus_platform_interface 1.2.1 422d1cdbb448079a8a62a5a770b69baa489f8f7ca21aef47800c726d404f9d16"
	"watcher 1.1.0 3d2ad6751b3c16cf07c7fca317a1413b3f26530319181b37e3b9039b84fc01d8"
	"web 1.1.0 cd3543bd5798f6ad290ea73d210f423502e71900302dde696f8bff84bf89a1cb"
	"webkit_inspection_protocol 1.2.0 67d3a8b6c79e1987d19d848b0892e582dbb0c66c57cc1fef58a177dd2aa2823d"
	"webkit_inspection_protocol 1.2.1 87d3f2333bb240704cd3f1c6b5b7acd8a10e7f0bc28c28dcf14e782014f4a572"
	"web_socket 0.1.6 3c12d96c0c9a4eec095246debcea7b86c0324f22df69893d538fcc6f1b8cce83"
	"web_socket_channel 2.4.0 d88238e5eac9a42bb43ca4e721edba3c08c6354d4a53063afaa568516217621b"
	"web_socket_channel 3.0.1 9f187088ed104edd8662ca07af4b124465893caf063ba29758f97af57e61da8f"
	"wechat_assets_picker 9.5.0 65104fff598394fcf1c9a75a8a65a7aa9687485534b44d6e85275774d015df45"
	"wechat_picker_library 1.0.5 a42e09cb85b15fc9410f6a69671371cc60aa99c4a1f7967f6593a7f665f6f47a"
	"win32 5.8.0 84ba388638ed7a8cb3445a320c8273136ab2631cd5f2c57888335504ddab1bc2"
	"win32_registry 1.1.5 21ec76dfc731550fd3e2ce7a33a9ea90b828fdf19a5c3bcf556fa992cfa99852"
	"window_manager 0.4.3 732896e1416297c63c9e3fb95aea72d0355f61390263982a47fd519169dc5059"
	"windows_taskbar 1.1.2 204edfdb280a7053febdf50fc9b49b3c007255bd8a83c082d10c174ec6548f33"
	"xdg_directories 1.1.0 7a3f37b05d989967cdddcbb571f1ea834867ae2faa29725fd085180e0883aa15"
	"xml 6.5.0 b015a8ad1c488f66851d762d3090a21c600e479dc75e68328c52774040cf9226"
	"yaml 3.1.2 75769501ea3489fca56601ff33454fe45507ea3bfb014161abc3b43ae25989d5"
	"yaru 5.3.2 afc659f78a0bef5e06ebbbd516979afceca7526b7703daa444bf419a54b2dc85"
	"yaru_window 0.2.1+1 bc2a1df3c6f33477b47f84bf0a9325df411dbb7bd483ac88e5bc1c019d2f2560"
	"yaru_window_linux 0.2.1 46a1a0743dfd45794cdaf8c5b3a48771ab73632b50a693f59c83b07988e96689"
	"yaru_window_manager 0.1.2+1 b36c909fa082a7cb6e2f259d4357e16f08d3d8ab086685b81d1916e457100d1e"
	"yaru_window_platform_interface 0.1.2+1 93493d7e17a9e887ffa94c518bc5a4b3eb5425c009446e3294c689cb1a87b7e1"
	"yaru_window_web 0.0.3+1 31468aeb515f72d5eeddcd62773094a4f48fee96f7f0494f8ce53ad3b38054f1"
)

PUB_GIT=(
	"pasteboard https://github.com/Seidko/flutter-plugins.git 58748dae405df5e68a131e4905d48e75d0624be2 packages/pasteboard"
	"permission_handler_windows https://github.com/localsend/permission_handler_windows_noop.git 2dadd8afbf81e0e3e4791d7144e689555e58f649 ."
)

# rust-vendor holds the vendored crates for the rhttp plugin's Rust build (pure source,
# cargo vendor of rhttp's Cargo.lock). See gentoo-zh-drafts/localsend.
SRC_URI="
	https://github.com/localsend/localsend/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/${PN}/releases/download/${PV}/${P}-rust-vendor.tar.xz
	$(dart-pub_src_uri)
"
S="${WORKDIR}/${PN}-${PV}/app"

LICENSE="Apache-2.0"
# Vendored Rust crate licenses (rhttp plugin dependencies)
LICENSE+="
	0BSD Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0 ISC MIT
	MPL-2.0 Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"

# The bundled Flutter engine library is a prebuilt blob; libapp.so (compiled Dart)
# and librhttp.so (Rust, strip = true) come out of the release build already stripped.
QA_PREBUILT="opt/${PN}/lib/libflutter_linux_gtk.so"
QA_PRESTRIPPED="
	opt/${PN}/lib/libapp.so
	opt/${PN}/lib/libflutter_linux_gtk.so
	opt/${PN}/lib/librhttp.so
"

BDEPEND="
	${RUST_DEPEND}
	dev-build/cmake
	dev-build/ninja
	~dev-util/flutter-bin-${_FLUTTER_VERSION}
	dev-util/patchelf
	dev-vcs/git
	virtual/pkgconfig
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
"
DEPEND="
	dev-libs/libayatana-appindicator
	x11-libs/gtk+:3
"
RDEPEND="
	${DEPEND}
	x11-misc/xdg-user-dirs
"

PATCHES=( "${FILESDIR}/${P}-drop-werror.patch" )

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_unpack() {
	# Only the app source and vendored Rust crates are unpacked; the Dart pub archives stay
	# in ${DISTDIR} and are laid out into the pub-cache by dart-pub_populate below.
	unpack "${P}.tar.gz"
	unpack "${P}-rust-vendor.tar.xz"

	# flutter needs a writable SDK (it locks bin/cache even to print its version); copy the
	# shared SDK, then add this app's pub.dev deps to its flutter_tools pub-cache.
	cp -a "${EPREFIX}"/opt/flutter "${WORKDIR}"/flutter || die
	chmod -R u+w "${WORKDIR}"/flutter || die
	dart-pub_populate "${WORKDIR}"/flutter/.pub-cache
}

src_prepare() {
	# Drop the proprietary in-app-purchase / donation code (upstream's FOSS build path).
	# The script cd's into app/ itself, so it must run from the repository root.
	pushd "${WORKDIR}/${PN}-${PV}" >/dev/null || die
	sh scripts/remove_proprietary_dependencies.sh || die
	popd >/dev/null || die

	default

	# The lockfile shipped in the tarball still lists the removed proprietary deps; drop it so
	# pub re-resolves offline against the FOSS pubspec.yaml and the fetched pub-cache.
	rm -f "${S}/pubspec.lock" || die

	export HOME="${T}"
	export PUB_CACHE="${WORKDIR}/flutter/.pub-cache"
	export FLUTTER_SUPPRESS_ANALYTICS=true

	# cargokit (the rhttp plugin's Rust build) drives the toolchain through rustup; shim it so
	# it uses the system Rust instead of downloading one.
	mkdir -p "${T}/bin" || die
	cat > "${T}/bin/rustup" <<-'RUSTUP' || die
		#!/bin/sh
		case "${1}" in
			toolchain) [ "${2}" = list ] && echo "stable-x86_64-unknown-linux-gnu (default)"; exit 0 ;;
			target)    echo "x86_64-unknown-linux-gnu"; exit 0 ;;
			run)       shift 2; exec "$@" ;;
			*)         exit 0 ;;
		esac
	RUSTUP
	chmod +x "${T}/bin/rustup" || die

	# Build the rhttp crates from the vendored sources, fully offline.
	mkdir -p "${T}/cargo-home" || die
	cat > "${T}/cargo-home/config.toml" <<-CARGO || die
		[source.crates-io]
		replace-with = "vendored-sources"

		[source.vendored-sources]
		directory = "${WORKDIR}/rust-vendor"
	CARGO

	# cargokit resolves its build_tool's Dart deps with a networked pub get; force it offline.
	sed -i 's/pub get --no-precompile/pub get --no-precompile --offline/g' \
		"${PUB_CACHE}"/hosted/pub.dev/rhttp-*/cargokit/run_build_tool.sh || die

	# flutter derives its version by running git in the SDK tree, which the build user does
	# not own; without this it reports 0.0.0-unknown and version solving fails.
	git config --global --add safe.directory '*' || die

	# Resolve the git dependencies (pasteboard, the permission_handler_windows noop) as local
	# path overrides so pub does not try to clone them inside the network sandbox.
	dart-pub_git_overrides "${S}"

	# Resolve flutter_tools' own deps offline first, then the project's, both from pub-cache.
	pushd "${WORKDIR}/flutter/packages/flutter_tools" >/dev/null || die
	"${WORKDIR}"/flutter/bin/cache/dart-sdk/bin/dart pub get --offline || die
	popd >/dev/null || die

	"${WORKDIR}"/flutter/bin/flutter --no-version-check pub get --offline || die

	# Regenerate the dart_mappable sources build_runner would produce (not shipped).
	# dart_mappable races itself across cores, so pin the run to one.
	taskset -c 0 "${WORKDIR}"/flutter/bin/dart run build_runner build \
		--delete-conflicting-outputs || die
}

src_compile() {
	export HOME="${T}"
	export PUB_CACHE="${WORKDIR}/flutter/.pub-cache"
	export FLUTTER_SUPPRESS_ANALYTICS=true
	export CARGO_HOME="${T}/cargo-home"
	export CARGO_NET_OFFLINE=true
	export PATH="${T}/bin:${PATH}"

	"${WORKDIR}"/flutter/bin/flutter --no-version-check build linux --release --no-pub || die
}

src_install() {
	local bundle="build/linux/x64/release/bundle"

	insinto /opt/${PN}
	doins -r "${bundle}"/{data,lib}
	exeinto /opt/${PN}
	doexe "${bundle}"/${PN}_app

	# The Flutter build bakes the build-tree ephemeral directory into each plugin's
	# RUNPATH; drop it (the libraries all sit next to each other under /opt/${PN}/lib).
	local plugin
	for plugin in "${ED}"/opt/${PN}/lib/lib*plugin.so; do
		[[ -e ${plugin} ]] || continue
		patchelf --remove-rpath "${plugin}" || die
	done

	dodir /opt/bin
	dosym -r /opt/${PN}/${PN}_app /opt/bin/${PN}

	newicon -s 128 assets/img/logo-128.png ${PN}.png
	newicon -s 256 assets/img/logo-256.png ${PN}.png

	domenu "${FILESDIR}"/${PN}.desktop
}
