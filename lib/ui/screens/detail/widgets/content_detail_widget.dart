import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/restaurant.dart';
import '../../../../provider/detail/restaurant_detail_provider.dart';
import '../../../../utils/image.util.dart';
import '../../../../utils/theme.dart';
import 'customer_review_widget.dart';
import 'menu_card_widget.dart';

class ContentDetailWidget extends StatefulWidget {
  final Restaurant restaurantDetail;
  const ContentDetailWidget({super.key, required this.restaurantDetail});

  @override
  State<ContentDetailWidget> createState() => _ContentDetailWidgetState();
}

class _ContentDetailWidgetState extends State<ContentDetailWidget> {
  final _nameC = TextEditingController();
  final _reviewC = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameC.dispose();
    _reviewC.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final name = _nameC.text.trim();
    final review = _reviewC.text.trim();

    if (name.isEmpty || review.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua bidang.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<RestaurantDetailProvider>().addReview(
        widget.restaurantDetail.id,
        name,
        review,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil ditambahkan.')),
        );
      }

      _nameC.clear();
      _reviewC.clear();
      if (mounted) {
        await context.read<RestaurantDetailProvider>().fetchRestaurantDetail(
          widget.restaurantDetail.id,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan review: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Hero(
            tag: widget.restaurantDetail.id,
            child: Image.network(
              getRestaurantImageUrl(widget.restaurantDetail.pictureId),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.restaurantDetail.name,
            style: AppTextStyles.textThemeCustom.headlineMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.restaurantDetail.city}, ${widget.restaurantDetail.address}",
                    style: AppTextStyles.textThemeCustom.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.restaurantDetail.rating}',
                    style: AppTextStyles.textThemeCustom.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.restaurantDetail.description,
                style: AppTextStyles.textThemeCustom.bodyMedium,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Text(
                "Menu Makanan",
                style: AppTextStyles.textThemeCustom.titleLarge,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      widget.restaurantDetail.menus!.foods
                          .map((food) => MenuCardWidget(menuName: food.name))
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Menu Minuman",
                style: AppTextStyles.textThemeCustom.titleLarge,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      widget.restaurantDetail.menus!.drinks
                          .map((drink) => MenuCardWidget(menuName: drink.name))
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text("Review", style: AppTextStyles.textThemeCustom.titleLarge),
              const SizedBox(height: 8),
              Column(
                children:
                    widget.restaurantDetail.customerReviews!
                        .map(
                          (review) => CustomerReviewWidget(
                            name: review.name,
                            review: review.review,
                            date: review.date,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
              Divider(thickness: 1, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                "Tambahkan Review Anda",
                style: AppTextStyles.textThemeCustom.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameC,
                decoration: const InputDecoration(
                  labelText: 'Nama Anda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewC,
                decoration: const InputDecoration(
                  labelText: 'Review Anda',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('Kirim Review'),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
