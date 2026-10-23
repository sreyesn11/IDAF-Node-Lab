#ifndef IDAF_SENSOR_PROVIDER_H
#define IDAF_SENSOR_PROVIDER_H

#include <stdbool.h>
#include <stdint.h>

enum idaf_sensor_status_e
{
  IDAF_SENSOR_STATUS_OK = 0,
  IDAF_SENSOR_STATUS_ERROR,
  IDAF_SENSOR_STATUS_TIMEOUT,
  IDAF_SENSOR_STATUS_NO_DATA
};

struct idaf_sensor_sample_s
{
  uint32_t sequence;
  uint64_t timestamp_ms;
  float value;
  bool valid;
  enum idaf_sensor_status_e status;
};

struct idaf_sensor_provider_s
{
  const char *name;
  const char *unit;

  int (*read)(struct idaf_sensor_sample_s *sample);
};

#endif /* IDAF_SENSOR_PROVIDER_H */
