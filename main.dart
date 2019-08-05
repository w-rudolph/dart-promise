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
