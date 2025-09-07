{
  pkgs,
  config,
  ...
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
  packageName = cargoToml.package.name;
  packageVersion = cargoToml.package.version;
  packageDescription = cargoToml.package.description or "";
  package = config.languages.rust.import ./. { };
in
{
  dotenv.enable = true;
  imports = [
    ./nix/rust.nix
  ];
  packages = [
    package
  ];
  outputs = {
    # "${packageName}" = package;
    default = package;
  };
  enterShell = ''
    clear
    ${pkgs.figlet}/bin/figlet "${packageName}"
    echo 
    {
      ${pkgs.lib.optionalString (packageDescription != "") ''echo "• ${packageDescription}"''}
      echo -e "• \033[1mv${packageVersion}\033[0m"
      echo -e " \033[0;32m✓\033[0m Development environment ready"
    } | ${pkgs.boxes}/bin/boxes -d stone -a l -i none
    echo
  '';
}
