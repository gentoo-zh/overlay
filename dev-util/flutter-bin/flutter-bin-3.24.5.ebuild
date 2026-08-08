# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dart-pub

DESCRIPTION="Flutter SDK (prebuilt), for building Flutter applications from source"
HOMEPAGE="https://flutter.dev/"

# flutter_tools (the SDK's own build tool) resolves these Dart dependencies the first
# time flutter runs; ship them as a pub-cache inside the SDK so consumers build offline.
# Regenerate with pubspec2ebuild.py on packages/flutter_tools/pubspec.lock from the SDK.
PUB_HOSTED=(
	"_fe_analyzer_shared 72.0.0 f256b0c0ba6c7577c15e2e4e114755640a875e885099367bf6e012b19314c834"
	"analyzer 6.7.0 b652861553cd3990d8ed361f7979dc6d7053a9ac8843fa73820ab68ce5410139"
	"archive 3.6.1 cb6a278ef2dbb298455e1a713bda08524a175630ec643a242c399c932a0a1f7d"
	"args 2.5.0 7cf60b9f0cc88203c5a190b4cd62a99feea42759a7fa695010eb5de1c0b2252a"
	"async 2.11.0 947bfcf187f74dbc5e146c9eb9c0f10c9f8b30743e341481c1e2ed3ecc18c20c"
	"boolean_selector 2.1.1 6cfb5af12253eaf2b368f07bacc5a80d1301a071c73360d746b7f2e32d762c66"
	"browser_launcher 1.1.1 6ee4c6b1f68a42e769ef6e663c4f56708522f7bce9d2ab6e308a37b612ffa4ec"
	"built_collection 5.1.1 376e3dd27b51ea877c28d525560790aee2e6fbb5f20e2f85d5081027d94e2100"
	"built_value 8.9.2 c7913a9737ee4007efedaffc968c049fd0f3d0e49109e778edc10de9426005cb"
	"checked_yaml 2.0.3 feb6bed21949061731a7a75fc5d2aa727cf160b91af9a3e464c5e3a32e28b5ff"
	"cli_config 0.2.0 ac20a183a07002b700f0c25e61b7ee46b23c309d76ab7b7640a028f18e4d99ec"
	"clock 1.1.1 cb6d7f03e1de671e34607e909a7213e31d7752be4fb66a86d29fe1eb14bfb5cf"
	"collection 1.18.0 ee67cb0715911d28db6bf4af1026078bd6f0128b07a5f66fb2ed94ec6783c09a"
	"completion 1.0.1 f11b7a628e6c42b9edc9b0bc3aa490e2d930397546d2f794e8e1325909d11c60"
	"convert 3.1.1 0f08b14755d163f6e2134cb58222dd25ea2a2ee8a195e53983d57c075324d592"
	"coverage 1.8.0 3945034e86ea203af7a056d98e98e42a5518fff200d6e8e6647e1886b07e936e"
	"crypto 3.0.3 ff625774173754681d66daaf4a448684fb04b78f902da9cb3d308c19cc5e8bab"
	"csslib 1.0.0 706b5707578e0c1b4b7550f64078f0a0f19dec3f50a178ffae7006b0a9ca58fb"
	"dap 1.3.0 c0e53b52c9529d901329045afc4c5acb04304a28acde4b54ab0a08a93da546aa"
	"dds 4.2.4+2 f3bca60b6b7d2b005268a1a579c82e38bec3d85cc85c332a872fe623c7ba94d7"
	"dds_service_extensions 2.0.0 390ae1d0128bb43ffe11f8e3c6cd3a481c1920492d1026883d379cee50bdf1a2"
	"devtools_shared 10.0.1 a6e66165629ec004cabd84e6971f502aeac07f1a5f6ffd9b3244cd05b1a06fb0"
	"dtd 2.2.0 58ac5c2d628e575dbcdfda44a698cd4c1212663e27fe5f8ced37aea85faa0d30"
	"dwds 24.0.0 61ebaabb04d779d040b47d3b4d0b3963449ced0920fb8efd81ca6d5e51ccfc1a"
	"extension_discovery 2.0.0 20735622d0763865f9d94c3ecdce4441174530870760253e9d364fb4f3da8688"
	"fake_async 1.3.1 511392330127add0b769b75a987850d136345d9227c6b94c96a04cf4a391bf78"
	"ffi 2.1.2 493f37e7df1804778ff3a53bd691d8692ddf69702cf4c1c1096a2e41b4779e21"
	"file 7.0.0 5fc22d7c25582e38ad9a8515372cd9a93834027aacf1801cf01164dac0ffa08c"
	"file_testing 3.0.0 0aaadb4025bd350403f4308ad6c4cea953278d9407814b8342558e4946840fb5"
	"fixnum 1.1.0 25517a4deb0c03aa0f32fd12db525856438902d9c16536311e76cdc57b31d7d1"
	"flutter_template_images 4.2.0 fd3e55af73c577b9e3f88d4080d3e366cb5c8ef3fbd50b94dfeca56bb0235df6"
	"frontend_server_client 4.0.0 f64a0333a82f30b0cca061bc3d143813a486dc086b574bfb233b7c1372427694"
	"glob 2.1.2 0e7014b3b7d4dac1ca4d6114f82bf1782ee86745b9b42a92c9289c23d8a0ab63"
	"graphs 2.3.1 aedc5a15e78fc65a6e23bcd927f24c64dd995062bcd1ca6eda65a3cff92a4d19"
	"html 0.15.4 3a7812d5bcd2894edf53dfaf8cd640876cf6cef50a8f238745c8b8120ea74d3a"
	"http 0.13.6 5895291c13fa8a3bd82e76d5627f69e0d85ca6a30dcac95c4ea19a5d555879c2"
	"http_multi_server 3.2.1 97486f20f9c2f7be8f514851703d0119c3596d14ea63227af6f7a481ef2b2f8b"
	"http_parser 4.0.2 2aa08ce0341cc9b354a498388e30986515406668dbcc4f7c950c3e715496693b"
	"intl 0.19.0 d6f56758b7d3014a48af9701c085700aac781a92a87a62b1333b46d8879661cf"
	"io 1.0.4 2ec25704aba361659e10e3e5f5d672068d332fc8ac516421d483a11e5cbd061e"
	"js 0.7.1 c1b2e9b5ea78c45e1a0788d29606ba27dc5f71f019f32ca5140f61ef071838cf"
	"json_annotation 4.9.0 1ce844379ca14835a50d2f019a3099f419082cfdd231cd86a142af94dd5c6bb1"
	"json_rpc_2 3.0.2 5e469bffa23899edacb7b22787780068d650b106a21c76db3c49218ab7ca447e"
	"logging 1.2.0 623a88c9594aa774443aa3eb2d41807a48486b5613e67599fb4c41c0ad47c340"
	"macros 0.1.2-main.4 0acaed5d6b7eab89f63350bccd82119e6c602df0f391260d0e32b5e23db79536"
	"matcher 0.12.16+1 d2323aa2060500f906aa31a895b4030b6da3ebdcc5619d14ce1aada65cd161cb"
	"meta 1.15.0 bdb68674043280c3428e9ec998512fb681678676b3c54e773629ffe74419f8c7"
	"mime 1.0.5 2e123074287cc9fd6c09de8336dae606d1ddb88d9ac47358826db698c176a1f2"
	"multicast_dns 0.3.2+7 982c4cc4cda5f98dd477bddfd623e8e4bd1014e7dbf9e7b05052e14a5b550b99"
	"mustache_template 2.0.0 a46e26f91445bfb0b60519be280555b06792460b27b19e2b19ad5b9740df5d1c"
	"native_assets_builder 0.7.0 e6612ad01cbc3c4d1b00a1a42aa25aa567950ab10ae1f95721574923540f3bd8"
	"native_assets_cli 0.6.0 f54ddc4a3f8cff1d8d63723b4938902da7586a5a47fe3c1bfa226eb80223f32e"
	"native_stack_traces 0.5.7 64d2f4bcf3b69326fb9bc91b4dd3a06f94bb5bbc3a65e25ae6467ace0b34bfd3"
	"node_preamble 2.0.2 6e7eac89047ab8a8d26cf16127b5ed26de65209847630400f9aefd7cd5c730db"
	"package_config 2.1.0 1c5b77ccc91e4823a5af61ee74e6b972db1ef98c2ff5a18d3161c982a55448bd"
	"path 1.9.0 087ce49c3f0dc39180befefc60fdb4acd8f8620e5682fe2476afd0b3688bb4af"
	"petitparser 6.0.2 c15605cd28af66339f8eb6fbe0e541bfe2d1b72d5825efc6598f3e0a31b9ad27"
	"platform 3.1.5 9b71283fc13df574056616011fb138fd3b793ea47cc509c189a6c3fa5f8a1a65"
	"pool 1.5.1 20fe868b6314b322ea036ba325e6fc0711a22948856475e2c2b6306e8ab39c2a"
	"process 5.0.2 21e54fd2faf1b5bdd5102afd25012184a6793927648ea81eea80552ac9405b32"
	"pub_semver 2.1.4 40d3ab1bbd474c4c2328c91e3a7df8c6dd629b79ece4c4bd04bee496a224fb0c"
	"pubspec_parse 1.3.0 c799b721d79eb6ee6fa56f00c04b472dcd44a30d258fac2174a6ec57302678f8"
	"shelf 1.4.1 ad29c505aee705f41a4d8963641f91ac4cee3c8fad5947e033390a7bd8180fa4"
	"shelf_packages_handler 3.0.2 89f967eca29607c933ba9571d838be31d67f53f6e4ee15147d5dc2934fee1b1e"
	"shelf_proxy 1.0.4 a71d2307f4393211930c590c3d2c00630f6c5a7a77edc1ef6436dfd85a6a7ee3"
	"shelf_static 1.1.2 a41d3f53c4adf0f57480578c1d61d90342cd617de7fc8077b1304643c2d85c1e"
	"shelf_web_socket 1.0.4 9ca081be41c60190ebcb4766b2486a7d50261db7bd0f5d9615f2d653637a84c1"
	"source_map_stack_trace 2.1.1 84cf769ad83aa6bb61e0aa5a18e53aea683395f196a6f39c4c881fb90ed4f7ae"
	"source_maps 0.10.12 708b3f6b97248e5781f493b765c3337db11c5d2c81c3094f10904bfa8004c703"
	"source_span 1.10.0 53e943d4206a5e30df338fd4c6e7a077e02254531b138a15aec3bd143c1a8b3c"
	"sse 4.1.5 fdce3a4ac3ae1c01083d05ded0bcdb7e02857ca2323823548e9e76d2f61638f0"
	"stack_trace 1.11.1 73713990125a6d93122541237550ee3352a2d84baad52d375a4cad2eb9b7ce0b"
	"standard_message_codec 0.0.1+4 fc7dd712d191b7e33196a0ecf354c4573492bb95995e7166cb6f73b047f9cae0"
	"stream_channel 2.1.2 ba2aa5d8cc609d96bbb2899c28934f9e1af5cddbd60a827822ea467161eb54e7"
	"string_scanner 1.2.0 556692adab6cfa87322a115640c11f13cb77b3f076ddcc5d6ae3c20242bedcde"
	"sync_http 0.3.1 7f0cd72eca000d2e026bcd6f990b81d0ca06022ef4e32fb257b30d3d1014a961"
	"term_glyph 1.2.1 a29248a84fbb7c79282b40b8c72a1209db169a2e0542bce341da992fe1bc7e84"
	"test 1.25.7 7ee44229615f8f642b68120165ae4c2a75fe77ae2065b1e55ae4711f6cf0899e"
	"test_api 0.7.2 5b8a98dafc4d5c4c9c72d8b31ab2b23fc13422348d2997120294d3bac86b4ddb"
	"test_core 0.6.4 55ea5a652e38a1dfb32943a7973f3681a60f872f8c3a05a14664ad54ef9c6696"
	"typed_data 1.3.2 facc8d6582f16042dd49f2463ff1bd6e2c9ef9f3d5da3d9b087e244a7b564b3c"
	"unified_analytics 6.1.2 916215af2dc2f54a204c6bfbc645ec401b6a150048764814379f42e09b557d2d"
	"usage 4.1.1 0bdbde65a6e710343d02a56552eeaefd20b735e04bfb6b3ee025b6b22e8d0e15"
	"uuid 3.0.7 648e103079f7c64a36dc7d39369cabb358d377078a051d6ae2ad3aa539519313"
	"vm_service 14.2.5 5c5f338a667b4c644744b661f309fb8080bb94b18a7e91ef1dbd343bed00ed6d"
	"vm_service_interface 1.1.0 f827453d9a3f8ceae04e389810da26f9b67636bdd13aa2dd9405b110c4daf59c"
	"vm_snapshot_analysis 0.7.6 5a79b9fbb6be2555090f55b03b23907e75d44c3fd7bdd88da09848aa5a1914c8"
	"watcher 1.1.0 3d2ad6751b3c16cf07c7fca317a1413b3f26530319181b37e3b9039b84fc01d8"
	"web 0.5.1 97da13628db363c635202ad97068d47c5b8aa555808e7a9411963c533b449b27"
	"web_socket_channel 2.4.5 58c6666b342a38816b2e7e50ed0f1e261959630becd4c879c4f26bfa14aa5a42"
	"webdriver 3.0.3 003d7da9519e1e5f329422b36c4dcdf18d7d2978d1ba099ea4e45ba490ed845e"
	"webkit_inspection_protocol 1.2.1 87d3f2333bb240704cd3f1c6b5b7acd8a10e7f0bc28c28dcf14e782014f4a572"
	"xml 6.5.0 b015a8ad1c488f66851d762d3090a21c600e479dc75e68328c52774040cf9226"
	"yaml 3.1.2 75769501ea3489fca56601ff33454fe45507ea3bfb014161abc3b43ae25989d5"
	"yaml_edit 2.2.1 e9c1a3543d2da0db3e90270dbb1e4eebc985ee5e3ffe468d83224472b2194a5f"
)

