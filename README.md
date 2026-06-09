# Problem?

Problem? - мобильное Flutter-приложение для локального дневника самоанализа. Пользователь создает запись по пяти шагам, описывает ситуацию, мысли, телесные ощущения, последствия и то, что он делал бы без проблемы. Записи хранятся на устройстве через `shared_preferences`, без серверной части, аккаунтов, аналитики, рекламы и облачной синхронизации.

Приложение помогает бережно разложить трудную ситуацию на наблюдаемые части, найти повторяющиеся темы и подготовить записи для самостоятельного анализа или анализа в отдельном AI-чате. Кнопка "Скопировать для AI" формирует структурированный промпт и JSON со всеми записями, но отправка никуда не выполняется автоматически: пользователь сам вставляет текст в выбранный чат.

## Возможности

- создание записи через 5 последовательных шагов;
- редактирование записи, даты и времени события;
- поиск по заголовку, ситуации и мыслям;
- группировка записей по датам;
- локальное хранение дневника на устройстве;
- экран инструкций с подсказками по заполнению;
- копирование дневника в буфер обмена в формате промпта для AI;
- светлая и темная тема по настройкам системы.

## Технологии

- Flutter / Dart;
- Material UI;
- `shared_preferences` для локального хранения;
- `flutter_launcher_icons` для генерации иконок;
- платформы: iOS, Android, macOS, web, Linux, Windows.

## Идентификаторы и версия

Текущие значения проекта:

- app name: `Problem?`;
- Flutter package: `problem_mobile`;
- версия: `1.0.0+1` в `pubspec.yaml`;
- iOS Bundle Identifier: `com.ayratzarip.problemMobile`;
- Android applicationId: `com.ayratzarip.problem_mobile`;
- Android namespace: `com.ayratzarip.problem_mobile`.

Для App Store Bundle Identifier должен начинаться с `com.ayratzarip`. В этом проекте уже используется `com.ayratzarip.problemMobile`.

## Локальная разработка

Перед сборкой проверьте окружение:

