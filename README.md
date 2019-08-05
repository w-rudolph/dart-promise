## Promise for dartlang

Promise feature for dartlang, reference from javascript Promise.


|Feature|Dart|ES Promise|
|--|--|--|
|then|promise.then|promise.then|
|catch|promise.catchError(`catch` is a keyword in dart, not allowed as a method, use `catchError` instead)|Promise.catch|
|finally|promise.always(`finally` is a keyword in dart, not allowed as a method, use `always` instead)|Promise.finally|
|resolve|Promise.resolve|Promise.resolve|
|reject|Promise.reject|Promise.reject|
|race|Promise.race|Promise.race|
|all|Promise.all|Promise.all|

## Example
```dart
import 'dart:async';
import './lib/promise.dart';

Promise delay(int seconds, String val) {
  return Promise((resolve, _) {
    Timer(Duration(seconds: seconds), () {
      resolve(val);
    });
  });
}

void main() {
  // case 1
  Promise((resolve, reject) {
    Timer(Duration(seconds: 2), () {
      resolve('Case1: resolved');
    });
  }).then(print);

  // case 2
  Promise((resolve, reject) {
    Timer(Duration(seconds: 2), () {
      reject('Case2: rejected');
    });
  }).then(null, print);

  // case 3
  Promise.all([delay(2, 'A'), delay(1, 'B'), delay(3, 'C')]).then((val) {
    print('Case3: $val');
  });

  // case 4
  Promise.race([delay(2, 'A'), delay(1, 'B'), delay(3, 'C')]).then((val) {
    print('Case4: $val');
  });

  // case 5
  Promise.reject('Case5').catchError((err) {
    print('Case5: Error');
  }).always(() => print('Case5: always run'));

  // case 6
  Promise.resolve('Case6').then((val) {
    return Promise.reject('$val: nested');
  }).catchError(print);

  // case 7
  Promise((resolve, reject) {
    resolve('Case7: run first, ignore next reslove or reject');
    reject('Case7: reject run?');
  }).then(print);
}
```
