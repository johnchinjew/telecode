# Telecode POC

## Development

```
pip install https://github.com/joh/when-changed/archive/master.zip
when-changed -rs . elm make src/Main.elm --output=static/main.js
python3 -m http.server
```

## Notes

- High score, turn-based, N players
- "Correspondence" game style?
- Add hearts?
- Stack: Heroku + Socket.IO + Elm
- Connection and presence instability
    - Disconnect (underlying socket is broken),
    - Page unload (navigation change, closed tab, closed browser),
    - Page hide (open home screen, sleep device)
- Think of better name...

## License

All rights reserved.
