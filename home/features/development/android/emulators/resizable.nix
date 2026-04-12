# Resizable Emulator Configuration
# Optimized for performance with ARM system images and hardware acceleration
# Supports multiple form factors: phone, foldable, tablet, desktop
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    home.file = {
      ".android/avd/Resizable.ini" = {
        text = ''
          avd.ini.encoding=UTF-8
          path=${config.home.homeDirectory}/.android/avd/Resizable.avd
          path.rel=avd/Resizable.avd
          target=android-36
        '';
      };

      ".android/avd/Resizable.avd/config.ini" = {
        text = ''
          AvdId=Resizable
          PlayStore.enabled=false
          abi.type=arm64-v8a
          avd.ini.displayname=Resizable
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
          hw.device.hash2=MD5:6ea1f37386c6ff2bb09825b1a05114ee
          hw.device.manufacturer=Generic
          hw.device.name=resizable
          hw.displayRegion.0.1.height=2092
          hw.displayRegion.0.1.width=1080
          hw.displayRegion.0.1.xOffset=0
          hw.displayRegion.0.1.yOffset=0
          hw.gps=yes
          hw.gpu.enabled=yes
          hw.gpu.mode=host
          hw.gyroscope=yes
          hw.initialOrientation=portrait
          hw.keyboard=yes
          hw.keyboard.lid=yes
          hw.lcd.density=420
          hw.lcd.height=2400
          hw.lcd.width=1080
          hw.mainKeys=no
          hw.ramSize=3072
          hw.resizable.configs=phone-0-1080-2400-420, foldable-1-2208-1840-420, tablet-2-1920-1200-240, desktop-3-1920-1080-160
          hw.sdCard=yes
          hw.sensor.hinge=yes
          hw.sensor.hinge.areas=1080-0-0-1840
          hw.sensor.hinge.count=1
          hw.sensor.hinge.defaults=180
          hw.sensor.hinge.ranges=0-180
          hw.sensor.hinge.sub_type=1
          hw.sensor.hinge.type=1
          hw.sensor.hinge_angles_posture_definitions=0-30, 30-150, 150-180
          hw.sensor.posture_list=1, 2, 3
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
          tag.display=Google APIs
          tag.displaynames=Google APIs
          tag.id=google_apis
          tag.ids=google_apis
          target=android-36
          vm.heapSize=228
        '';
      };
    };

    # Create Resizable AVD data directory
    home.activation.setupResizableEmulator = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Setting up Resizable emulator..."
      mkdir -p "${config.home.homeDirectory}/.android/avd/Resizable.avd"

      # Preserve existing userdata if it exists
      if [ -f "${config.home.homeDirectory}/.android/avd/Resizable.avd/userdata-qemu.img" ]; then
        echo "Preserving userdata for Resizable emulator..."
      else
        echo "Fresh Resizable emulator setup complete!"
      fi
    '';
  };
}
