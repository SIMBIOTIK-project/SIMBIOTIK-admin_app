# SIMBIOTIK Access

### Run Project
- Clone project 
```
git clone https://github.com/SIMBIOTIK-project/SIMBIOTIK-customer_app.git
```

Note: You can use [Project IDX](https://idx.dev) to clone this project.

- Create the ```.env``` and ```.env_dev``` in the root project with value
```
URL = "https://'name-site-API'"
``` 

Note: For API URL you can contact Developer/Owner this project

- Run pub get in Terminal
```
flutter pub get
```

- Run Project
For Development
```
flutter run --flavor dev --target lib/main_dev.dart
```

For Production
```
flutter run --flavor prod --target lib/main_prod.dart
```

Build Apk
```
flutter build apk --flavor=prod --target=lib/main_prod.dart --dart-define-from-file=.env
```


If Error: 
- Execution failed for task ':app:checkProdReleaseDuplicateClasses'.

Solution: Add in adndroid/app/build.gradle file
```
configurations.all {
    resolutionStrategy {
        eachDependency {
            if ((requested.group == "org.jetbrains.kotlin") && (requested.name.startsWith("kotlin-stdlib"))) {
                useVersion("1.8.0")
            }
        }
    }
}
```