```bash
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

Запуск на iOS Simulator:

```bash
open -a Simulator
flutter run -d ios
```

Запуск на Android-эмуляторе:

```bash
flutter emulators
flutter emulators --launch <emulator_id>
flutter run -d android
```

Обновление иконок после замены `assets/branding/app_icon_source.png`:

```bash
dart run flutter_launcher_icons
```

Обновление версии перед релизом:

```yaml
version: 1.0.1+2
```

Формат: `1.0.1` - публичная версия, `2` - номер сборки. Для каждого нового upload в App Store и RuStore увеличивайте build number.

## Политика конфиденциальности на GitHub Pages

Статическая страница политики находится в `docs/privacy/index.html`. На странице есть переключение русского и английского языка, а корневой `docs/index.html` перенаправляет пользователя на политику.

После включения GitHub Pages URL будет таким:

```text
https://ayratzarip.github.io/problem_mobile/privacy/
```

Как опубликовать страницу через GitHub:

1. Запушьте изменения в репозиторий:

```bash
git add README.md docs
git commit -m "Add privacy policy page"
git push origin main
```

2. Откройте репозиторий на GitHub: https://github.com/ayratzarip/problem_mobile
3. Перейдите в `Settings` -> `Pages`.
4. В блоке `Build and deployment` выберите:

- Source: `Deploy from a branch`;
- Branch: `main`;
- Folder: `/docs`.

5. Нажмите `Save`.
6. Подождите публикацию. Обычно страница появляется через несколько минут. Если она не открылась сразу, проверьте вкладку `Actions` или блок `Pages` в настройках репозитория.

## Инструкция публикации в App Store

Инструкция рассчитана на macOS с установленными VS Code, Xcode, Android Studio и Transporter.

Официальные полезные ссылки:

- Flutter iOS deployment: https://docs.flutter.dev/deployment/ios
- App Store Connect: https://appstoreconnect.apple.com/
- Certificates, Identifiers & Profiles: https://developer.apple.com/account/resources/
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Transporter: https://apps.apple.com/app/transporter/id1450874784
- GitHub Pages publishing source: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

### 1. Подготовить проект

Проверьте зависимости и тесты:

```bash
cd /Users/ayratzarip/Programming/flutter/problem_mobile
flutter clean
flutter pub get
flutter analyze
flutter test
```

Проверьте текущие идентификаторы:

```bash
grep -n "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj
grep -n "CFBundleDisplayName" ios/Runner/Info.plist
```

Ожидаемое значение для приложения:

```text
com.ayratzarip.problemMobile
```

Если нужно изменить Bundle Identifier, откройте проект:

```bash
open ios/Runner.xcworkspace
```

В Xcode выберите `Runner` -> target `Runner` -> `Signing & Capabilities`:

- Team: выберите свой Apple Developer Team;
- Bundle Identifier: `com.ayratzarip.problemMobile`;
- Automatically manage signing: включено;
- Signing Certificate: `Apple Distribution`, если Xcode предлагает выбор для release.

Во вкладке `General`:

- Display Name: `Problem?`;
- Version: `1.0.0`;
- Build: `1`;
- Deployment Target: оставьте текущий или выберите минимальную версию iOS, которую готовы поддерживать.

### 2. Создать Bundle ID в Apple Developer

Откройте https://developer.apple.com/account/resources/identifiers/list и нажмите `+`.

Что выбирать:

- Register a new identifier: `App IDs`;
- Type: `App`;
- Description: `Problem?`;
- Bundle ID: `Explicit`;
- Bundle ID value: `com.ayratzarip.problemMobile`;
- Capabilities: ничего дополнительно не включать, если Xcode не требует. Для текущей версии не нужны Push Notifications, Associated Domains, iCloud, Sign in with Apple, HealthKit.

Нажмите `Continue` -> `Register`.

### 3. Создать приложение в App Store Connect

Откройте https://appstoreconnect.apple.com/ -> `My Apps` -> `+` -> `New App`.

Что выбирать и вводить:

- Platforms: `iOS`;
- Name: `Problem?`;
- Primary Language: `Russian`;
- Bundle ID: `com.ayratzarip.problemMobile`;
- SKU: `problem-mobile-ios`;
- User Access: `Full Access`, если доступен такой выбор.

После создания откройте `App Information`.

Что выбрать:

- Category / Primary: `Health & Fitness`;
- Category / Secondary: `Lifestyle`;
- Content Rights: `No, it does not contain, show, or access third-party content`;
- Age Rating: пройдите анкету, для текущей версии выбирайте `None` / `No` по пунктам про насилие, азартные игры, сексуальный контент, unrestricted web access, commerce, medical treatment. Ожидаемый результат: `4+`;
- Made for Kids: `No`;
- License Agreement: `Standard Apple License Agreement`.

### 4. Заполнить карточку App Store

Поле `Subtitle`:

```text
Локальный дневник самоанализа
```

Поле `Promotional Text`:

```text
Problem? помогает спокойно разобрать трудную ситуацию по шагам: факты, мысли, телесные ощущения, последствия и желаемое действие без проблемы.
```

Поле `Description`:

```text
Problem? - локальный дневник самоанализа для тех, кто хочет лучше понимать свои повторяющиеся трудности.

Создавайте записи по пяти простым шагам:
1. Что происходит?
2. О чем вы думаете?
3. Что ощущаете в теле?
4. Как это мешает жить?
5. Что бы вы делали без проблемы?

Приложение помогает отделить факты от мыслей, заметить телесные реакции, сформулировать последствия и увидеть, какие действия становятся доступнее без проблемы.

Все записи хранятся только на вашем устройстве. Problem? не использует аккаунты, серверы, рекламу, аналитику или облачную синхронизацию.

Если вы хотите обсудить записи с AI, приложение может скопировать структурированный промпт в буфер обмена. Дальше вы сами решаете, куда его вставлять и отправлять ли вообще.

Важно: приложение не ставит диагнозы, не является медицинской услугой и не заменяет психолога, психотерапевта, врача или кризисную помощь.
```

Поле `Keywords`:

```text
дневник,самоанализ,мысли,эмоции,тревога,рефлексия,психология,записи
```

Поле `Support URL`:

```text
https://github.com/ayratzarip/problem_mobile/issues
```

Поле `Marketing URL` можно оставить пустым или указать:

```text
https://ayratzarip.github.io/problem_mobile/
```

Поле `Privacy Policy URL` обязательно. Укажите:

```text
https://ayratzarip.github.io/problem_mobile/privacy/
```

Перед отправкой на ревью включите GitHub Pages по инструкции выше и проверьте, что ссылка открывается без авторизации.

### 5. Текст политики конфиденциальности

Можно использовать как основу для страницы `Privacy Policy URL`:

```text
Политика конфиденциальности Problem?

