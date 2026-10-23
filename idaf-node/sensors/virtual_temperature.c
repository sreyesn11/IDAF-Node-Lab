#include <nuttx/config.h>

#include <time.h>
#include <stdint.h>

#include "virtual_temperature.h"

static uint32_t g_sequence = 0;
static enum idaf_virtual_temperature_mode_e g_mode =
  IDAF_VTEMP_MODE_NORMAL;

static uint64_t idaf_get_uptime_ms(void)
{
  struct timespec ts;

  clock_gettime(CLOCK_MONOTONIC, &ts);

  return ((uint64_t)ts.tv_sec * 1000ULL) +
         ((uint64_t)ts.tv_nsec / 1000000ULL);
}

static int virtual_temperature_read(struct idaf_sensor_sample_s *sample)
{
  if (sample == NULL)
    {
      return -1;
    }

  g_sequence++;

  sample->sequence = g_sequence;
  sample->timestamp_ms = idaf_get_uptime_ms();
  sample->value = 25.0f;
  sample->valid = true;
  sample->status = IDAF_SENSOR_STATUS_OK;

  return 0;
}

int virtual_temperature_get_status(
  struct idaf_virtual_temperature_status_s *status)
{
  if (status == NULL)
    {
      return -1;
    }

  status->mode = g_mode;
  status->sequence = g_sequence;

  return 0;
}

const char *virtual_temperature_mode_name(
  enum idaf_virtual_temperature_mode_e mode)
{
  switch (mode)
    {
      case IDAF_VTEMP_MODE_NORMAL:
        return "NORMAL";

      case IDAF_VTEMP_MODE_SPIKE:
        return "SPIKE";

      case IDAF_VTEMP_MODE_BIAS:
        return "BIAS";

      case IDAF_VTEMP_MODE_STUCK:
        return "STUCK";

      case IDAF_VTEMP_MODE_NO_DATA:
        return "NO_DATA";

      case IDAF_VTEMP_MODE_NOISY:
        return "NOISY";

      case IDAF_VTEMP_MODE_SLOW:
        return "SLOW";

      default:
        return "UNKNOWN";
    }
}

struct idaf_sensor_provider_s g_virtual_temperature_provider =
{
  .name = "virtual_temperature",
  .unit = "C",
  .read = virtual_temperature_read
};
