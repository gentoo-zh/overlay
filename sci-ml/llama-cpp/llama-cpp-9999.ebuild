# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="6.3"

inherit cmake cuda rocm linux-info

TINY_LLAMAS_COMMIT="99dd1a73db5a37100bd4ae633f4cfce6560e1567"

DESCRIPTION="LLM inference in C/C++"
HOMEPAGE="https://github.com/ggml-org/llama.cpp"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ggml-org/llama.cpp.git"
else
	MY_PV="b${PV#0_pre}"
	SRC_URI="
		https://github.com/ggml-org/llama.cpp/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz
		webui? (
			https://github.com/ggml-org/llama.cpp/releases/download/${MY_PV}/llama-${MY_PV}-ui.tar.gz -> ${P}-ui.tar.gz
		)
	"
	S="${WORKDIR}/llama.cpp-${MY_PV}"
	KEYWORDS="~amd64 ~riscv"
fi

SRC_URI+="
	examples? (
		https://huggingface.co/ggml-org/tiny-llamas/resolve/${TINY_LLAMAS_COMMIT}/stories15M-q4_0.gguf
			-> ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf
	)
"

LICENSE="MIT"
SLOT="0"

X86_CPU_FLAGS=(
	sse4_2
	avx
	avx_vnni
	avx2
	bmi2
	avx512f avx512cd avx512vl avx512dq avx512bw
	avx512vbmi
	avx512_vnni
	avx512_bf16
	fma3
	f16c
	amx_tile
	amx_int8
	amx_bf16
)
RISCV_CPU_FLAGS=( v zba zfh zvfh zicbop zihintpause xtheadvector )
CPU_FLAGS=(
	"${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}"
	"${RISCV_CPU_FLAGS[@]/#/cpu_flags_riscv_}"
)

IUSE="openblas +openmp blis rocm cuda opencl vulkan flexiblas wmma examples rpc +server webui ${CPU_FLAGS[*]}"

REQUIRED_USE="
	?? ( openblas blis flexiblas )
	rocm? ( ${ROCM_REQUIRED_USE} !riscv )
	wmma? ( rocm )
	webui? ( server )
"

CDEPEND="
	dev-libs/openssl
	openmp? ( llvm-runtimes/openmp:= )
	openblas? ( sci-libs/openblas:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}
		>=sci-libs/hipBLAS-${ROCM_VERSION}
		wmma? ( >=sci-libs/rocWMMA-${ROCM_VERSION} )
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
"
DEPEND="${CDEPEND}
	opencl? ( dev-util/opencl-headers )
	vulkan? ( dev-util/vulkan-headers )
"
RDEPEND="${CDEPEND}
	opencl? ( dev-libs/opencl-icd-loader )
	vulkan? ( media-libs/vulkan-loader )
"
BDEPEND="
	vulkan? ( media-libs/shaderc )
"

pkg_setup() {
	if use rocm; then
		linux-info_pkg_setup
		if linux-info_get_any_version && linux_config_exists; then
			if ! linux_chkconfig_present HSA_AMD_SVM; then
				ewarn "To use ROCm/HIP, you need to have HSA_AMD_SVM option enabled in your kernel."
			fi
		fi
	fi
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	if use webui; then
		if [[ ${PV} == *9999* ]]; then
			mkdir -p "${S}/tools/ui/dist"
			einfo Downloading webui dist from huggingface bucket...
			wget -qO - "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/dist.tar.gz" \
				| tar -xzf - -C "${S}/tools/ui/dist"
		else
			ln -s "${WORKDIR}/llama-${MY_PV}" "${S}/tools/ui/dist" || die
		fi
		echo "{\"version\":\"${MY_PV}\"}" > "${S}/tools/ui/dist/build.json"
	fi
}

src_prepare() {
	use cuda && cuda_src_prepare
	cmake_src_prepare
	if use examples; then
		mkdir -p "${BUILD_DIR}/tinyllamas" || die
		cp "${DISTDIR}/ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf" \
			"${BUILD_DIR}/tinyllamas/stories15M-q4_0.gguf" || die
	fi
}

