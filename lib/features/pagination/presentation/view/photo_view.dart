import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagination_clean_arch_practice/features/pagination/presentation/view_model/photo_view_model.dart';


class PhotosView extends ConsumerStatefulWidget {
  const PhotosView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PhotosViewState();
}

class _PhotosViewState extends ConsumerState<PhotosView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoViewModelProvider);

    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // Scroll garda feri last ma ho ki haina bhanera check garne ani data call garne
          if (_scrollController.position.extentAfter == 0) {
            // Data fetch gara api bata
            ref.read(photoViewModelProvider.notifier).getPhotos();
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.amber[100],
        appBar: AppBar(
          backgroundColor: Colors.yellow[400],
          title: const Text('Photos Pagination'),
          actions: [
            TextButton.icon(
              onPressed: () {
                ref.read(photoViewModelProvider.notifier).resetState();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        body: RefreshIndicator(
          // Yo chai pull to refresh ko lagi ho
          color: Colors.green,
          backgroundColor: Colors.amberAccent,
          onRefresh: () async {
            ref.read(photoViewModelProvider.notifier).resetState();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    controller: _scrollController,
                    itemCount: state.photos.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final photos = state.photos[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                photos.id.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.network(
                                  photos.thumbnailUrl,
                                  height: 200,
                                  width: 200,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else if (loadingProgress
                                            .expectedTotalBytes !=
                                        null) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          value: loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!,
                                        ),
                                      );
                                    } else {
                                      // If total bytes are unknown, you may want to handle it differently
                                      return const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.red),
                                      );
                                    }
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    return const Center(
                                      child: Text('Failed to load image'),
                                    );
                                  },
                                ),
                              ),
                              Text(
                                photos.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Data load huda feri progress bar dekhaune natra banda garne
                if (state.isLoading)
                  const CircularProgressIndicator(color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
