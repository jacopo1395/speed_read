import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/main.dart';
import 'package:speed_read/service/shared_preferences.service.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class FontSettingsPage extends StatefulWidget {
  @override
  _FontSettingsPageState createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends State<FontSettingsPage> {
  late Color textDialogPickerColor;
  late Color backgroundDialogPickerColor;

  @override
  void initState() {
    textDialogPickerColor = black;
    backgroundDialogPickerColor = white;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Font Settings'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: SizedBox(
                height: 100,
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor metus vel porttitor rhoncus. Etiam a mi quis augue fringilla auctor. Duis volutpat mauris ut risus varius, eget luctus ante pellentesque. Curabitur euismod feugiat neque, sit amet porta orci dapibus eget. Duis pulvinar mauris ac ullamcorper facilisis. Proin commodo ut leo eget iaculis. Nulla eu euismod massa. Aenean aliquam facilisis tristique. Nullam vestibulum libero elementum ipsum ultricies, vel auctor tellus pretium. Cras scelerisque fringilla malesuada. Nam tincidunt nisi et enim viverra, sit amet sodales sapien ornare. Nullam odio tellus, rutrum in diam a, ultricies hendrerit nisl. Ut non mattis ante.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: padding),
                    child: Icon(Icons.format_size, color: black),
                  ),
                  Flexible(
                    child: TextFormField(
                      initialValue:
                          SharedPreferenceService().fontSize.toString(),
                      onChanged: (String value) {
                        SharedPreferenceService()
                            .setFontSize(double.parse(value));
                        isThemeChanged.add(AppThemes.primaryTheme.copyWith(
                            textTheme: AppThemes.primaryTextTheme.copyWith(
                                bodyText1: AppThemes.primaryTextTheme.bodyText1
                                    ?.copyWith(
                                        fontSize: double.parse(value)))));
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Row(
                children: [
                  Icon(Icons.color_lens, color: black),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('Text color:'),
                  ),
                  ColorIndicator(
                    width: 44,
                    height: 44,
                    borderRadius: 4,
                    color: textDialogPickerColor,
                    onSelectFocus: false,
                    onSelect: () async {
                      // Store current color before we open the dialog.
                      final colorBeforeDialog = textDialogPickerColor;
                      // Wait for the picker to close, if dialog was dismissed,
                      // then restore the color we had before it was opened.
                      if (!(await colorPickerDialog())) {
                        setState(() {
                          textDialogPickerColor = colorBeforeDialog;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Row(
                children: [
                  Icon(Icons.color_lens_outlined, color: black),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('Background color:'),
                  ),
                  ColorIndicator(
                    width: 44,
                    height: 44,
                    borderRadius: 4,
                    color: textDialogPickerColor,
                    onSelectFocus: false,
                    onSelect: () async {
                      // Store current color before we open the dialog.
                      final colorBeforeDialog = textDialogPickerColor;
                      // Wait for the picker to close, if dialog was dismissed,
                      // then restore the color we had before it was opened.
                      if (!(await colorPickerDialog())) {
                        setState(() {
                          textDialogPickerColor = colorBeforeDialog;
                        });
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void changeTextColor(Color color) {
    SharedPreferenceService().setFontColor(color.value);

    isThemeChanged.add(AppThemes.primaryTheme.copyWith(
        textTheme: AppThemes.primaryTextTheme.copyWith(
            bodyText1:
                AppThemes.primaryTextTheme.bodyText1?.copyWith(color: color))));
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: textDialogPickerColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) {
        setState(() => textDialogPickerColor = color);
        changeTextColor(textDialogPickerColor);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      // customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
}
