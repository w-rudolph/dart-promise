import 'dart:async';

enum PromiseStatus { PENDING, RESOLVED, REJECTED }

typedef Func(Object val);

class Promise {
  PromiseStatus _status = PromiseStatus.PENDING;
  dynamic _value;
  dynamic _reason;
  List<Func> _rejectedCallbacks = [];
  List<Func> _resolvedCallbacks = [];

  get value {
    return this._value;
  }

  get reason {
    return this._reason;
  }

  PromiseStatus get status {
    return this._status;
  }

  Promise(dynamic excutor(dynamic resolve(val), dynamic reject(val))) {
    if (!(excutor is Function)) {
      throw new AssertionError('Promise resolver $excutor is not a function');
    }
    try {
      excutor(this._resolve, this._reject);
    } catch (e) {
      this._reject(e);
    }
  }

  _resolve(value) {
    if (this.status == PromiseStatus.PENDING) {
      this._value = value;
      this._status = PromiseStatus.RESOLVED;
      this._resolvedCallbacks.forEach((fn) {
        fn(value);
      });
    }
  }

  _reject(reason) {
    if (this.status == PromiseStatus.PENDING) {
      this._reason = reason;
      this._status = PromiseStatus.REJECTED;
      this._rejectedCallbacks.forEach((fn) => fn(reason));
    }
  }

  Promise then(Func onFulfilled, [Func onRejected]) {
    if (!(onFulfilled is Function)) {
      onFulfilled = (val) => val;
    }
    if (!(onRejected is Function)) {
      onRejected = (err) => throw err;
    }
    Promise promise2;
    promise2 = new Promise((resolve, reject) {
      if (this.status == PromiseStatus.RESOLVED) {
        Timer.run(() {
          try {
            final x = onFulfilled(this._value);
            Promise.resolvePromise(promise2, x, resolve, reject);
          } catch (e) {
            reject(e);
          }
        });
      } else if (this.status == PromiseStatus.REJECTED) {
        Timer.run(() {
          try {
            final x = onRejected(this._reason);
            Promise.resolvePromise(promise2, x, resolve, reject);
          } catch (e) {
            reject(e);
          }
        });
      } else if (this.status == PromiseStatus.PENDING) {
        this._resolvedCallbacks.add((val) {
          Timer.run(() {
            try {
              final x = onFulfilled(val);
              Promise.resolvePromise(promise2, x, resolve, reject);
            } catch (e) {
              reject(e);
            }
          });
        });
        this._rejectedCallbacks.add((reason) {
          Timer.run(() {
            try {
              final x = onRejected(reason);
              Promise.resolvePromise(promise2, x, resolve, reject);
            } catch (e) {
              reject(e);
            }
          });
        });
      }
    });
    return promise2;
  }

  static void resolvePromise(
      Promise promise2, dynamic x, Func resolve, Func reject) {
    if (promise2 == x) {
      reject(new AssertionError('Chaining cycle detected for promise'));
      return;
    }
    bool called = false;
    if (x != null && (x is Promise)) {
      try {
        x.then((val) {
          if (called) return;
          called = true;
          Promise.resolvePromise(promise2, val, resolve, reject);
        }, (err) {
          if (called) return;
          called = true;
          reject(err);
        });
      } catch (e) {
        if (called) return;
        called = true;
        reject(e);
      }
    } else {
      resolve(x);
    }
  }

  Promise catchError(Func onRejected) {
    return this.then(null, onRejected);
  }

  Promise always(Function callback) {
    return this.then((value) {
      Promise.resolve(callback()).then((_) => value);
    }, (reason) {
      Promise.reject(callback()).catchError((_) => throw reason);
    });
  }

  static Promise resolve(value) {
    return new Promise((resolve, reject) {
      resolve(value);
    });
  }

  static Promise reject(reason) {
    return new Promise((_, reject) {
      reject(reason);
    });
  }

  static Promise race(List<Promise> promises) {
    return new Promise((resolve, reject) {
      promises.forEach((promise) {
        promise.then(resolve, reject);
      });
    });
  }

  static Promise all(List<Promise> promises) {
    final length = promises.length;
    int i = 0;
    return Promise((resolve, reject) {
      promises.forEach((promise) {
        promise.then((val) {
          i++;
          if (i == length) {
            resolve(promises.map((promise) => promise.value));
          }
        }, reject);
      });
    });
  }
}
