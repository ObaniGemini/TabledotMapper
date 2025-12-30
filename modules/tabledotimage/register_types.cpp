/* register_types.cpp */

#include "register_types.h"

#include "core/object/class_db.h"
#include "tabledotimage.h"

void initialize_tabledotimage_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	ClassDB::register_class<TabledotImage>();
}

void uninitialize_tabledotimage_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
   // Nothing to do here in this example.
}