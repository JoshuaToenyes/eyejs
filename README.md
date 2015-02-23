# EyeJS

## EyeJS WebSocket Sub-Protocol

All EyeJS communication occurs using WebSockets as defined by RFC 6455. EyeJS
defines a custom WebSocket sub-protocol for communication between the
background process communicating with the eye-tracker and the client process
such as a webbrowser or other application.

### General Message Format

All EyeJS messages will contain a `type` field which defines the expected
payload fields with the message.

    {
      type: <string>
      ...
    }

### Gaze Messages

Gaze messages are sent to the client when updated gaze coordinates are
available from the tracker. This typically will occur 30 or more times per
second.

    {
      type: 'gaze',

      // millisecond timestamp
      timestamp: <number>,

      // averaged (x, y) coordinates of gaze
      avg: {
        x: <number>,
        y: <number>
      },

      // (x, y) screen coordinates of left eye
      left: {
        x: <number>,
        y: <number>
      },

      // (x, y) screen coordinates of right eye
      right: {
        x: <number>,
        y: <number>
      }

      available: {
        left:   <boolean>,
        right:  <boolean>,
        both:   <boolean>
      }
    }
