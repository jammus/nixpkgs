{ buildPythonApplication
, colorama
, decli
, fetchFromGitHub
, git
, jinja2
, lib
, packaging
, poetry
, pytest-freezegun
, pytest-mock
, pytest-regressions
, pytestCheckHook
, pyyaml
, questionary
, termcolor
, tomlkit
, typing-extensions
, argcomplete
}:

buildPythonApplication rec {
  pname = "commitizen";
  version = "2.35.0";

  src = fetchFromGitHub {
    owner = "commitizen-tools";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9ek6m5k01sGVHwqWXjWYDsPmIeAgK+H23D9sF5hjrf0=";
    deepClone = true;
  };

  format = "pyproject";

  nativeBuildInputs = [ poetry ];

  propagatedBuildInputs = [
    termcolor
    questionary
    colorama
    decli
    tomlkit
    jinja2
    pyyaml
    argcomplete
    typing-extensions
    packaging
  ];

  doCheck = true;

  checkInputs = [
    pytestCheckHook
    pytest-freezegun
    pytest-mock
    pytest-regressions
    argcomplete
    git
  ];

  # the tests require a functional git installation
  # which requires a valid HOME directory.
  preCheck = ''
    export HOME="$(mktemp -d)"

    git config --global user.name "Nix Builder"
    git config --global user.email "nix-builder@nixos.org"
    git init .
  '';

  # NB: These tests require complex GnuPG setup
  disabledTests = [
    "test_bump_minor_increment_signed"
    "test_bump_minor_increment_signed_config_file"
    "test_bump_on_git_with_hooks_no_verify_enabled"
    "test_bump_on_git_with_hooks_no_verify_disabled"
    "test_bump_pre_commit_changelog"
    "test_bump_pre_commit_changelog_fails_always"
    "test_get_commits_with_signature"
  ];

  meta = with lib; {
    description = "Tool to create committing rules for projects, auto bump versions, and generate changelogs";
    homepage = "https://github.com/commitizen-tools/commitizen";
    license = licenses.mit;
    maintainers = with maintainers; [ lovesegfault anthonyroussel ];
  };
}
