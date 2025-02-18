String getRestaurantImageUrl(String pictureId, {String resolution = 'small'}) {
  return 'https://restaurant-api.dicoding.dev/images/$resolution/$pictureId';
}
