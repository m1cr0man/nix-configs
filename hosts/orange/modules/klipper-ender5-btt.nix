{ config, ... }:
let
  serial = "/dev/ttyACM0";
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
    enable = false;
    enableKlipperFlash = true;
    configFile = ./ender5-btt.cfg;
  };

  services.klipper.settings = {
    mcu = {
      inherit serial;
      baud = 500000;
    };

    stepper_x = {
      step_pin = "P2.2";
      dir_pin = "!P2.6";
      enable_pin = "!P2.1";
      microsteps = 64;
      rotation_distance = 40;
      endstop_pin = "P1.29";
      position_endstop = 230;
      position_max = 230;
      homing_speed = 30;
    };

    stepper_y = {
      step_pin = "P0.19";
      dir_pin = "!P0.20";
      enable_pin = "!P2.8";
      microsteps = 64;
      rotation_distance = 40;
      endstop_pin = "P1.28";
      position_endstop = 220;
      position_max = 220;
      homing_speed = 30;
    };

    stepper_z = {
      step_pin = "P0.22";
      dir_pin = "!P2.11";
      enable_pin = "!P0.21";
      microsteps = 64;
      rotation_distance = 8;
      endstop_pin = "probe:z_virtual_endstop";
      position_min = 0;
      position_max = 250;
    };

    bltouch = {
      sensor_pin = "P1.27";
      control_pin = "P2.0";
      z_offset = 1.08;
      x_offset = -probeX;
      y_offset = -probeY;
      # samples:2
      # samples_result:average
      # probe_with_touch_mode: true
      # stow_on_each_sample: false
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

    screws_tilt_adjust = screws // {
      speed = 100;
      screw_thread = "CW-M4";
    };

    extruder = {
      max_extrude_only_distance = 100.0;
      step_pin = "P2.13";
      dir_pin = "!P0.11";
      enable_pin = "!P2.12";
      microsteps = 16;
      rotation_distance = 33.683;
      nozzle_diameter = 0.400;
      filament_diameter = 1.750;
      heater_pin = "P2.7";
      sensor_type = "EPCOS 100K B57560G104F";
      sensor_pin = "P0.24";
      control = "pid";
      # tuned for stock hardware with 200 degree Celsius target
      pid_Kp = 21.527;
      pid_Ki = 1.063;
      pid_Kd = 108.982;
      min_temp = 0;
      max_temp = 250;
      # pressure_advance = 0.073
    };

    heater_bed = {
      heater_pin = "P2.5";
      sensor_type = "EPCOS 100K B57560G104F";
      sensor_pin = "P0.25";
      control = "pid";
      # tuned for stock hardware with 50 degree Celsius target
      pid_Kp = 54.027;
      pid_Ki = 0.770;
      pid_Kd = 948.182;
      min_temp = 0;
      max_temp = 130;
    };

    fan = {
      pin = "P2.3";
    };

    "heater_fan Hotend_Fan" = {
      pin = "P2.4";
      max_power = 1.0;
      shutdown_speed = 0;
      cycle_time = 0.010;
      hardware_pwm = false;
      kick_start_time = 0.100;
      off_below = 0.0;
      heater = "extruder";
      heater_temp = 50.0;
      fan_speed = 1.0;
    };

    input_shaper = {};

    printer = {
      kinematics = "cartesian";
      max_velocity = 300;
      max_accel = 1500;
      square_corner_velocity = 12.0;
      max_z_velocity = 5;
      max_z_accel = 100;
    };

    # TMC2209 config
    "tmc2209 stepper_x" = {
      uart_pin = "P1.10";
      interpolate = false;
      run_current = 0.650;
    };

    "tmc2209 stepper_y" = {
      uart_pin = "P1.9";
      interpolate = false;
      run_current = 0.800;
    };

    "tmc2209 stepper_z" = {
      uart_pin = "P1.8";
      interpolate = false;
      # Dual motors
      run_current = 1.200;
    };

    "tmc2209 extruder" = {
      uart_pin = "P1.4";
      interpolate = false;
      run_current = 0.700;
    };

    ## Display config
    board_pins = {
      aliases = "EXP1_1=P1.30, EXP1_3=P1.18, EXP1_5=P1.20, EXP1_7=P1.22, EXP1_9=<GND>,";
      aliases_2 = "EXP1_2=P0.28, EXP1_4=P1.19, EXP1_6=P1.21, EXP1_8=P1.23, EXP1_10=<5V>,";
      aliases_3 = "EXP2_1=P0.17, EXP2_3=P3.26, EXP2_5=P3.25, EXP2_7=P1.31, EXP2_9=<GND>,";
      aliases_4 = "EXP2_2=P0.15, EXP2_4=P0.16, EXP2_6=P0.18, EXP2_8=<RST>, EXP2_10=<NC>";
      # Pins EXP2_1, EXP2_6, EXP2_2 are also MISO, MOSI, SCK of bus "ssp0"
    };

    display = {
      lcd_type = "st7920";
      cs_pin = "EXP1_7";
      sclk_pin = "EXP1_6";
      sid_pin = "EXP1_8";
      encoder_pins = "^EXP1_5, ^EXP1_3";
      click_pin = "^!EXP1_2";
    };

    "output_pin beeper".pin = "EXP1_1";
  };
}
