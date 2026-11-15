{
  description = "Среда сборки ВКР: XeLaTeX + latexmk + Times New Roman";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ "corefonts" ];
      };
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = pkgsFor system;

          tex = pkgs.texliveSmall.withPackages (ps: with ps; [
            xetex
            latexmk
            collection-langcyrillic
            collection-fontsrecommended
            fontspec
            polyglossia
            unicode-math
            extsizes
            caption
            titlesec
            booktabs
            setspace
            tex-gyre-math
          ]);

          fontsConf = pkgs.makeFontsConf {
            fontDirectories = [ pkgs.corefonts pkgs.liberation_ttf ];
          };
        in
        {
          default = pkgs.mkShell {
            name = "vkr";

            packages = [
              tex
              pkgs.poppler-utils
              pkgs.qpdf
            ];

            FONTCONFIG_FILE = "${fontsConf}";

            shellHook = ''
              unset LD_LIBRARY_PATH
              export VKR_ENV=1
              echo "ВКР: $(xelatex --version | head -1 | sed 's/^XeTeX [^ ]* //'), latexmk $(latexmk -v | sed -n 's/.*Version \([0-9.]*\).*/\1/p')"
              echo "Сборка: ./compile.sh thesis/thesis.tex"
            '';
          };
        });
    };
}
