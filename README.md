# BLoC event transformers

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.)
<img src="https://raw.githubusercontent.com/monterail/bloc_event_transformers/development/doc/assets/monterail_logo.svg" alt="Monterail's logo" width="25%" height="100" align="right"/>

Skip implementing transformers on your own and
configure timings in which events in your BLoC's are processed.

Available transformers:

- [throttle](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/throttle.html) (see [visualization](https://rxmarbles.com/#throttleTime))
- [debounce](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/debounce.html) (see [visualization](https://rxmarbles.com/#debounceTime))
- [skip](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/skip.html) (see [visualization](https://rxmarbles.com/#skip))
- [delay](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/delay.html) (see [visualization](https://rxmarbles.com/#delay))
