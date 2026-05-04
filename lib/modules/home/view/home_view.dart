import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/modules/home/model/product_model.dart';
import 'package:store_app_api/modules/home/viewmodel/home_viewmodel.dart';

/// Home catalogue: loads profile + products in parallel ([HomeViewmodel]).
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _accent = Color(0xFFFF7622);
  static const _headerBg = Color(0xFF121223);

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(HomeViewmodel());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _accent),
          );
        }
        return RefreshIndicator(
          color: _accent,
          onRefresh: vm.pullToRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 132,
                backgroundColor: _headerBg,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          Obx(() {
                            final u = vm.user.value;
                            return CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white24,
                              backgroundImage: u != null && u.avatar.isNotEmpty
                                  ? NetworkImage(u.avatar)
                                  : null,
                              child: u == null || u.avatar.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 32, color: Colors.white54)
                                  : null,
                            );
                          }),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Obx(() {
                              final u = vm.user.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    u?.name.isNotEmpty == true
                                        ? u!.name
                                        : 'Guest',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    u?.email ?? '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              Obx(
                () {
                  final items = vm.products;
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        childCount: items.length,
                        (context, index) {
                          return _ProductCard(product: items[index]);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: p.primaryImage.isEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.inventory_2_outlined,
                            size: 40, color: Colors.grey.shade400),
                      )
                    : Image.network(
                        p.primaryImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined,
                              color: Colors.grey.shade500),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${p.price.toStringAsFixed(p.price.truncateToDouble() == p.price ? 0 : 2)}',
                    style: const TextStyle(
                      color: HomeView._accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (p.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      p.category!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
