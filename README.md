# godot-narwhal-manager

Godot app for managing TuFFrabit devices over USB serial.

## Serial layer

This project uses [GdSerial](https://github.com/SujithChristopher/gdserial),
a Rust-based GDExtension for Godot 4, vendored under `addons/gdserial/`.

- **Version:** v0.3.4
- **Source:** https://github.com/SujithChristopher/gdserial/releases/tag/v0.3.4
- **License:** MIT (see `addons/gdserial/LICENSE`)

On Linux, the user must be in the `dialout` group to access serial ports:

```bash
sudo usermod -a -G dialout $USER
# Log out and back in for the change to take effect.
```
