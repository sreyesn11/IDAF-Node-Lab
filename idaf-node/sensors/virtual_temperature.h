#ifndef IDAF_VIRTUAL_TEMPERATURE_H
#define IDAF_VIRTUAL_TEMPERATURE_H

#include <stdint.h>

#include "sensor_provider.h"

enum idaf_virtual_temperature_mode_e
{
  IDAF_VTEMP_MODE_NORMAL = 0,
  IDAF_VTEMP_MODE_SPIKE,
  IDAF_VTEMP_MODE_BIAS,
  IDAF_VTEMP_MODE_STUCK,
  IDAF_VTEMP_MODE_NO_DATA,
  IDAF_VTEMP_MODE_NOISY,
  IDAF_VTEMP_MODE_SLOW
};

struct idaf_virtual_temperature_status_s
{
  enum idaf_virtual_temperature_mode_e mode;
  uint32_t sequence;
};

extern struct idaf_sensor_provider_s g_virtual_temperature_provider;

int virtual_temperature_get_status(
  struct idaf_virtual_temperature_status_s *status);

const char *virtual_temperature_mode_name(
  enum idaf_virtual_temperature_mode_e mode);

#endif /* IDAF_VIRTUAL_TEMPERATURE_H */
