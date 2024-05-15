# Happy Belly Kitchen App

### Overview

**Stack**: Flutter with Provider for state management & Get it package for dependency injection
**Current Flutter Version**: 3.16.5  
**Dark SDK**: >=2.17.0 <3.0.0
**Available Platform**: Android only
**Push Notifications**: Firebase  
**Current Version on Store**: 1.0.0

## Setup Instructions

#### Firebase Push Notifications

1. **Change Package Name**: Ensure your app has a unique package name.
2. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com).
   - Create a project and add your Android app with your package name and app name.
   - Click register app and download `google-services.json`.
   - Place `google-services.json` in `<project>/android/app/`.
3. **Notification Icon**:
   - Create a white PNG logo for the notification icon.
   - Replace `notification_icon.png` in `<project>/android/app/src/main/res/drawable/` with your logo.

### Change Base URL

Update the `baseUrl` variable in `<project>/lib/util/app_constants.dart` https://github.com/Happybellytech/kitchen-app/blob/6db745353d38ec7c020fc2a53f98049adb8bc946/lib/util/app_constants.dart?plain=1#L9

### Building the App

- **Android**:
  - For a debug build: `flutter build apk`
  - To split APKs: `flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi`
  - For deployment, refer to the [Flutter Android deployment documentation](https://docs.flutter.dev/deployment/android)
- **iOS**: Use TestFlight or App Store for deployment. Refer to the [Flutter iOS deployment documentation](https://docs.flutter.dev/deployment/ios)

## Additional Implementations

### UI Redesigned:

The kitchen app was redesigned which migrated from the `order grid view` to `horizontal list view` and also supports multiple screen's

### Multiple Screen:

- Orders are spitted to two different screens `Screen 1`, `Screen 2` using their screenId
- This is filtered and rendered on the `lib\view\screens\home\widget\new\order_list_view.dart` https://github.com/Happybellytech/kitchen-app/blob/6db745353d38ec7c020fc2a53f98049adb8bc946/lib/view/screens/home/widget/new/order_list_view.dart?plain=1#L44-L55

> [!NOTE]
> All Screen shows all the orders from both `Screen 1` & `Screen 2`

### Order List Card

To speed up loading time, we used a ListView Builder Widget which only loads more Order item's when scrolling left horizontally

- This means the more you scroll left, each of the order item's fetches their details from the backend and then renders to the screen
- We also added a skimmer loading component's which are being shown until the order details are fetched
- To avoid refetching order details when the order card is being rerendered, We added a caching implementation which caches the order details and serve from the cache instead of fetching from backend all over
