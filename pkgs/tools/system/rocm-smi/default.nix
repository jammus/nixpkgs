{ lib, stdenv, fetchFromGitHub, writeScript, cmake, wrapPython }:

stdenv.mkDerivation rec {
  pname = "rocm-smi";
  version = "5.2.3";

  src = fetchFromGitHub {
    owner = "RadeonOpenCompute";
    repo = "rocm_smi_lib";
    rev = "rocm-${version}";
    hash = "sha256-D3ZH6xJe2C9rUCsJPOf9QlStecU90/iYi4wrXVvPff0=";
  };

  nativeBuildInputs = [ cmake wrapPython ];

  postPatch = ''
    # Upstream ROCm is installed in an /opt directory. For this reason,
    # it does not completely follow FHS layout, creating top-level
    # rocm_smi, oam, and bindings top-level directories. Since rocm-smi
    # is a package that is typically installed, we change the paths to
    # follow FHS more closely.

    # rocm_smi libraries and headers go into lib and include. Bindings
    # go into lib/rocm_smi/bindings.
    substituteInPlace rocm_smi/CMakeLists.txt \
      --replace "DESTINATION rocm_smi/" "DESTINATION " \
      --replace "DESTINATION bindings" "DESTINATION lib/rocm_smi/bindings" \
      --replace "../rocm_smi/bindings/rsmiBindings.py" "../lib/rocm_smi/bindings/rsmiBindings.py" \
      --replace 'DESTINATION ''${ROCM_SMI}/' "DESTINATION "

    # oam libraries and headers go into lib and include.
    substituteInPlace oam/CMakeLists.txt \
      --replace "DESTINATION oam/" "DESTINATION " \
      --replace 'DESTINATION ''${OAM_NAME}/' "DESTINATION "
  '';

  postInstall = ''
    wrapPythonProgramsIn $out
  '';

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    version="$(curl -sL "https://api.github.com/repos/RadeonOpenCompute/rocm_smi_lib/releases?per_page=1" | jq '.[0].tag_name | split("-") | .[1]' --raw-output)"
    update-source-version rocm-smi "$version"
  '';

  meta = with lib; {
    description = "System management interface for AMD GPUs supported by ROCm";
    homepage = "https://github.com/RadeonOpenCompute/rocm_smi_lib";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ lovesegfault ];
    platforms = [ "x86_64-linux" ];
  };
}
