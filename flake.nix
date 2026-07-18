{
  description = "A headless GStreamer pipeline package suite optimized for server environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Define the architectures you are targeting
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Helper function to generate outputs for each system
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = import nixpkgs { inherit system; };
        
        # Your custom headless override function
        makeHeadlessGst = p: rec {
          gstreamer = p.gst_all_1.gstreamer;
          gst-libav = p.gst_all_1.gst-libav;
          gst-plugins-bad = p.gst_all_1.gst-plugins-bad;
          gst-plugins-rs = p.gst_all_1.gst-plugins-rs;

          gst-plugins-base = p.gst_all_1.gst-plugins-base.override {
            enableX11 = false;
            enableWayland = false;
            enableCocoa = false;
            enableGl = false;
            enableAlsa = false;
            enableCdparanoia = false;
          };

          gst-plugins-good = p.gst_all_1.gst-plugins-good.override {
            inherit gst-plugins-base;
            gtkSupport = false;
            qt5Support = false;
            qt6Support = false;
            enableX11 = false;
            enableWayland = false;
            enableJack = false;
          };
        };
      });
    in {
      packages = forEachSupportedSystem ({ pkgs, makeHeadlessGst }:
        let
          headlessGst = makeHeadlessGst pkgs;
          
          # 💡 Define it here in the let block so both attributes can safely read it
          headless-gstreamer-kit = pkgs.linkFarm "headless-gstreamer-kit" [
            { name = "gstreamer"; path = headlessGst.gstreamer; }
            { name = "gst-libav"; path = headlessGst.gst-libav; }
            { name = "gst-plugins-bad"; path = headlessGst.gst-plugins-bad; }
            { name = "gst-plugins-rs"; path = headlessGst.gst-plugins-rs; }
            { name = "gst-plugins-base"; path = headlessGst.gst-plugins-base; }
            { name = "gst-plugins-good"; path = headlessGst.gst-plugins-good; }
          ];
        in {
          # Expose individual components
          inherit (headlessGst) gstreamer gst-libav gst-plugins-bad gst-plugins-rs gst-plugins-base gst-plugins-good;

          # Bind the kit attribute
          headless-gstreamer-kit = headless-gstreamer-kit;

          # Now this reference is perfectly valid!
          default = headless-gstreamer-kit;
        });
        
      # Adds a development shell so you can drop into an environment with these tools ready
      devShells = forEachSupportedSystem ({ pkgs, makeHeadlessGst }:
        let 
          headlessGst = makeHeadlessGst pkgs;
        in {
          default = pkgs.mkShell {
            buildInputs = [
              headlessGst.gstreamer
              headlessGst.gst-libav
              headlessGst.gst-plugins-base
              headlessGst.gst-plugins-good
              headlessGst.gst-plugins-bad
              headlessGst.gst-plugins-rs
              pkgs.pkg-config
            ];
            
            shellHook = ''
              echo "⚡ Headless GStreamer development environment loaded! ⚡"
              echo "GST_PLUGIN_SYSTEM_PATH is handled automatically by the nix environment."
            '';
          };
        });
    };
}
