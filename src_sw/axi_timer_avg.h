#pragma once

#include <stdint.h>
#include <stdio.h>
#include <xil_types.h>
#include "timer_avg.h"

typedef struct {
	timer_avg *timer;
	int init;
} axi_timer_avg;


#define axi_timer_avg_has_init(ptr) (ptr->init == 1) ? TRUE : FALSE

int axi_timer_avg_init(axi_timer_avg *ptr, uint32_t baseaddress);
int axi_timer_avg_stop(axi_timer_avg *ptr);
int axi_timer_avg_has_msmt_enabled(axi_timer_avg *ptr);
int axi_timer_avg_msmt_enable(axi_timer_avg *ptr);
int axi_timer_avg_get_msmt_limit(axi_timer_avg *ptr, uint32_t *msmt_limit);
int axi_timer_avg_set_msmt_limit(axi_timer_avg *ptr, uint32_t msmt_limit);
int axi_timer_avg_get_avg_value(axi_timer_avg *ptr, uint64_t *avg_value);
int axi_timer_avg_get_msmt_count(axi_timer_avg *ptr, uint32_t *msmt_count);
