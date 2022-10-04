#pragma once

#include <stdint.h>
#include <stdio.h>
#include <xil_types.h>



typedef struct {
	uint32_t stop_reg;
	uint32_t average_ctrl_reg;
	uint32_t avg_msmt_value_lsb_reg;
	uint32_t avg_msmt_value_msb_reg;
	uint32_t msmt_count
} timer_avg;




#define STOP_REG_STOP_MASK                  0x00000001

#define AVERAGE_CTRL_REG_AVG_MSMT_ENABLE_MASK 	0x00000001
#define AVERAGE_CTRL_REG_AVG_MSMT_LIMIT_MASK 	0x00001F00

#define timer_avg_stop(ptr) ((ptr)->stop_reg |= STOP_REG_STOP_MASK)

#define timer_avg_msmt_enable(ptr) ((ptr)->average_ctrl_reg |= AVERAGE_CTRL_REG_AVG_MSMT_ENABLE_MASK)
#define timer_avg_has_msmt_enabled(ptr) ((ptr)->average_ctrl_reg & AVERAGE_CTRL_REG_AVG_MSMT_ENABLE_MASK) ? TRUE : FALSE

#define timer_avg_set_msmt_limit(ptr, value) ((ptr)->average_ctrl_reg = ((ptr)->average_ctrl_reg & ~AVERAGE_CTRL_REG_AVG_MSMT_LIMIT) | ( (value << 8) & AVERAGE_CTRL_REG_AVG_MSMT_LIMIT))
#define timer_avg_get_msmt_limit(ptr) (((ptr)->average_ctrl_reg & AVERAGE_CTRL_REG_AVG_MSMT_LIMIT_MASK) >> 8)

#define timer_avg_get_avg_value_lsb(ptr) ((ptr)->avg_msmt_value_lsb_reg)

#define timer_avg_get_avg_value_msb(ptr) ((ptr)->avg_msmt_value_msb_reg)

#define timer_avg_get_msmt_count(ptr) ((ptr)->msmt_count)