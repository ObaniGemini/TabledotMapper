/* tabledotimage.h */

#ifndef TABLEDOTIMAGE_H
#define TABLEDOTIMAGE_H

#include "core/io/image.h"

class TabledotImage : public RefCounted {
	GDCLASS(TabledotImage, RefCounted);

protected:
	static void _bind_methods();

public:
	static void copy_no_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src);
	static void add_only_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect, float max_alpha);
};

#endif // TABLEDOTIMAGE_H