#include "axi_timer_avg.h"



int axi_timer_avg_init(axi_timer_avg *ptr, uint32_t baseaddress){
	ptr->timer = (timer_avg*)baseaddress;

	ptr->init = 1;

	return TIMER_OK;

}



int axi_timer_avg_stop(axi_timer_avg *ptr){
	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	timer_avg_stop(ptr->timer);

	return TIMER_OK;
}



int axi_timer_avg_has_msmt_enabled(axi_timer_avg *ptr){
	return (timer_avg_has_msmt_enabled(ptr->timer));
}



int axi_timer_avg_msmt_enable(axi_timer_avg *ptr){
	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	timer_avg_msmt_enable(ptr->timer);

	return TIMER_OK;
}


int axi_timer_avg_get_msmt_limit(axi_timer_avg *ptr, uint32_t *msmt_limit){

	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	*msmt_limit = timer_avg_get_msmt_limit(ptr->timer);

	return TIMER_OK;
}


int axi_timer_avg_set_msmt_limit(axi_timer_avg *ptr, uint32_t msmt_limit){
	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	timer_avg_set_msmt_limit(ptr->timer, msmt_limit);

	return TIMER_OK;
}


int axi_timer_avg_get_avg_value(axi_timer_avg *ptr, uint64_t *avg_value){

	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	*avg_value = ((uint64_t)timer_avg_get_avg_value_lsb(ptr->timer)) + ((uint64_t)timer_avg_get_avg_value_msb(ptr->timer) << 32);

	return TIMER_OK;
}


int axi_timer_avg_get_msmt_count(axi_timer_avg *ptr, uint32_t *msmt_count){

	if (!axi_timer_avg_has_init(ptr)){
		return TIMER_UNINIT;
	}

	*msmt_count = timer_avg_get_msmt_count(ptr->timer);

	return TIMER_OK;
}
