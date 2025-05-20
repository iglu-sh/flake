{ buildBunApplication
, fetchFromGitHub
}:

buildBunApplication {
  src = fetchFromGitHub {
    owner = "iglu-api";
    repo = "cache";
    hash = "sha256-VvxCcpZokbKHKHe8CWDgJlcME/tf8L9qCqwE1YE71Kw=";
    rev = "main";
  };

  nodeModuleHash = "sha256-yLSf11QbDZ09DXlAupAyhNBKDFRt4lA+Z2UH+bxaOrw=";

  bunScript = "prod";

  filesToInstall = [
    "index.ts"
    "routes"
    "utils"
  ];
}
