{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "civo";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "civo";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-KwzQnjLmss8udSCKncoASZlO+G9ch7pZp6Iql+YV1nQ=";
  };

  vendorHash = "sha256-jW1pJ/UmeFsIEVvrwxcQuWwPQFHYkJBFnxGei41pz2U=";

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  # Some lint checks fail
  doCheck = false;

  ldflags = [
    "-s"
    "-X github.com/civo/cli/common.VersionCli=${version}"
    "-X github.com/civo/cli/common.CommitCli=${src.rev}"
    "-X github.com/civo/cli/common.DateCli=unknown"
  ];

  doInstallCheck = false;

  postInstall = ''
    mv $out/bin/cli $out/bin/civo
    installShellCompletion --cmd civo \
      --bash <($out/bin/civo completion bash) \
      --fish <($out/bin/civo completion fish) \
      --zsh <($out/bin/civo completion zsh)
  '';

  meta = {
    description = "CLI for interacting with Civo resources";
    mainProgram = "civo";
    homepage = "https://github.com/civo/cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      techknowlogick
      rytswd
    ];
  };
}
