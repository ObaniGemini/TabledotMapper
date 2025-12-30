/* tabledotimage.cpp */

#include "tabledotimage.h"

void TabledotImage::copy_no_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src) {
	ERR_FAIL_COND_MSG(p_src.is_null(), "Cannot blit_rect an image: invalid src Image object.");
	ERR_FAIL_COND_MSG(p_dst.is_null(), "Cannot blit_rect an image: invalid dst Image object.");
	ERR_FAIL_COND(p_dst->get_width() != p_src->get_width() || p_dst->get_height() != p_src->get_height());
	ERR_FAIL_COND(p_dst->get_format() != p_src->get_format() || p_dst->get_format() != Image::FORMAT_RGBA8);
	ERR_FAIL_COND_MSG(p_dst->is_compressed(), "Cannot blit_rect in compressed image formats.");

	uint8_t *dst_ptr = p_dst->ptrw();
	const uint8_t *src_ptr = p_src->ptr();

	int pixel_size = Image::get_format_pixel_size(p_dst->get_format());

	for (int x = 0; x < p_dst->get_width(); x++) {
		for (int y = 0; y < p_dst->get_height(); y++) {
			uint64_t pos = (y * p_dst->get_width() + x) * pixel_size;
			uint64_t end = pos + pixel_size - 1;

			for (; pos < end; pos++)
				dst_ptr[pos] = src_ptr[pos];
			dst_ptr[pos] = 0;
		}
	}
}

void TabledotImage::add_only_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect, float max_alpha) {
	ERR_FAIL_COND_MSG(p_src.is_null(), "Cannot blit_rect an image: invalid src Image object.");
	ERR_FAIL_COND_MSG(p_dst.is_null(), "Cannot blit_rect an image: invalid dst Image object.");
	ERR_FAIL_COND(p_dst->get_width() != p_src->get_width() || p_dst->get_height() != p_src->get_height());
	ERR_FAIL_COND(p_dst->get_format() != p_src->get_format() || p_dst->get_format() != Image::FORMAT_RGBA8);
	ERR_FAIL_COND_MSG(p_dst->is_compressed(), "Cannot blit_rect in compressed image formats.");

	uint8_t *dst_ptr = p_dst->ptrw();
	const uint8_t *src_ptr = p_src->ptr();

	uint64_t pixel_size = Image::get_format_pixel_size(p_dst->get_format());

	uint64_t end_x = p_src_rect.position.x + p_src_rect.size.x;
	uint64_t end_y = p_src_rect.position.y + p_src_rect.size.y;
	uint64_t width = p_dst->get_width();

	uint16_t real_max_alpha = CLAMP(max_alpha * 255.0, 0, 255);

	for (uint64_t y = p_src_rect.position.y; y < end_y; y++) {
		for (uint64_t x = p_src_rect.position.x; x < end_x; x++) {
			uint64_t pos = (y * width + x) * pixel_size + 3;
			dst_ptr[pos] = uint8_t(MIN(real_max_alpha, uint16_t(dst_ptr[pos]) + uint16_t(src_ptr[pos])));
		}
	}
}

void TabledotImage::_bind_methods() {
	ClassDB::bind_static_method("TabledotImage", D_METHOD("copy_no_alpha", "dst", "src"), &TabledotImage::copy_no_alpha);
	ClassDB::bind_static_method("TabledotImage", D_METHOD("add_only_alpha", "dst", "src", "src_rect", "max_alpha"), &TabledotImage::add_only_alpha);
}