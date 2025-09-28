# MyPixel9 Emulator Configuration
# Optimized for performance with ARM system images and hardware acceleration
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    home.file = {
      ".android/avd/MyPixel9.ini" = {
        text = ''
          avd.ini.encoding=UTF-8
          path=${config.home.homeDirectory}/.android/avd/MyPixel9.avd
          path.rel=avd/MyPixel9.avd
          target=android-36
        '';
      };

      ".android/avd/MyPixel9.avd/config.ini" = {
        text = ''
          AvdId=MyPixel9
          PlayStore.enabled=false
          abi.type=arm64-v8a
          avd.ini.displayname=MyPixel9
          avd.ini.encoding=UTF-8
          disk.dataPartition.size=6G
          fastboot.chosenSnapshotFile=
          fastboot.forceChosenSnapshotBoot=no
          fastboot.forceColdBoot=no
          fastboot.forceFastBoot=yes
          hw.accelerometer=yes
          hw.arc=false
          hw.audioInput=yes
          hw.battery=yes
          hw.camera.back=virtualscene
          hw.camera.front=emulated
          hw.cpu.arch=arm64
          hw.cpu.ncore=2
          hw.dPad=no
          hw.device.hash2=MD5:5478e3411cc0e0441240e736eb14c07a
          hw.device.manufacturer=Google
          hw.device.name=pixel_9
          hw.gps=yes
          hw.gpu.enabled=yes
          hw.gpu.mode=host
          hw.gyroscope=yes
          hw.initialOrientation=portrait
          hw.keyboard=yes
          hw.lcd.density=420
          hw.lcd.height=2424
          hw.lcd.width=1080
          hw.mainKeys=no
          hw.ramSize=3072
          hw.sdCard=yes
          hw.sensors.light=yes
          hw.sensors.magnetic_field=yes
          hw.sensors.orientation=yes
          hw.sensors.pressure=yes
          hw.sensors.proximity=yes
          hw.trackBall=no
          image.sysdir.1=system-images/android-36/google_apis/arm64-v8a/
          runtime.network.latency=none
          runtime.network.speed=full
          sdcard.size=512M
          showDeviceFrame=yes
          skin.dynamic=yes
          skin.name=pixel_9
          tag.display=Google APIs
          tag.displaynames=Google APIs
          tag.id=google_apis
          tag.ids=google_apis
          target=android-36
          vm.heapSize=228
        '';
      };
    };

    # Create MyPixel9 AVD data directory
    home.activation.setupMyPixel9Emulator = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Setting up MyPixel9 emulator..."
      mkdir -p "${config.home.homeDirectory}/.android/avd/MyPixel9.avd"

      # Preserve existing userdata if it exists
      if [ -f "${config.home.homeDirectory}/.android/avd/MyPixel9.avd/userdata-qemu.img" ]; then
        echo "Preserving userdata for MyPixel9 emulator..."
      else
        echo "Fresh MyPixel9 emulator setup complete!"
      fi
    '';
  };
}