src_configure() {
	if [[ ${PV} == *9999* ]]; then
		local mycmakeargs=(
			-DLLAMA_BUILD_NUMBER="$(git rev-list --count HEAD)"
			-DLLAMA_BUILD_COMMIT="$(git rev-parse HEAD)"
		)
	else
		local mycmakeargs=( -DLLAMA_BUILD_NUMBER="${MY_PV#b}" )
	fi

	mycmakeargs+=(
		-DGGML_CCACHE=OFF
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DLLAMA_BUILD_TESTS=OFF
		-DLLAMA_BUILD_EXAMPLES="$(usex examples)"
		-DLLAMA_BUILD_SERVER="$(usex server)"
		-DLLAMA_BUILD_UI="$(usex webui)"

		-DGGML_RPC="$(usex rpc)"
		-DGGML_OPENCL="$(usex opencl)"
		-DGGML_OPENMP="$(usex openmp)"
		-DGGML_VULKAN="$(usex vulkan)"

		-DGGML_NATIVE=OFF
	)

	if [[ ${ARCH} = "amd64" ]]; then
		mycmakeargs+=(
			-DGGML_SSE42="$(usex cpu_flags_x86_sse4_2)"
			-DGGML_AVX="$(usex cpu_flags_x86_avx)"
			-DGGML_AVX_VNNI="$(usex cpu_flags_x86_avx_vnni)"
			-DGGML_AVX2="$(usex cpu_flags_x86_avx2)"
			-DGGML_BMI2="$(usex cpu_flags_x86_bmi2)"
			-DGGML_AVX512_VBMI="$(usex cpu_flags_x86_avx512vbmi)"
			-DGGML_AVX512_VNNI="$(usex cpu_flags_x86_avx512_vnni)"
			-DGGML_AVX512_BF16="$(usex cpu_flags_x86_avx512_bf16)"
			-DGGML_FMA="$(usex cpu_flags_x86_fma3)"
			-DGGML_F16C="$(usex cpu_flags_x86_f16c)"
			-DGGML_AMX_TILE="$(usex cpu_flags_x86_amx_tile)"
			-DGGML_AMX_INT8="$(usex cpu_flags_x86_amx_int8)"
			-DGGML_AMX_BF16="$(usex cpu_flags_x86_amx_bf16)"
		)
		if use cpu_flags_x86_avx512f &&
			use cpu_flags_x86_avx512cd &&
			use cpu_flags_x86_avx512vl &&
			use cpu_flags_x86_avx512dq &&
			use cpu_flags_x86_avx512bw; then
			mycmakeargs+=( -DGGML_AVX512=ON )
		else
			mycmakeargs+=( -DGGML_AVX512=OFF )
		fi
	elif [[ ${ARCH} = "riscv" ]]; then
		mycmakeargs+=(
			-DGGML_RVV="$(usex cpu_flags_riscv_v)"
			-DGGML_RV_ZFH="$(usex cpu_flags_riscv_zfh)"
			-DGGML_RV_ZVFH="$(usex cpu_flags_riscv_zvfh)"
			-DGGML_RV_ZICBOP="$(usex cpu_flags_riscv_zicbop)"
			-DGGML_RV_ZIHINTPAUSE="$(usex cpu_flags_riscv_zihintpause)"
			-DGGML_XTHEADVECTOR="$(usex cpu_flags_riscv_xtheadvector)"
		)
	fi

	if use openblas || use blis || use flexiblas; then
		mycmakeargs+=( -DGGML_BLAS=ON )
		if use openblas; then
			mycmakeargs+=( -DGGML_BLAS_VENDOR=OpenBLAS )
		elif use blis; then
			mycmakeargs+=( -DGGML_BLAS_VENDOR=FLAME )
		elif use flexiblas; then
			mycmakeargs+=( -DGGML_BLAS_VENDOR=FlexiBLAS )
		fi
	fi

	if use cuda; then
		mycmakeargs+=( -DGGML_CUDA=ON )
		local -x CUDAHOSTCXX="$(cuda_gccdir)"
		# tries to recreate dev symlinks
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		export HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)"
		mycmakeargs+=(
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
			-DGGML_HIP=ON
			-DGGML_HIP_ROCWMMA_FATTN="$(usex wmma)"
		)
	fi

	cmake_src_configure
}
