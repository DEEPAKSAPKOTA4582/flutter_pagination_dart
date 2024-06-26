import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagination_clean_arch_practice/features/pagination/data/data_source/remote/photo_data_source.dart';
import 'package:pagination_clean_arch_practice/features/pagination/presentation/state/photo_state.dart';


final photoViewModelProvider =
    StateNotifierProvider<PhotoViewModel, PhotoState>((ref) {
  final photoDataSource = ref.read(photoDataSourceProvider);
  return PhotoViewModel(photoDataSource);
});

class PhotoViewModel extends StateNotifier<PhotoState> {
  final PhotoDataSource _photoDataSource;
  PhotoViewModel(this._photoDataSource) : super(PhotoState.initial()) {
    getPhotos();
  }

  Future resetState() async {
    state = PhotoState.initial();
    getPhotos();
  }

  Future getPhotos() async {
    state = state.copyWith(isLoading: true);
    final currentState = state;
    final page = currentState.page + 1;
    final photos = currentState.photos;
    final hasReachedMax = currentState.hasMaxReached;
    if (!hasReachedMax) {
      // get data from data source
      final result = await _photoDataSource.getPhotos(page);
      result.fold(
        (failure) =>
            state = state.copyWith(hasMaxReached: true, isLoading: false),
        (data) {
          if (data.isEmpty) {
            state = state.copyWith(hasMaxReached: true);
          } else {
            state = state.copyWith(
              photos: [...photos, ...data],
              page: page,
              isLoading: false,
            );
          }
        },
      );
    }
  }
}