Problem? - приложение для локального дневника самоанализа.

Какие данные обрабатываются:
Пользователь может вводить текстовые записи о ситуациях, мыслях, телесных ощущениях, последствиях и желаемых действиях.

Где хранятся данные:
Все записи хранятся локально на устройстве пользователя. Приложение не использует серверную часть, аккаунты, облачную синхронизацию, рекламу и аналитические SDK.

Передача данных:
Приложение не передает записи разработчику и третьим лицам. Функция "Скопировать для AI" только помещает подготовленный текст в буфер обмена устройства. Пользователь самостоятельно решает, куда вставить этот текст и отправлять ли его во внешние сервисы.

Доступ к данным:
Доступ к записям имеет только пользователь через свое устройство. При удалении приложения локальные данные могут быть удалены операционной системой.

Медицинский статус:
Problem? не является медицинским изделием, не ставит диагнозы и не заменяет консультацию специалиста. При угрозе жизни, здоровью или безопасности необходимо обратиться за срочной профессиональной помощью или в экстренные службы.

Контакты:
По вопросам конфиденциальности: draazaripov@yandex.ru
```

### 6. App Privacy в App Store Connect

Откройте `App Privacy` -> `Get Started`.

Для текущей версии выбирайте:

- Do you or your third-party partners collect data from this app?: `No`.

Обоснование: текущая версия хранит пользовательский текст только на устройстве и не передает его разработчику или сторонним SDK. Если позже добавятся сервер, аналитика, crash reporting, авторизация, реклама или облачная синхронизация, ответы нужно обновить.

### 7. Export Compliance

В разделе экспортного контроля выберите:

- Does your app use encryption?: `No`, если приложение не добавляло собственную криптографию и использует только стандартные возможности ОС/Flutter без сетевых соединений.

Если App Store Connect формулирует вопрос как "Does your app use or access encryption?", для текущей версии обычно можно выбрать вариант про стандартное шифрование ОС без отдельной документации, если такой вариант доступен. При сомнении проверьте актуальную формулировку Apple перед отправкой.

### 8. Скриншоты

Сделайте скриншоты на симуляторах iPhone. Минимальный набор для App Store обычно включает современные размеры iPhone, которые App Store Connect попросит в интерфейсе.

Запуск симулятора:

```bash
open -a Simulator
flutter run -d ios --release
```

Рекомендуемые экраны для скриншотов:

- главный экран с несколькими записями;
- шаг "Что происходит?";
- шаг "Что ощущаете в теле?";
- экран редактирования;
- экран инструкций.

Тексты для подписей на скриншотах:

```text
Разберите ситуацию по шагам
Запишите мысли и телесные ощущения
Увидьте, как проблема мешает жить
Храните дневник локально на устройстве
Скопируйте записи для анализа в AI
```

### 9. Собрать IPA

В терминале:

```bash
cd /Users/ayratzarip/Programming/flutter/problem_mobile
flutter clean
flutter pub get
flutter build ipa --release --build-name=1.0.0 --build-number=1
```

Ожидаемый файл:

```text
build/ios/ipa/*.ipa
```

Если сборка ругается на signing, откройте Xcode:

```bash
open ios/Runner.xcworkspace
```

Затем проверьте `Signing & Capabilities`, выберите Team и повторите команду сборки.

### 10. Загрузить IPA через Transporter

Откройте Transporter:

```bash
open -a Transporter
```

Дальше:

- войдите под Apple ID с доступом к App Store Connect;
- перетащите файл `build/ios/ipa/*.ipa` в окно Transporter;
- нажмите `Verify`, если кнопка доступна;
- нажмите `Deliver`;
- дождитесь письма от Apple или появления сборки во вкладке `TestFlight` / `Activity`.

### 11. Отправить на ревью

В App Store Connect откройте версию `1.0.0` и заполните:

- Build: выберите загруженную сборку;
- Version Release: `Manually release this version`, если хотите выпустить вручную после одобрения, или `Automatically release this version`;
- App Review Information / Contact Information: ваши имя, телефон, email;
- Sign-In Information: `No`, потому что аккаунтов нет;
- Notes:

```text
Problem? is a local self-reflection diary. The app has no account system, no server backend, no analytics, no ads, and no cloud sync.

All diary entries are stored locally on the user's device. The "Copy for AI" button only copies a structured prompt to the system clipboard; the app does not send this content anywhere.

The app is not a medical service, does not diagnose conditions, and does not replace professional help.
```

Нажмите `Add for Review` -> `Submit to App Review`.

## Инструкция публикации в RuStore

Инструкция рассчитана на Android-релиз с macOS, Android Studio и Flutter.

Официальные полезные ссылки:

- RuStore Console: https://console.rustore.ru/
- Публикация приложений RuStore: https://www.rustore.ru/help/developers/publishing-and-verifying-apps
- Upload AAB: https://www.rustore.ru/help/developers/publishing-and-verifying-apps/app-publication/new-version-app/upload-aab
- Категории приложений: https://www.rustore.ru/help/developers/publishing-and-verifying-apps/app-publication/new-version-app/category
- Возрастные ограничения: https://www.rustore.ru/help/developers/publishing-and-verifying-apps/app-publication/new-version-app/age-restrictions

### 1. Подготовить Android release signing

Сейчас `android/app/build.gradle.kts` подписывает release debug-ключом. Для публикации нужен отдельный release-ключ.

Создайте keystore:

```bash
cd /Users/ayratzarip/Programming/flutter/problem_mobile
keytool -genkey -v \
  -keystore ~/problem-mobile-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias problem_mobile
```

Создайте файл `android/key.properties`:

```properties
storePassword=ВАШ_ПАРОЛЬ_KEYSTORE
keyPassword=ВАШ_ПАРОЛЬ_КЛЮЧА
keyAlias=problem_mobile
storeFile=/Users/ayratzarip/problem-mobile-release.jks
```

Добавьте `android/key.properties` в `.gitignore`, если его там нет:

```bash
grep -n "android/key.properties" .gitignore
```

Если команда ничего не вывела, добавьте строку `android/key.properties` в `.gitignore`.

В `android/app/build.gradle.kts` замените debug signing для release на release signing. Для Kotlin DSL используйте такую схему. Импорты должны быть в самом верху файла:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

После правки проверьте:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

### 2. Собрать AAB

Убедитесь, что версия в `pubspec.yaml` обновлена:

```yaml
version: 1.0.0+1
```

Соберите Android App Bundle:

```bash
cd /Users/ayratzarip/Programming/flutter/problem_mobile
flutter build appbundle --release --build-name=1.0.0 --build-number=1
```

Ожидаемый файл:

```text
build/app/outputs/bundle/release/app-release.aab
```

Дополнительно можно собрать APK для локальной проверки:

```bash
flutter build apk --release --build-name=1.0.0 --build-number=1
```

Установка APK на подключенный Android-девайс:

```bash
flutter devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 3. Создать приложение в RuStore Console

Откройте https://console.rustore.ru/ -> `Приложения` -> `Добавить приложение`.

Что вводить:

- Название приложения: `Problem?`;
- Тип приложения: `Приложение`;
- Платформа: `Android`;
- Package name / package ID: `com.ayratzarip.problem_mobile`;
- Распространение: `Бесплатно`;
- Монетизация: `Нет`, если приложение без покупок и рекламы.

Если RuStore предлагает загрузить подпись для AAB, следуйте подсказке консоли и используйте PEPK-команду, которую RuStore сгенерирует именно для вашего приложения. Не используйте чужую команду: в ней есть уникальный encryption key.

### 4. Загрузить сборку

В карточке приложения выберите `Загрузить новую версию`.

Что выбирать:

- Формат файла: `AAB`, если есть выбор;
- Файл: `build/app/outputs/bundle/release/app-release.aab`;
- Версия: `1.0.0`;
- Номер версии: `1`;
- Тип релиза: `Релиз`;
- Публикация после модерации: `Опубликовать автоматически после модерации`, если хотите сразу выпустить, или `Вручную`, если хотите проверить статус перед публикацией.

Текст для поля "Что нового":

```text
Первый релиз Problem?.

Добавлены:
- создание записей по 5 шагам;
- локальное хранение дневника на устройстве;
- поиск и редактирование записей;
- экран инструкций;
- копирование записей в формате промпта для AI.
```

### 5. Заполнить карточку RuStore

Краткое описание:

```text
Локальный дневник самоанализа по 5 шагам.
```

Полное описание:

```text
Problem? - приложение для локального дневника самоанализа.

Оно помогает разобрать трудную ситуацию по пяти шагам:
1. Что происходит?
2. О чем вы думаете?
3. Что ощущаете в теле?
4. Как это мешает жить?
5. Что бы вы делали без проблемы?

Записи можно искать, редактировать и группировать по датам. Встроенные инструкции помогают понять, что писать на каждом шаге.

Все записи хранятся только на устройстве. В приложении нет аккаунтов, серверов, рекламы, аналитики и облачной синхронизации.

Функция "Скопировать для AI" подготавливает структурированный текст и помещает его в буфер обмена. Приложение не отправляет этот текст автоматически: пользователь сам решает, куда его вставить.

Problem? не является медицинской услугой, не ставит диагнозы и не заменяет специалиста.
```

Категория:

```text
Здоровье и фитнес
```

Если такой категории в выпадающем списке нет, выбирайте:

```text
Образ жизни
```

Возрастное ограничение:

```text
0+
```

Если RuStore считает, что из-за тем самоанализа лучше повысить рейтинг, выбирайте:

```text
12+
```

Ключевые слова / поисковые теги:

```text
дневник, самоанализ, рефлексия, мысли, эмоции, тревога, психология, записи, привычки, осознанность
```

Сайт:

```text
https://ayratzarip.github.io/problem_mobile/
```

Поддержка:

```text
draazaripov@yandex.ru
```

Политика конфиденциальности:

```text
https://ayratzarip.github.io/problem_mobile/privacy/
```

### 6. Декларации данных и разрешений

В текущем AndroidManifest нет опасных разрешений. Приложение не запрашивает камеру, микрофон, геолокацию, контакты, файлы, SMS, уведомления или телефон.

Если RuStore спрашивает про разрешения:

- Dangerous permissions: `Нет`;
- Special permissions: `Нет`;
- Signature permissions: `Нет`;
- Prohibited permissions: `Нет`;
- Доступ к интернету: `Нет`, если в манифест не добавляли `android.permission.INTERNET`.

Если RuStore спрашивает про сбор пользовательских данных:

- Собирает ли приложение данные пользователя: `Нет`;
- Передает ли приложение данные третьим лицам: `Нет`;
- Используется ли аналитика: `Нет`;
- Используется ли реклама: `Нет`;
- Есть ли аккаунты: `Нет`;
- Есть ли серверная обработка записей: `Нет`;
- Где хранятся записи: `Локально на устройстве пользователя`.

Пояснение для модерации:

```text
Приложение хранит записи пользователя локально на устройстве через shared_preferences. Серверная часть, аккаунты, аналитика, реклама и автоматическая отправка данных отсутствуют. Кнопка "Скопировать для AI" только копирует текст в буфер обмена устройства.
```

### 7. Скриншоты для RuStore

Рекомендуемые скриншоты:

- главный экран со списком записей;
- создание записи, шаг "Что происходит?";
- создание записи, шаг "О чем Вы думаете?";
- экран редактирования;
- экран инструкций.

Можно сделать скриншоты на Android-эмуляторе:

```bash
flutter emulators
flutter emulators --launch <emulator_id>
flutter run -d android --release
```

Тексты для подписей:

```text
Пятишаговый дневник самоанализа
Отделяйте ситуацию от мыслей
Замечайте телесные реакции
Храните записи локально
Копируйте дневник для анализа в AI
```

### 8. Контакты и примечание для модератора

Текст для поля "Комментарий для модератора":

```text
Problem? - локальный дневник самоанализа. Приложение не требует регистрации, не использует серверы, не собирает аналитику и не показывает рекламу.

Пользовательские записи сохраняются только на устройстве. Функция "Скопировать для AI" копирует подготовленный текст в буфер обмена, но приложение не отправляет его во внешние сервисы.

Приложение не является медицинским изделием, не ставит диагнозы и не оказывает медицинские услуги.
```

После заполнения карточки отправьте приложение на модерацию. Если выбран ручной релиз, после одобрения вернитесь в карточку версии и нажмите публикацию вручную.
