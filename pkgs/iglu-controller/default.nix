{ buildBunApplication
, fetchFromGitHub
}:

buildBunApplication {
  src = fetchFromGitHub {
    owner = "iglu-api";
    repo = "controller";
    hash = "sha256-9w4SevhSrT4SUv5I1T786uUWTE33oq3kcOylRaKYTK4=";
    rev = "main";
  };

  nodeModuleHash = "sha256-iJfo8sXM/CJ9rVaDRNlYVGvCziYYFDtzfSrAns1oOH4=";

  bunExtraArgs = "--bun";
  bunScript = "start";

  filesToInstall = [
    "src"
    "public"
    "next.config.ts"
  ];

  buildOutput = [
    ".next"
  ];

  nodeModulesToKeep = [
    "next"
    "styled-jsx"
    "@swc"
    "@next"
    "react"
    "caniuse-lite"
  ];

  nodeExecToKeep = [
    "next"
  ];

  buildPhase = ''
    bun run --bun build
  '';
}
