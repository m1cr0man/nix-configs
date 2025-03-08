let
  serial = "/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0";
  probeX = 42.2;
  probeY = 10;
  ts = builtins.toString;

  # Applies the probe offset to an absolute set of coordinates
  # Returns a comma separated string
  xyProbe = x: y: "${ts (x + probeX)},${ts (y + probeY)}";

  # The inverse of xyProbe
  xyProbeInv = x: y: "${ts (x - probeX)},${ts (y - probeY)}";

  # Probe distances added to screws
  screws = {
    # screw1 = "33,30";
    screw1 = xyProbe 33 30;
    screw1_name = "Front left";
    # screw2 = "187,30";
    screw2 = xyProbe 187 30;
    screw2_name = "Front Right";
    # screw3 = "187,187";
    screw3 = xyProbe 187 187;
    screw3_name = "Back Right";
    # screw4 = "33,187";
    screw4 = xyProbe 33 187;
    screw4_name = "Back Left";
  };
in
{
  services.klipper.firmwares.mcu = {
    inherit serial;
    enable = true;
    enableKlipperFlash = true;
    configFile = ./ender5.cfg;
  };

  services.klipper.settings = {
    mcu = {
      inherit serial;
      baud = 500000;
    };

    stepper_x = {
      step_pin = "PD7";
      dir_pin = "!PC5";
      enable_pin = "!PD6";
      microsteps = 16;
      rotation_distance = 40;
      endstop_pin = "^PC2";
      position_endstop = 230;
      position_max = 230;
      homing_speed = 30;
    };

    stepper_y = {
      step_pin = "PC6";
      dir_pin = "!PC7";
      enable_pin = "!PD6";
      microsteps = 16;
      rotation_distance = 40;
      endstop_pin = "^PC3";
      # Shortened to clear fan cowling at Y=0
      position_endstop = 220;
      position_max = 220;
      homing_speed = 30;
    };

    stepper_z = {
      step_pin = "PB3";
      dir_pin = "!PB2";
      enable_pin = "!PA5";
      microsteps = 16;
      # Use 4 for Ender5 versions after late 2019
      rotation_distance = 8;
      endstop_pin = "probe:z_virtual_endstop";
      # position_endstop = "0.0";
      position_max = 300;
    };

    bltouch = {
      sensor_pin = "^PC4";
      # Note: This is the buzzer pin on the LCD screen.
      control_pin = "PA4";
      z_offset = 3.1;
      x_offset = -probeX; ##!! Measure and change for your own printer!!
      y_offset = -probeY; ##!! Measure and change for your own printer!!
      #y_offset = -15.7
    };

    safe_z_home = {
      home_xy_position = xyProbe 110 110;
      speed = 50;
      z_hop = 10; # Move up 10mm
      z_hop_speed = 5;
    };

    bed_mesh = {
      speed = 120;
      mesh_min = xyProbe 0 0;
      mesh_max = xyProbeInv 220 220;
      probe_count = "5,5";
      horizontal_move_z = 7;
    };

    bed_screws = screws // {
      speed = 100;
    };

    screws_tilt_adjust = screws // {
      speed = 100;
      screw_thread = "CW-M4";
    };

    extruder = {
      max_extrude_only_distance = 100.0;
      step_pin = "PB1";
      dir_pin = "!PB0";
      enable_pin = "!PD6";
      microsteps = 16;
      rotation_distance = 33.683;
      nozzle_diameter = 0.400;
      filament_diameter = 1.750;
      heater_pin = "PD5";
      sensor_type = "EPCOS 100K B57560G104F";
      sensor_pin = "PA7";
      control = "pid";
      # tuned for stock hardware with 200 degree Celsius target
      pid_Kp = 21.527;
      pid_Ki = 1.063;
      pid_Kd = 108.982;
      min_temp = 0;
      max_temp = 250;
    };

    heater_bed = {
      heater_pin = "PD4";
      sensor_type = "EPCOS 100K B57560G104F";
      sensor_pin = "PA6";
      control = "pid";
      # tuned for stock hardware with 50 degree Celsius target
      pid_Kp = 54.027;
      pid_Ki = 0.770;
      pid_Kd = 948.182;
      min_temp = 0;
      max_temp = 130;
    };

    fan = {
      pin = "PB4";
    };

    printer = {
      kinematics = "cartesian";
      max_velocity = 300;
      max_accel = 3000;
      max_z_velocity = 5;
      max_z_accel = 100;
    };

    display = {
      lcd_type = "st7920";
      cs_pin = "PA3";
      sclk_pin = "PA1";
      sid_pin = "PC1";
      encoder_pins = "^PD2, ^PD3";
      click_pin = "^!PC0";
    };

    # No buzzer: The pin (PA4) is used by the BLTouch
  };
}
