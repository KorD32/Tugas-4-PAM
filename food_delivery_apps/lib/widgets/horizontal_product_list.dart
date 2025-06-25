import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HorizontalProductList extends StatefulWidget {
  final List<Product> products;
  final void Function(Product) onTap;

  const HorizontalProductList(
      {required this.products, required this.onTap, super.key});

  @override
  State<HorizontalProductList> createState() => _HorizontalProductListState();
}

class _HorizontalProductListState extends State<HorizontalProductList> {
  final controller = PageController(viewportFraction: 0.96);

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;
    final pageCount = (widget.products.length / 2).ceil();

    return SizedBox(
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                int first = pageIndex * 2;
                int second = first + 1;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: widget.products[first],
                        onTap: () => widget.onTap(widget.products[first]),
                        isHorizontal: true,
                        cardHeight: 310,
                        imageHeight: 160,
                      ),
                    ),
                    const SizedBox(width: 15),
                    if (second < widget.products.length)
                      SizedBox(
                        width: cardWidth,
                        child: ProductCard(
                          product: widget.products[second],
                          onTap: () => widget.onTap(widget.products[second]),
                          isHorizontal: true,
                          cardHeight: 310,
                          imageHeight: 160,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SmoothPageIndicator(
            controller: controller,
            count: pageCount,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Colors.deepPurple,
              dotColor: Colors.grey.shade300,
            ),
            onDotClicked: (index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
