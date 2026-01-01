/* tabledotimage.cpp */

#include "tabledotimage.h"

template <typename T>
static T MinMaxColor(T src, T dst) {
	return MIN(MAX(dst, src), src + dst);
}

Ref<Image> TabledotImage::make_luminance_image(const Ref<Image> &p_src) {
	Ref<Image> output;
	output.instantiate();
	output->initialize_data(p_src->get_width(), p_src->get_height(), p_src->has_mipmaps(), Image::Format::FORMAT_LA8);

	uint8_t *dst_ptr = output->ptrw();
	const uint8_t *src_ptr = p_src->ptr();

	constexpr uint64_t LA8_PIXEL_SIZE = 2;
	uint64_t pixel_size = Image::get_format_pixel_size(p_src->get_format());
	uint64_t pixel_size_minus_1 = pixel_size - 1;
	uint64_t end = p_src->get_height() * p_src->get_width();

	for(uint64_t i = 0; i < end; ++i) {
		uint64_t p = 0;
		uint16_t v = 0;
		for(; p < pixel_size_minus_1; ++p) {
			v += src_ptr[p + i * pixel_size];
		}

		dst_ptr[0 + i * LA8_PIXEL_SIZE] = MIN(uint16_t(255), v / pixel_size_minus_1);
		dst_ptr[1 + i * LA8_PIXEL_SIZE] = src_ptr[pixel_size_minus_1 + i * pixel_size];
	}

	return output;
}


void TabledotImage::blend_luminance_rect_to_rgba8(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect, const Point2i &p_dest, const Color &p_color) {
	ERR_FAIL_COND_MSG(p_dst->get_format() != Image::Format::FORMAT_RGBA8, "DST image needs to be RGBA8");
	ERR_FAIL_COND_MSG(p_src->get_format() != Image::Format::FORMAT_LA8, "SRC image needs to be LA8");

	constexpr uint64_t SRC_PIXEL_SIZE = 2;
	constexpr uint64_t DST_PIXEL_SIZE = 4;

	uint8_t *dst_ptr = p_dst->ptrw();
	const uint8_t *src_ptr = p_src->ptr();
	uint64_t size_y = p_src_rect.size.y;
	uint64_t size_x = p_src_rect.size.x;

	for (uint64_t y = 0; y < size_y; y++) {
		for (uint64_t x = 0; x < size_x; x++) {
			uint64_t src_pos = ((p_src_rect.position.y + y) * p_src->get_width() + p_src_rect.position.x + x) * SRC_PIXEL_SIZE;
			uint64_t dst_pos = ((p_dest.y + y) * p_dst->get_width() + p_dest.x + x) * DST_PIXEL_SIZE;

			float l = src_ptr[src_pos + 0] / 255.f;
			float a = src_ptr[src_pos + 1] / 255.f;

			Color sc = Color(l, l, l, a) * p_color;
			if (sc.a != 0) {
				Color dc = Color(
					dst_ptr[dst_pos + 0] / 255.f,
					dst_ptr[dst_pos + 1] / 255.f,
					dst_ptr[dst_pos + 2] / 255.f,
					dst_ptr[dst_pos + 3] / 255.f);
				
				dst_ptr[dst_pos + 0] = uint8_t(CLAMP(MinMaxColor(sc.r, dc.r) * 255.f, 0, 255));
				dst_ptr[dst_pos + 1] = uint8_t(CLAMP(MinMaxColor(sc.g, dc.g) * 255.f, 0, 255));
				dst_ptr[dst_pos + 2] = uint8_t(CLAMP(MinMaxColor(sc.b, dc.b) * 255.f, 0, 255));
				dst_ptr[dst_pos + 3] = uint8_t(CLAMP(MinMaxColor(sc.a, dc.a) * 255.f, 0, 255));
			}
		}
	}
}


void TabledotImage::blend_rgba8_to_rgb8_clear(const Ref<Image> &p_dst, const Ref<Image> &p_src) {
	ERR_FAIL_COND_MSG(p_dst->get_format() != Image::Format::FORMAT_RGB8, "DST image needs to be RGB8");
	ERR_FAIL_COND_MSG(p_src->get_format() != Image::Format::FORMAT_RGBA8, "SRC image needs to be RGBA8");
	ERR_FAIL_COND_MSG(p_dst->get_width() != p_src->get_width() || p_dst->get_height() != p_src->get_height(), "DST and SRC must share the same size");

	constexpr uint64_t SRC_PIXEL_SIZE = 4;
	constexpr uint64_t DST_PIXEL_SIZE = 3;

	uint8_t *dst_ptr = p_dst->ptrw();
	uint8_t *src_ptr = p_src->ptrw();

	uint64_t height = p_src->get_height();
	uint64_t width = p_src->get_width();

	for (uint64_t y = 0; y < height; y++) {
		for (uint64_t x = 0; x < width; x++) {
			uint64_t src_pos = (y * width + x) * SRC_PIXEL_SIZE;
			uint64_t dst_pos = (y * width + x) * DST_PIXEL_SIZE;

			uint8_t a = src_ptr[src_pos + 3];
			if (a != 0) {
				Color dc = Color(dst_ptr[dst_pos + 0] / 255.f, dst_ptr[dst_pos + 1] / 255.f, dst_ptr[dst_pos + 2] / 255.f, 1.f);
				dc = dc.blend(Color(src_ptr[src_pos + 0] / 255.f, src_ptr[src_pos + 1] / 255.f, src_ptr[src_pos + 2] / 255.f, src_ptr[src_pos + 3] / 255.f));
				
				dst_ptr[dst_pos + 0] = uint8_t(CLAMP(dc.r * 255.f, 0, 255));
				dst_ptr[dst_pos + 1] = uint8_t(CLAMP(dc.g * 255.f, 0, 255));
				dst_ptr[dst_pos + 2] = uint8_t(CLAMP(dc.b * 255.f, 0, 255));
			}

			src_ptr[src_pos + 0] = 0;
			src_ptr[src_pos + 1] = 0;
			src_ptr[src_pos + 2] = 0;
			src_ptr[src_pos + 3] = 0;
		}
	}
}


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


void TabledotImage::add_only_alpha(const Ref<Image> &p_dst, const Ref<Image> &p_src, const Rect2i &p_src_rect) {
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

	for (uint64_t y = p_src_rect.position.y; y < end_y; y++) {
		for (uint64_t x = p_src_rect.position.x; x < end_x; x++) {
			uint64_t pos = (y * width + x) * pixel_size + 3;
			uint16_t dst_px = dst_ptr[pos];
			uint16_t src_px = src_ptr[pos];
			dst_ptr[pos] = uint8_t(MinMaxColor(src_px, dst_px));
		}
	}
}


void TabledotImage::_bind_methods() {
	ClassDB::bind_static_method("TabledotImage", D_METHOD("make_luminance_image", "src"), &TabledotImage::make_luminance_image);
	ClassDB::bind_static_method("TabledotImage", D_METHOD("blend_luminance_rect_to_rgba8", "dst", "src", "src_rect", "dst_pos", "color"), &TabledotImage::blend_luminance_rect_to_rgba8);
	ClassDB::bind_static_method("TabledotImage", D_METHOD("blend_rgba8_to_rgb8_clear", "dst", "src"), &TabledotImage::blend_rgba8_to_rgb8_clear);
	ClassDB::bind_static_method("TabledotImage", D_METHOD("copy_no_alpha", "dst", "src"), &TabledotImage::copy_no_alpha);
	ClassDB::bind_static_method("TabledotImage", D_METHOD("add_only_alpha", "dst", "src", "src_rect"), &TabledotImage::add_only_alpha);
}