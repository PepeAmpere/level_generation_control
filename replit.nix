{ pkgs }: {
  deps = [
      pkgs.lua5_4
      pkgs.sumneko-lua-language-server
      pkgs.love
  ];
}