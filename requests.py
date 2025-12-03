"""Minimal requests-like shim for offline testing.
This is intentionally small and only supports what the tests require."""
from __future__ import annotations

import json
import urllib.parse
import urllib.request
import urllib.error
from dataclasses import dataclass


class RequestException(Exception):
    pass


class Timeout(RequestException):
    pass


class ConnectionError(RequestException):
    pass


@dataclass
class Response:
    status_code: int
    content: bytes
    headers: dict[str, str]

    def json(self):
        return json.loads(self.content.decode() or "null")

    def text(self):  # pragma: no cover
        return self.content.decode(errors="ignore")


class _RequestsShim:
    def _send(self, method: str, url: str, *, data=None, json_body=None, headers=None, timeout: float | None = None) -> Response:
        payload = None
        req_headers = headers.copy() if headers else {}
        if json_body is not None:
            payload = json.dumps(json_body).encode()
            req_headers.setdefault("Content-Type", "application/json")
        elif data is not None:
            if isinstance(data, dict):
                payload = urllib.parse.urlencode(data).encode()
                req_headers.setdefault("Content-Type", "application/x-www-form-urlencoded")
            else:
                payload = str(data).encode()
        req = urllib.request.Request(url, data=payload, headers=req_headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                body = resp.read()
                return Response(status_code=resp.getcode(), content=body, headers=dict(resp.headers))
        except urllib.error.HTTPError as exc:
            return Response(status_code=exc.code, content=exc.read() or b"", headers=dict(exc.headers or {}))
        except urllib.error.URLError as exc:
            raise ConnectionError(str(exc))

    def post(self, url: str, data=None, json=None, headers=None, timeout: float | None = None):
        return self._send("POST", url, data=data, json_body=json, headers=headers, timeout=timeout)

    def get(self, url: str, headers=None, timeout: float | None = None):
        return self._send("GET", url, headers=headers, timeout=timeout)


# exposed module-level helpers
_shim = _RequestsShim()
post = _shim.post
gGet = _shim.get  # legacy typo guard
get = _shim.get

class exceptions:
    ConnectionError = ConnectionError
    Timeout = Timeout
    RequestException = RequestException

__all__ = [
    "post",
    "get",
    "exceptions",
    "Response",
    "ConnectionError",
    "Timeout",
    "RequestException",
]