SRC_URI="
	https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${PV}-stable.tar.xz
	$(dart-pub_src_uri)
"
S="${WORKDIR}/flutter"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="mirror strip"

# Prebuilt Dart VM and Flutter engine binaries live under bin/cache.
QA_PREBUILT="*"

RDEPEND="sys-libs/glibc"

# The flutter tool writes a lockfile under bin/cache even for `flutter --version`, so the SDK
# cannot be invoked from its read-only install path and this package ships no /usr/bin wrapper.
# A consumer DEPENDs on it and copies /opt/flutter into its own writable build tree first; see
# net-misc/rustdesk for the pattern.

src_unpack() {
	# Only the SDK tarball is unpacked; the pub archives stay in ${DISTDIR} and are laid
	# out into the pub-cache by dart-pub_populate at install time.
	unpack "flutter_linux_${PV}-stable.tar.xz"
}

src_prepare() {
	default
	# Windows launchers are useless on Linux.
	rm -f bin/*.bat || die
}

src_install() {
	dodir /opt
	cp -a "${S}" "${ED}"/opt/flutter || die

	# flutter_tools' dependencies as a pub-cache inside the SDK; a consumer copies this
	# into its writable build tree as the base cache and adds its own app dependencies.
	dart-pub_populate "${ED}"/opt/flutter/.pub-cache
}
