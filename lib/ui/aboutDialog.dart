import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_alarm/i18n.dart';

void showGalleryAboutDialog(BuildContext context) {
  const LicenseEntry entry =
      const LicenseEntryWithLineBreaks(<String>['Sunrise-Sunset'], '''
Sunrise-Sunset © 2019

We offer a free API that provides sunset and sunrise times for a given latitude and longitude.

The sunrise and sunset API can be used free of charge. You may not use this API in a manner that exceeds reasonable request volume, constitutes excessive or abusive usage. We require that you show attribution to us with a link to our site.
          
https://sunrise-sunset.org/api        
''');

  final Function onValue = (bool element) {
    if (!element) {
      LicenseRegistry.addLicense(() {
        return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[entry]);
      });
    }

    showAboutDialog(
      context: context,
      applicationVersion: 'März 2019',
      applicationIcon: const FlutterLogo(),
      applicationLegalese: '© 2019 David Seemann',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: Theme.of(context).textTheme.body2,
                  text: AppTranslations.of(context).text('about'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  };

  LicenseRegistry.licenses.contains(entry).then(onValue);
}
