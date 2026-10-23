#include <nuttx/config.h>

#include <stdio.h>
#include <string.h>

#include "sensors/virtual_temperature.h"

static void idaf_print_usage(void)
{
  printf("Usage:\n");
  printf("  idaf\n");
  printf("  idaf sensor read\n");
  printf("  idaf sensor status\n");
}

static int idaf_sensor_read(void)
{
  struct idaf_sensor_sample_s sample;
  int ret;

  ret = g_virtual_temperature_provider.read(&sample);
  if (ret < 0)
    {
      printf("Sensor read failed\n");
      return ret;
    }

  printf("sensor=%s\n", g_virtual_temperature_provider.name);
  printf("sequence=%lu\n", (unsigned long)sample.sequence);
  printf("timestamp_ms=%llu\n",
         (unsigned long long)sample.timestamp_ms);
  printf("value=%.2f\n", sample.value);
  printf("unit=%s\n", g_virtual_temperature_provider.unit);
  printf("valid=%s\n", sample.valid ? "true" : "false");
  printf("status=%d\n", sample.status);

  return 0;
}

static int idaf_sensor_status(void)
{
  struct idaf_virtual_temperature_status_s status;
  int ret;

  ret = virtual_temperature_get_status(&status);
  if (ret < 0)
    {
      printf("Sensor status failed\n");
      return ret;
    }

  printf("sensor=%s\n", g_virtual_temperature_provider.name);
  printf("mode=%s\n",
         virtual_temperature_mode_name(status.mode));
  printf("sequence=%lu\n",
         (unsigned long)status.sequence);

  return 0;
}

int idaf_main(int argc, char *argv[])
{
  if (argc == 1)
    {
      printf("IDAF Node Agent\n");
      idaf_print_usage();
      return 0;
    }

  if (argc == 3 &&
      strcmp(argv[1], "sensor") == 0 &&
      strcmp(argv[2], "read") == 0)
    {
      return idaf_sensor_read();
    }

  if (argc == 3 &&
      strcmp(argv[1], "sensor") == 0 &&
      strcmp(argv[2], "status") == 0)
    {
      return idaf_sensor_status();
    }

  printf("Unknown command\n");
  idaf_print_usage();

  return 1;
}
