{ lib
, nodejs-slim_latest
, bun
, stdenv
, makeWrapper
, ...
}:
{ src
, nodeModuleHash
, nativeBuildInputs ? []
, buildInputs ? []
, buildPhase ? ""
, configurePhase ? ""
, installPhase ? ""
, postInstall ? ""
, bunScript ? "start"
, bunExtraArgs ? ""
, filesToInstall ? [ "*.ts" ]
, buildOutput ? [ ]
, nodeModulesToKeep ? [ ]
, nodeExecToKeep ? [ ]
, extraWrapScript ? ""
}:

let
  packageJSON = lib.importJSON "${src}/package.json";
  inherit (packageJSON) version;
  pname = packageJSON.name;

  wrapScript = extraWrapScript + ''
    cd \$CWD
    bun run ${bunExtraArgs} ${bunScript}
  '';

  nodeModules = stdenv.mkDerivation {
    pname = "${pname}_node-modules";
    inherit src version;

    nativeBuildInputs = [ bun ] ++ nativeBuildInputs;
    buildInputs = [ nodejs-slim_latest ] ++ buildInputs;

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR

      bun install --no-progress --frozen-lockfile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      mv node_modules $out/

      runHook postInstall
    '';

    outputHash = nodeModuleHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [
    nodeModules
    nodejs-slim_latest
    makeWrapper
  ];

  buildInputs = [ bun ];

  configurePhase = ''
    runHook preConfigure

    cp -a ${nodeModules}/node_modules ./node_modules
    chmod -R u+rw node_modules
    chmod -R u+x node_modules/.bin
    patchShebangs node_modules

    export HOME=$TMPDIR
    export PATH="$PWD/node_modules/.bin:$PATH"

    ${configurePhase}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ${buildPhase}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname}/
    mkdir $out/bin

    ${installPhase}

    for file in ${lib.strings.concatMapStrings (x: " " + x) (filesToInstall ++ [ "package.json" ])}; do
      cp -r $src/$file $out/share/${pname}/
    done

    for file in ${lib.strings.concatMapStrings (x: " " + x) buildOutput}; do
      cp -r $file $out/share/${pname}/
    done

    ${if (nodeModulesToKeep != [ ]) then "mkdir -p $out/share/${pname}/node_modules" else ""}

    for file in ${lib.strings.concatMapStrings (x: " " + x) nodeModulesToKeep}; do
      cp -r ./node_modules/$file $out/share/${pname}/node_modules/
    done

    ${if (nodeExecToKeep != [ ]) then "mkdir -p $out/share/${pname}/node_modules/.bin" else ""}

    for file in ${lib.strings.concatMapStrings (x: " " + x) nodeExecToKeep}; do
      cp -r ./node_modules/.bin/$file $out/share/${pname}/node_modules/.bin/
    done

    echo "${wrapScript}" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        lib.makeBinPath[
          bun
        ]
      } \
      --prefix CWD : $out/share/${pname}/
  '';
}
