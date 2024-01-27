# recipes_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Documentation for My Recipes App

Problem Statement

Some people like to write down their recipe personally. Doing this will make them easier in future to recook the same recipe or if they want to share their recipe to other people. But there are some problem on using the traditional recipe taking:

1. The book can be damaged by an unexpected accident such as burning, exposed to water, missing and many more.
2. If there is too many recipes it will more difficult to search for a spesific one.
3. Some ink can disappear over time.

Objective of My Recipes App

This application can give a best features for the user to fully utilize the app and can save their recipe safely. The features are:

1. The data is stored in cloud database. Even if the app is deleted, the data will stay on the cloud as long as the user do not remove it from cloud.
2. Data is separated by user. Different user can not access another user's recipe data.
3. User can favorite their recipes to filter down the recipe.
4. User can use search box to search their recipe.
5. User can edit the menu if they want to make some changes.
6. User can delete the menu.
7. The app can sort the menu by their type.
8. User can list down all the groceries they want to buy.
9. User can change display name of the app.
10. User can logout.


Database

Database used for this project is Firebase Authentication and Firebase Firestore.

Firebase Authentication: Used to store user credentials information which is email and password.

Firebase Firestore: Used to store user information data.In Firestore, it have 3 collections, that is User, Recipe and Shopping. User collection will created based on user email. And under the User's collection, it will have two other collection that are Recipes and Shopping. This two collection will store the user recipe data and groceries. In User collection have display name and username field. While in Recipes collection have favorite, instruction and ingredient fields. And in Shopping collection it has quantity field. All the collection created by their name.

