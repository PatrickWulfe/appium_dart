import 'package:test/test.dart';

import 'package:appium_driver/async_io.dart';

void main() {
  AppiumWebDriver driver;

  setUpAll(() async {
    driver = await createDriver(
        uri: Uri.parse('http://127.0.0.1:4723/wd/hub/'),
        desired: {
          'platformName': 'Android',
          'browserName': 'Chrome',
          'deviceName': 'Android',
          'autoAcceptsAlerts': 'true',
          'automationName': 'UiAutomator2',
          'headspin.selector': {'sku': 'Pixel', 'os_version': '>5'},
        });
    await driver.timeouts.setImplicitTimeout(Duration(seconds: 5));
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('Click a button', () async {
    final buttons = 'Buttons';
    final gray = 'Gray';
    final textView = 'TextView';

    var element = await driver.findElement(AppiumBy.accessibilityId(buttons));
    await element.click();

    await driver.findElement(AppiumBy.name(gray));
    await driver.back();

    await driver.findElement(AppiumBy.accessibilityId(textView));
  });
}