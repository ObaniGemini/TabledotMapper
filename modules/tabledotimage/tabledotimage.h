#pragma once

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/image.hpp>

using namespace godot;

class TabledotImage : public RefCounted {
	GDCLASS(TabledotImage, RefCounted);

protected:
	static void _bind_methods();

public:
	static Ref<Image> make_luminance_image(const Ref<Image> &p_src);
	static void blend_luminance_rect_to_rgba8(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect, const Point2i &p_dest, const Color &p_color);
	static void blend_rgba8_to_rgb8_clear(const Ref<Image> &p_dst, const Ref<Image> &p_src);
	static void copy_no_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src);
	static void blend_circle(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect, const Point2i &center, int64_t radius, float roughness, float alpha);
};
